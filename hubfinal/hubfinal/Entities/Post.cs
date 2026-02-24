namespace hubfinal.Entities;

public class Post
{
    public Guid Id { get; set; }
    public int GroupId { get; set; }
    public Guid UserId { get; set; }
    public string Content { get; set; }
    public string Status { get; set; }
    public DateTime CreatedAt { get; set; }
}
