using hubfinal.Data; // Thêm namespace này để dùng AppDbContext
using hubfinal.DTOs.User;
using hubfinal.Entities;
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
        [Authorize]
        [HttpGet("search")]
        public async Task<IActionResult> SearchByDisplayName([FromQuery] string name)
        {
            var currentUserId = _currentUser.UserId;
            if (string.IsNullOrEmpty(name)) return BadRequest("Tên tìm kiếm không được để trống.");

            var users = await _context.Users
                .AsNoTracking()
                .Where(u => u.Id != currentUserId && u.DisplayName != null && u.DisplayName.Contains(name))
                .Select(u => new
                {
                    u.Id,
                    u.DisplayName,
                    u.AvatarUrl,
                    IsFriend = _context.Friends.Any(f => (f.UserId == currentUserId && f.FriendId == u.Id) || (f.FriendId == currentUserId && f.UserId == u.Id)),
                    HasSentRequest = _context.FriendRequests.Any(fr => fr.SenderId == currentUserId && fr.ReceiverId == u.Id && fr.Status == "0"),
                    // MỚI: Kiểm tra xem người này có đang gửi lời mời cho mình không
                    IsIncomingRequest = _context.FriendRequests.Any(fr => fr.SenderId == u.Id && fr.ReceiverId == currentUserId && fr.Status == "0")
                })
                .Take(20)
                .ToListAsync();

            return Ok(users);
        }

        [Authorize]
        [HttpPost("send-request/{receiverId}")]
        public async Task<IActionResult> SendFriendRequest(string receiverId)
        {
            if (!Guid.TryParse(receiverId, out Guid receiverGuid)) return BadRequest("ID không hợp lệ.");
            var currentUserId = _currentUser.UserId;

            // SỬA: Kiểm tra cả 2 chiều để tránh tạo dòng dữ liệu trùng lặp
            var existingRequest = await _context.FriendRequests
                .AnyAsync(fr => ((fr.SenderId == currentUserId && fr.ReceiverId == receiverGuid) ||
                                 (fr.SenderId == receiverGuid && fr.ReceiverId == currentUserId)) &&
                                 fr.Status == "0");

            if (existingRequest) return BadRequest("Lời mời đã tồn tại giữa hai người.");

            var friendRequest = new hubfinal.Entities.FriendRequest
            {
                SenderId = currentUserId,
                ReceiverId = receiverGuid,
                Status = "0",
                CreatedAt = DateTime.Now
            };

            _context.FriendRequests.Add(friendRequest);
            await _context.SaveChangesAsync();
            return Ok();
        }
        // Lấy danh sách lời mời kết bạn ĐẾN mình
        [Authorize]
        [HttpGet("pending-requests")]
        public async Task<IActionResult> GetPendingRequests()
        {
            var currentUserId = _currentUser.UserId;

            var requests = await _context.FriendRequests
                .AsNoTracking()
                .Where(fr => fr.ReceiverId == currentUserId && fr.Status == "0")
                .Select(fr => new
                {
                    fr.Id, // ID của bản ghi FriendRequest (kiểu int trong DB của bạn)
                    SenderId = fr.SenderId,
                    DisplayName = fr.Sender.DisplayName,
                    AvatarUrl = fr.Sender.AvatarUrl
                })
                .ToListAsync();

            return Ok(requests);
        }

        [Authorize]
        [HttpPost("accept-request/{requestId}")]
        public async Task<IActionResult> AcceptFriendRequest(int requestId)
        {
            // 1. Tìm lời mời dựa trên requestId (kiểu int khớp với DB)
            var request = await _context.FriendRequests.FindAsync(requestId);

            if (request == null)
            {
                return NotFound("Không tìm thấy lời mời kết bạn.");
            }

            // 2. Cập nhật trạng thái thành "1" (Dạng chuỗi khớp với nvarchar)
            request.Status = "1";

            // 3. Khởi tạo quan hệ bạn bè mới
            // Sử dụng tên đầy đủ để tránh lỗi CS0117 nếu có xung đột lớp
            var friendRelation = new hubfinal.Entities.Friend
            {
                UserId = request.ReceiverId,
                FriendId = request.SenderId,
            };

            try
            {
                _context.Friends.Add(friendRelation);

                // Cập nhật lại bản ghi FriendRequest
                _context.FriendRequests.Update(request);

                await _context.SaveChangesAsync();
                return Ok(new { message = "Đã chấp nhận lời mời kết bạn." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi khi lưu dữ liệu: {ex.Message}");
            }
        }
        [Authorize]
        [HttpDelete("decline-request/{requestId}")]
        public async Task<IActionResult> DeclineFriendRequest(int requestId)
        {
            // Tìm lời mời dựa trên Id (kiểu int)
            var request = await _context.FriendRequests.FindAsync(requestId);

            if (request == null) return NotFound("Không tìm thấy lời mời.");

            // Xóa lời mời khỏi Database
            _context.FriendRequests.Remove(request);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã gỡ lời mời kết bạn." });
        }

    }
}