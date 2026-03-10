import '../../core/config/app_config.dart';

class FriendModel {
  final String id;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final String subtitle;

  FriendModel({
    required this.id,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
    required this.subtitle,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    // Debug: Xem dữ liệu thực tế từ Server
    print("Đang parse friend: $json");

    String? avatar = json['avatarUrl'];

    // Xử lý logic nối URL ảnh giống UserSearchDto:
    if (avatar != null && avatar.isNotEmpty && avatar.startsWith('/')) {
      avatar = "${AppConfig.serverUrl}$avatar";
    }

    return FriendModel(
      id: json['id'].toString(), // Ép kiểu string để tránh lỗi Guid/Int
      displayName: json['displayName'] ?? 'Thành viên Hub',
      bio: json['bio'] ?? 'Thành viên Hub',
      avatarUrl: avatar, // Đã được nối ServerUrl nếu cần
      subtitle: json['subtitle'] ?? 'Sinh viên Học viện Ngân hàng',
    );
  }
}