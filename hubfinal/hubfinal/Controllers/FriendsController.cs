using hubfinal.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
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

        [HttpPost("accept/{requestId}")]
        public async Task<IActionResult> Accept(Guid requestId)
        {
            var result = await _friendService.AcceptFriendRequestAsync(requestId);
            return result ? Ok() : BadRequest("Lỗi chấp nhận kết bạn");
        }

        [HttpDelete("unfriend/{friendId}")]
        public async Task<IActionResult> Unfriend(Guid friendId)
        {
            var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var result = await _friendService.UnfriendAsync(userId, friendId);
            return result ? Ok() : BadRequest("Không thể hủy kết bạn");
        }
    }
}
