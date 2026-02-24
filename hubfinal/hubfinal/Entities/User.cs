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
}
