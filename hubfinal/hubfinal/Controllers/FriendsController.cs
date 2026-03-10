using hubfinal.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace hubfinal.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class FriendsController : ControllerBase
    {
        private readonly FriendService _friendService;
        public FriendsController(FriendService friendService) => _friendService = friendService;

        [HttpGet("my-friends")]
        public async Task<IActionResult> GetFriends()
        {
            var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            return Ok(await _friendService.GetMyFriendsAsync(userId));
        }

        // Đổi Guid thành int cho requestId
        [HttpPost("accept/{requestId}")]
        public async Task<IActionResult> Accept(int requestId)
        {
            var result = await _friendService.AcceptFriendRequestAsync(requestId);
            return result ? Ok(new { message = "Đã trở thành bạn bè" }) : BadRequest("Lỗi chấp nhận kết bạn");
        }

        // Bổ sung Decline (Từ chối/Gỡ lời mời)
        [HttpDelete("decline/{requestId}")]
        public async Task<IActionResult> Decline(int requestId)
        {
            var result = await _friendService.DeclineFriendRequestAsync(requestId);
            return result ? Ok(new { message = "Đã gỡ lời mời" }) : BadRequest("Không tìm thấy lời mời");
        }

        [HttpDelete("unfriend/{friendId}")]
        public async Task<IActionResult> Unfriend(Guid friendId)
        {
            var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var result = await _friendService.UnfriendAsync(userId, friendId);
            return result ? Ok(new { message = "Đã hủy kết bạn" }) : BadRequest("Không thể hủy kết bạn");
        }
    }
}