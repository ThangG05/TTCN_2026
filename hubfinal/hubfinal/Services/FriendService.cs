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

        // 1. Lấy danh sách bạn bè (Từ bảng Friends)
        public async Task<List<FriendResponse>> GetMyFriendsAsync(Guid userId)
        {
            return await _context.Friends
                .Where(f => f.UserId == userId || f.FriendId == userId)
                .Select(f => new FriendResponse
                {
                    Id = f.UserId == userId ? f.FriendId : f.UserId,
                    DisplayName = f.UserId == userId ? f.FriendUser.DisplayName : f.User.DisplayName,
                    AvatarUrl = f.UserId == userId ? f.FriendUser.AvatarUrl : f.User.AvatarUrl,
                    Subtitle = "Bạn bè"
                }).ToListAsync();
        }

        // 2. Chấp nhận kết bạn (Chuyển từ FriendRequests sang Friends)
        public async Task<bool> AcceptFriendRequestAsync(Guid requestId)
        {
            var request = await _context.FriendRequests.FindAsync(requestId);
            if (request == null) return false;

            // Thêm vào bảng Friends
            var friendship = new Friend
            {
                UserId = request.SenderId,
                FriendId = request.ReceiverId
            };
            _context.Friends.Add(friendship);

            // Xóa hoặc cập nhật status trong bảng FriendRequests
            _context.FriendRequests.Remove(request);

            await _context.SaveChangesAsync();
            return true;
        }

        // 3. Hủy kết bạn (Xóa khỏi bảng Friends)
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
