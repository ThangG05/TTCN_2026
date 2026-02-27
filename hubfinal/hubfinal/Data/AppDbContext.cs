using hubfinal.Entities;
using Microsoft.EntityFrameworkCore;

namespace hubfinal.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Role> Roles { get; set; }
    public DbSet<UserRole> UserRoles { get; set; }
    public DbSet<OtpCode> OtpCodes { get; set; }
    public DbSet<Group> Groups { get; set; }
    public DbSet<GroupMember> GroupMembers { get; set; }
    public DbSet<Post> Posts { get; set; }
    public DbSet<PostMedia> PostMedia { get; set; }
    public DbSet<PostLike> PostLikes { get; set; }
    public DbSet<Comment> Comments { get; set; }
    public DbSet<FriendRequest> FriendRequests { get; set; }
    public DbSet<Friend> Friends { get; set; }
    public DbSet<Report> Reports { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<UserRole>().HasKey(x => new { x.UserId, x.RoleId });
        modelBuilder.Entity<GroupMember>().HasKey(x => new { x.GroupId, x.UserId });
        modelBuilder.Entity<PostLike>().HasKey(x => new { x.PostId, x.UserId });

        // --- CẤU HÌNH BẢNG FRIENDS (SỬA LỖI UserId1) ---
        // 1. Cấu hình bảng Friends (Xử lý lỗi UserId1)
        modelBuilder.Entity<Friend>(entity =>
        {
            entity.HasKey(x => new { x.UserId, x.FriendId });

            entity.HasOne(f => f.User)
                  .WithMany(u => u.Friends) // Chỉ định rõ u.Friends để EF không tự tạo UserId1
                  .HasForeignKey(f => f.UserId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(f => f.FriendUser)
                  .WithMany()
                  .HasForeignKey(f => f.FriendId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // 2. Cấu hình bảng FriendRequests
        modelBuilder.Entity<FriendRequest>(entity =>
        {
            entity.HasKey(x => x.Id);

            entity.HasOne(fr => fr.Sender)
                  .WithMany()
                  .HasForeignKey(fr => fr.SenderId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(fr => fr.Receiver)
                  .WithMany()
                  .HasForeignKey(fr => fr.ReceiverId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Username).IsUnique();
            entity.HasIndex(u => u.Email).IsUnique();
        });
    }
}