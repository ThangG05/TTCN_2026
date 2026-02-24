namespace hubfinal.Entities;

public class FriendRequest
{
    public int Id { get; set; }
    public Guid SenderId { get; set; }
    public Guid ReceiverId { get; set; }
    public string Status { get; set; }
    public DateTime CreatedAt { get; set; }
}
