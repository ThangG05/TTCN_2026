using Microsoft.AspNetCore.Http;
namespace hubfinal.DTOs.User
{
    public class UpdateAvatarRequest
    {
        public IFormFile File { get; set; }
    }
}
