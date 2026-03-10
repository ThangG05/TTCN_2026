namespace hubfinal.Entities;

public class FriendRequest
{
    // Sửa Guid thành int để khớp với DB
    public int Id { get; set; }

    public Guid SenderId { get; set; }
    public virtual User Sender { get; set; } = null!;

    public Guid ReceiverId { get; set; }
    public virtual User Receiver { get; set; } = null!;

    // Sửa int thành string vì DB đang để nvarchar(20)
    public string Status { get; set; } = "0";

    public DateTime CreatedAt { get; set; } = DateTime.Now;
}