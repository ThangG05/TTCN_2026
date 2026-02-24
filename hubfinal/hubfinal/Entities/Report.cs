namespace hubfinal.Entities;

public class Report
{
    public int Id { get; set; }
    public Guid ReporterId { get; set; }
    public string TargetType { get; set; }
    public Guid TargetId { get; set; }
    public string Reason { get; set; }
    public string Status { get; set; }
    public DateTime CreatedAt { get; set; }
}
