import '../../core/config/app_config.dart';

class UserSearchDto {
  final String id;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final bool isFriend;
  final bool hasSentRequest;
  final bool isIncomingRequest;

  UserSearchDto({
    required this.id,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
    required this.isFriend,
    required this.hasSentRequest,
    required this.isIncomingRequest,
  });

  factory UserSearchDto.fromJson(Map<String, dynamic> json) {
    String? avatar = json['avatarUrl'];

    // Xử lý logic nối URL ảnh:
    // Nếu có avatar và đường dẫn là tương đối (bắt đầu bằng /)
    // thì nối thêm Server URL vào đầu.
    if (avatar != null && avatar.isNotEmpty && avatar.startsWith('/')) {
      avatar = "${AppConfig.serverUrl}$avatar";
    }

    return UserSearchDto(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? 'Sinh viên Học viện Ngân hàng',
      bio: json['bio'] ?? 'Sinh viên Học viện Ngân hàng',
      avatarUrl: avatar,
      isFriend: json['isFriend'] ?? false,
      hasSentRequest: json['hasSentRequest'] ?? false,
      isIncomingRequest: json['isIncomingRequest'] ?? false,
    );
  }
}