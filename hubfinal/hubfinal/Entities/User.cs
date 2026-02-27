namespace hubfinal.Entities;

public class User
{
    public Guid Id { get; set; }
    public string Email { get; set; }
    public string Username { get; set; }
    public string? DisplayName { get; set; }
    public string? StudentCode { get; set; }
    public string PasswordHash { get; set; }
    public string? AvatarUrl { get; set; }
    public string? Bio { get; set; }
    public bool IsEmailVerified { get; set; }
    public bool IsLocked { get; set; }
    public DateTime CreatedAt { get; set; }
    public ICollection<UserRole> UserRoles { get; set; }
    public virtual ICollection<Post> Posts { get; set; } = new List<Post>();

    // Giả sử bạn có bảng Friend và GroupMember, hãy thêm vào nếu đã tạo Entity
    public virtual ICollection<Friend> Friends { get; set; } = new List<Friend>();
    public virtual ICollection<GroupMember> GroupMembers { get; set; } = new List<GroupMember>();
}
