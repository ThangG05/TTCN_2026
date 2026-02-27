using hubfinal.Data; // Thêm namespace này để dùng AppDbContext
using hubfinal.DTOs.User;
using hubfinal.Helpers;
using hubfinal.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace hubfinal.Controllers
{
    [ApiController]
    [Route("api/users")]
    public class UsersController : ControllerBase
    {
        private readonly UserService _userService;
        private readonly CurrentUser _currentUser;
        private readonly AppDbContext _context; // 1. Khai báo thêm AppDbContext

        // 2. Thêm AppDbContext vào Constructor
        public UsersController(UserService userService, CurrentUser currentUser, AppDbContext context)
        {
            _userService = userService;
            _currentUser = currentUser;
            _context = context;
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            var userDto = await _userService.GetCurrentUserDtoAsync(_currentUser.UserId);
            if (userDto == null) return Unauthorized();
            return Ok(userDto);
        }

        [Authorize]
        [HttpPut("update-profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            var result = await _userService.UpdateProfileAsync(_currentUser.UserId, request);
            if (!result) return BadRequest();
            return Ok();
        }

        [Authorize]
        [HttpPut("update-avatar")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UpdateAvatar([FromForm] UpdateAvatarRequest request)
        {
            if (request.File == null || request.File.Length == 0)
                return BadRequest("No file uploaded");

            var avatarPath = await _userService.UpdateAvatarAsync(
                _currentUser.UserId,
                request.File
            );

            if (avatarPath == null)
                return BadRequest();

            return Ok(new { avatarUrl = avatarPath });
        }

        [Authorize] // Nên thêm Authorize để bảo mật và lấy đúng currentUserId
        [HttpGet("search")]
        public async Task<IActionResult> SearchByDisplayName([FromQuery] string name)
        {
            // Lưu ý: Sử dụng _currentUser.UserId hoặc _currentUser.Id tùy theo class CurrentUser của bạn
            var currentUserId = _currentUser.UserId;

            if (string.IsNullOrEmpty(name))
            {
                return BadRequest("Tên tìm kiếm không được để trống.");
            }

            // Sử dụng _context đã được inject ở trên
            var users = await _context.Users
                .AsNoTracking()
                .Where(u => u.Id != currentUserId && u.DisplayName != null && u.DisplayName.Contains(name))
                .Select(u => new
                {
                    u.Id,
                    u.DisplayName,
                    u.AvatarUrl,
                    // Logic kiểm tra quan hệ dựa trên 2 bảng bạn đã tạo
                    IsFriend = _context.Friends.Any(f => f.UserId == currentUserId && f.FriendId == u.Id),
                    HasSentRequest = _context.FriendRequests.Any(fr =>
    fr.SenderId == currentUserId &&
    fr.ReceiverId == u.Id &&
    fr.Status == 0) // 0 tương ứng với Pending như bạn đã định nghĩa trong Entity
                })
                .Take(20)
                .ToListAsync();

            return Ok(users);
        }
    }
}