namespace hubfinal.DTOs.Friend
{
    public class FriendRequestResponse
    {
        public Guid RequestId { get; set; } 
        public Guid SenderId { get; set; }
        public string SenderName { get; set; } = string.Empty;
        public string? SenderAvatar { get; set; }
    }
}
