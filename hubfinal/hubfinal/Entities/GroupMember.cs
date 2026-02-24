namespace hubfinal.Entities;

public class GroupMember
{
    public int GroupId { get; set; }
    public Guid UserId { get; set; }
    public string Role { get; set; }
    public DateTime JoinedAt { get; set; }
}
