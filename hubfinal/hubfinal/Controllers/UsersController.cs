using hubfinal.DTOs.User;
using hubfinal.Helpers;
using hubfinal.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
namespace hubfinal.Controllers
{
    [ApiController]
    [Route("api/users")]
    public class UsersController : ControllerBase
    {
        private readonly UserService _userService;
        private readonly CurrentUser _currentUser;

        public UsersController(UserService userService, CurrentUser currentUser)
        {
            _userService = userService;
            _currentUser = currentUser;
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            var user = await _userService.GetCurrentUserAsync(_currentUser.UserId);
            if (user == null) return Unauthorized();

            return Ok(user);
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
    }
}