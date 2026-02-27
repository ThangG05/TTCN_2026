class FriendModel {
  final String id; // Guid từ C# sang Dart là String
  final String displayName;
  final String? avatarUrl;
  final String subtitle;

  FriendModel({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.subtitle,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? 'Người dùng Hub',
      avatarUrl: json['avatarUrl'],
      subtitle: json['subtitle'] ?? '',
    );
  }
}