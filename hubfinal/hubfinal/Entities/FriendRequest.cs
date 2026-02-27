namespace hubfinal.Entities;

public class FriendRequest
{
    public Guid Id { get; set; }

    public Guid SenderId { get; set; }
    // Thêm dòng này để hết lỗi 'fr.Sender'
    public virtual User Sender { get; set; } = null!;

    public Guid ReceiverId { get; set; }
    // Thêm dòng này để hết lỗi 'fr.Receiver'
    public virtual User Receiver { get; set; } = null!;

    public int Status { get; set; } // 0: Pending, 1: Accepted, 2: Declined
    public DateTime CreatedAt { get; set; } = DateTime.Now;
}