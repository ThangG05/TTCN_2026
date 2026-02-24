using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using hubfinal.Data;
using hubfinal.DTOs;
using hubfinal.Entities;
using hubfinal.Services;

namespace hubfinal.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly JwtService _jwtService;
    private readonly EmailService _emailService;
    private readonly PasswordHasher<User> _hasher = new();

    public AuthController(AppDbContext context, JwtService jwtService, EmailService emailService)
    {
        _context = context;
        _jwtService = jwtService;
        _emailService = emailService;
    }

    // --- ĐĂNG KÝ ---
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest request)
    {
        if (string.IsNullOrEmpty(request.Email) || !request.Email.ToLower().EndsWith("@hvnh.edu.vn"))
            return BadRequest(new { message = "Chỉ chấp nhận email sinh viên Học viện Ngân hàng (@hvnh.edu.vn)" });

        if (await _context.Users.AnyAsync(x => x.Email == request.Email && !string.IsNullOrEmpty(x.PasswordHash)))
            return BadRequest(new { message = "Email này đã được đăng ký và kích hoạt." });

        var otp = new Random().Next(100000, 999999).ToString();

        _context.OtpCodes.Add(new OtpCode
        {
            Email = request.Email,
            Code = otp,
            ExpiredAt = DateTime.UtcNow.AddMinutes(5),
            IsUsed = false
        });

        await _context.SaveChangesAsync();
        await _emailService.SendOtpAsync(request.Email, otp);

        return Ok(new { message = "Mã OTP đã được gửi." });
    }

    // --- XÁC THỰC OTP ---
    [HttpPost("verify-otp")]
    public async Task<IActionResult> VerifyOtp(VerifyOtpRequest request)
    {
        var otp = await _context.OtpCodes
            .Where(x => x.Email == request.Email && !x.IsUsed)
            .OrderByDescending(x => x.Id)
            .FirstOrDefaultAsync();

        if (otp == null || otp.Code != request.Code || otp.ExpiredAt < DateTime.UtcNow)
            return BadRequest(new { message = "Mã xác thực không đúng hoặc đã hết hạn." });

        otp.IsUsed = true;
        await _context.SaveChangesAsync();

        return Ok(new { message = "Xác thực OTP thành công." });
    }

    // --- TẠO MẬT KHẨU LẦN ĐẦU (Dành cho Register) ---
    [HttpPost("create-password")]
    public async Task<IActionResult> CreatePassword(CreatePasswordRequest request)
    {
        var user = await _context.Users.FirstOrDefaultAsync(x => x.Email == request.Email);
        string defaultUsername = request.Email.Split('@')[0];

        if (user == null)
        {
            user = new User
            {
                Id = Guid.NewGuid(),
                Email = request.Email,
                Username = defaultUsername,
                DisplayName = defaultUsername,
                StudentCode = defaultUsername,
                IsEmailVerified = true,
                CreatedAt = DateTime.UtcNow
            };
            user.PasswordHash = _hasher.HashPassword(user, request.Password);
            _context.Users.Add(user);
        }
        else
        {
            // NẾU ĐÃ CÓ MẬT KHẨU RỒI THÌ KHÔNG CHO TẠO MỚI Ở ENDPOINT NÀY
            if (!string.IsNullOrEmpty(user.PasswordHash))
                return BadRequest(new { message = "Tài khoản này đã tồn tại. Vui lòng đăng nhập." });

            user.PasswordHash = _hasher.HashPassword(user, request.Password);
            _context.Users.Update(user);
        }

        await _context.SaveChangesAsync();
        await AssignUserRole(user); // Gán role

        return Ok(new { message = "Cài đặt mật khẩu thành công." });
    }

    // --- ĐẶT LẠI MẬT KHẨU (Dành cho Forgot Password) ---
    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword(CreatePasswordRequest request)
    {
        var user = await _context.Users.FirstOrDefaultAsync(x => x.Email == request.Email);

        if (user == null)
            return BadRequest(new { message = "Email này chưa được đăng ký trên hệ thống." });

        // Ghi đè mật khẩu mới (Reset)
        user.PasswordHash = _hasher.HashPassword(user, request.Password);
        _context.Users.Update(user);

        await _context.SaveChangesAsync();

        return Ok(new { message = "Đặt lại mật khẩu thành công." });
    }

    // --- ĐĂNG NHẬP ---
    [HttpPost("signin")]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        var user = await _context.Users.FirstOrDefaultAsync(x => x.Email == request.Email);

        if (user == null)
            return BadRequest(new { message = "Email này chưa được đăng ký." });

        if (user.IsLocked)
            return BadRequest(new { message = "Tài khoản bị khóa." });

        if (string.IsNullOrEmpty(user.PasswordHash))
            return BadRequest(new { message = "Tài khoản chưa được thiết lập mật khẩu." });

        var result = _hasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
        if (result == PasswordVerificationResult.Failed)
            return BadRequest(new { message = "Mật khẩu không chính xác." });

        var roles = await _context.UserRoles
            .Where(x => x.UserId == user.Id)
            .Join(_context.Roles, ur => ur.RoleId, r => r.Id, (ur, r) => r.Name)
            .ToListAsync();

        var token = _jwtService.GenerateToken(user, roles);
        return Ok(new { token, user = new { user.Email, user.DisplayName, user.StudentCode } });
    }

    // --- QUÊN MẬT KHẨU (Gửi OTP) ---
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request)
    {
        if (string.IsNullOrEmpty(request.Email) || !request.Email.ToLower().EndsWith("@hvnh.edu.vn"))
            return BadRequest(new { message = "Vui lòng nhập đúng định dạng email Học viện." });

        var user = await _context.Users.FirstOrDefaultAsync(x => x.Email == request.Email);

        if (user == null || string.IsNullOrEmpty(user.PasswordHash))
            return BadRequest(new { message = "Email này chưa được đăng ký trên hệ thống." });

        var otp = new Random().Next(100000, 999999).ToString();
        _context.OtpCodes.Add(new OtpCode
        {
            Email = request.Email,
            Code = otp,
            ExpiredAt = DateTime.UtcNow.AddMinutes(5),
            IsUsed = false
        });

        await _context.SaveChangesAsync();
        await _emailService.SendOtpAsync(request.Email, otp);

        return Ok(new { message = "Mã OTP khôi phục mật khẩu đã được gửi." });
    }

    // Hàm phụ trợ gán Role
    private async Task AssignUserRole(User user)
    {
        var role = await _context.Roles.FirstOrDefaultAsync(r => r.Name == "User");
        if (role != null)
        {
            var hasRole = await _context.UserRoles.AnyAsync(ur => ur.UserId == user.Id && ur.RoleId == role.Id);
            if (!hasRole)
            {
                _context.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = role.Id });
                await _context.SaveChangesAsync();
            }
        }
    }
}