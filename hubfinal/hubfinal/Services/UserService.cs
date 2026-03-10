using hubfinal.Data;
using hubfinal.DTOs;
using hubfinal.DTOs.User;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace hubfinal.Services
{
    public class UserService
    {
        private readonly AppDbContext _context;
        private readonly IWebHostEnvironment _env;

        public UserService(AppDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        public async Task<UserResponse?> GetCurrentUserDtoAsync(Guid userId)
        {
            // 1. Lấy thông tin User cơ bản
            var user = await _context.Users
                .AsNoTracking()
                .Include(u => u.Posts)
                .Include(u => u.GroupMembers)
                .FirstOrDefaultAsync(x => x.Id == userId);

            if (user == null) return null;

      
            var friendCount = await _context.Friends
                .CountAsync(f => f.UserId == userId || f.FriendId == userId);

            return new UserResponse
            {
                Id = user.Id,
                Username = user.Username,
                DisplayName = user.DisplayName ?? user.Username,
                AvatarUrl = user.AvatarUrl,
                Bio = user.Bio,
                StudentCode = user.StudentCode,

                PostCount = user.Posts?.Count ?? 0,
                GroupCount = user.GroupMembers?.Count ?? 0,

                // Gán con số tổng hợp vào đây
                FriendCount = friendCount,

                Posts = user.Posts?.Select(p => new PostThumbnailDto
                {
                    Id = p.Id,
                    ImageUrl = p.ImageUrl
                }).ToList() ?? new List<PostThumbnailDto>()
            };
        }

        public async Task<bool> UpdateProfileAsync(Guid userId, UpdateProfileRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Id == userId);

            if (user == null) return false;

            if (!string.IsNullOrEmpty(request.DisplayName))
                user.DisplayName = request.DisplayName;

            if (!string.IsNullOrEmpty(request.Bio))
                user.Bio = request.Bio;

            await _context.SaveChangesAsync();
            return true;
        }
        public async Task<string?> UpdateAvatarAsync(Guid userId, IFormFile file)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Id == userId);

            if (user == null) return null;

            // Kiểm tra và lấy đường dẫn thư mục wwwroot
            // Nếu chạy trong môi trường dev, WebRootPath có thể null, ta lấy thư mục hiện tại ghép với wwwroot
            var rootPath = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

            var uploadsFolder = Path.Combine(rootPath, "uploads", "avatars");

            // Tạo thư mục nếu chưa tồn tại
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            // Tạo tên file duy nhất để tránh trùng lặp
            var fileName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
            var filePath = Path.Combine(uploadsFolder, fileName);

            // Lưu file vật lý vào server
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Lưu đường dẫn tương đối (để Flutter có thể ghép với Server URL)
            // Ví dụ: /uploads/avatars/abc-123.jpg
            var relativePath = $"/uploads/avatars/{fileName}";

            user.AvatarUrl = relativePath;
            await _context.SaveChangesAsync();

            return relativePath;
        }

    }
}