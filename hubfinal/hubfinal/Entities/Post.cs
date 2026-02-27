namespace hubfinal.Entities;

public class Post
{
    public Guid Id { get; set; }
    public int GroupId { get; set; }
    public Guid UserId { get; set; }
    public string Content { get; set; }
    public string Status { get; set; }
    public string? ImageUrl { get; set; } // Thêm cột này để lưu đường dẫn ảnh bài đăng
    public DateTime CreatedAt { get; set; }
    public virtual User User { get; set; } = null!;
}