import '../../core/config/app_config.dart';
import '../../utils/img_helper.dart';

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
    return FriendModel(
      id: json['id'].toString(),
      displayName: json['displayName'] ?? 'Thành viên Hub',
      bio: json['bio'] ?? 'Thành viên Hub',
      // Gọi hàm dùng chung thay vì viết logic if/else tại đây
      avatarUrl: ImageHelper.formatImageUrl(json['avatarUrl']),
      subtitle: json['subtitle'] ?? 'Sinh viên Học viện Ngân hàng',
    );
  }
}