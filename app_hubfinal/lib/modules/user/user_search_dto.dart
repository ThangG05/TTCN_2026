class UserSearchDto {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isFriend;
  final bool hasSentRequest;

  UserSearchDto({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.isFriend,
    required this.hasSentRequest,
  });

  factory UserSearchDto.fromJson(Map<String, dynamic> json) {
    return UserSearchDto(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? 'Người dùng Hub',
      avatarUrl: json['avatarUrl'],
      isFriend: json['isFriend'] ?? false,
      hasSentRequest: json['hasSentRequest'] ?? false,
    );
  }
}