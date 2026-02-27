
namespace hubfinal.DTOs;

public class UserResponse
{
    public Guid Id { get; set; }
    public string Email { get; set; }
    public string Username { get; set; }
    public string? DisplayName { get; set; }
    public string? StudentCode { get; set; }
    public string? AvatarUrl { get; set; }
    public string? Bio { get; set; }
    public List<string> Roles { get; set; }

    // Thêm các trường này
    public int PostCount { get; set; }
    public int FriendCount { get; set; }
    public int GroupCount { get; set; }
    public List<PostThumbnailDto> Posts { get; set; } = new();
}

public class PostThumbnailDto
{
    public Guid Id { get; set; }
    public string? ImageUrl { get; set; }
}

