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
}

