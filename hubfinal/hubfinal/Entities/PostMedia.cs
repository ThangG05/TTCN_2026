namespace hubfinal.Entities;

public class PostMedia
{
    public int Id { get; set; }
    public Guid PostId { get; set; }
    public string MediaUrl { get; set; }
    public string MediaType { get; set; }
}
