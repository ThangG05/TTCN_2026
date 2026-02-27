namespace hubfinal.Entities;

public class Friend
{
    public Guid UserId { get; set; }
    public virtual User User { get; set; } = null!;

    public Guid FriendId { get; set; }

    public virtual User FriendUser { get; set; } = null!;
}