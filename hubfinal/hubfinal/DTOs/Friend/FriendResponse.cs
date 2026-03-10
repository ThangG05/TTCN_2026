namespace hubfinal.DTOs.Friend
{
    public class FriendResponse
    {
        public Guid Id { get; set; } 
        public string DisplayName { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        public string? Subtitle { get; set; } 
    }
}
