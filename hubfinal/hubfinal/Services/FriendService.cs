using hubfinal.Data;
using hubfinal.DTOs.Friend;
using hubfinal.Entities;
using Microsoft.EntityFrameworkCore;

namespace hubfinal.Services
{
    public class FriendService
    {
        private readonly AppDbContext _context;
        public FriendService(AppDbContext context) => _context = context;

        public async Task<List<FriendResponse>> GetMyFriendsAsync(Guid userId)
        {
            
            var friendships = await _context.Friends
                .Include(f => f.User)
                .Include(f => f.FriendUser)
                .Where(f => f.UserId == userId || f.FriendId == userId)
                .ToListAsync();

            
            return friendships.Select(f =>
            {
                var isMeSender = f.UserId == userId;
                var friendData = isMeSender ? f.FriendUser : f.User;

                return new FriendResponse
                {
                    Id = friendData.Id,
                    DisplayName = friendData.DisplayName ?? "Thành viên bav",
                    AvatarUrl = friendData.AvatarUrl,
                    Subtitle = friendData.Bio,
                };
            }).ToList();
        }

        public async Task<bool> AcceptFriendRequestAsync(int requestId)
        {
            // Tìm yêu cầu dựa trên Id (int)
            var request = await _context.FriendRequests.FindAsync(requestId);

            // Nếu không tìm thấy hoặc yêu cầu đã được xử lý (Status != "0")
            if (request == null || request.Status != "0") return false;

            // Thêm vào bảng Friends để xác nhận quan hệ bạn bè
            var friendship = new Friend
            {
                UserId = request.SenderId,
                FriendId = request.ReceiverId
            };

            _context.Friends.Add(friendship);

            // QUAN TRỌNG: Xóa yêu cầu khỏi bảng FriendRequests sau khi chấp nhận để dọn dẹp DB
            _context.FriendRequests.Remove(request);

            await _context.SaveChangesAsync();
            return true;
        }

        // 3. Từ chối hoặc Gỡ lời mời kết bạn (Bổ sung mới)
        public async Task<bool> DeclineFriendRequestAsync(int requestId)
        {
            var request = await _context.FriendRequests.FindAsync(requestId);
            if (request == null) return false;

            _context.FriendRequests.Remove(request);
            await _context.SaveChangesAsync();
            return true;
        }

        // 4. Hủy kết bạn
        public async Task<bool> UnfriendAsync(Guid userId, Guid friendId)
        {
            var friend = await _context.Friends.FirstOrDefaultAsync(f =>
                (f.UserId == userId && f.FriendId == friendId) ||
                (f.UserId == friendId && f.FriendId == userId));

            if (friend == null) return false;

            _context.Friends.Remove(friend);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}