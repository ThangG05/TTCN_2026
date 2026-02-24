class UserModel {
  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? studentCode;
  final String? avatarUrl;
  final String? bio;
  final bool isEmailVerified;
  final bool isLocked;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.studentCode,
    this.avatarUrl,
    this.bio,
    required this.isEmailVerified,
    required this.isLocked,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['displayName'],
      studentCode: json['studentCode'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      isEmailVerified: json['isEmailVerified'],
      isLocked: json['isLocked'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
