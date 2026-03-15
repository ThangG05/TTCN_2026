import '../../utils/img_helper.dart';

class ChatRoomModel {
  final String id; // RoomId
  final String? lastMessage;
  final DateTime? lastTime;
  final bool isRead;
  final OtherUserInfo otherUser;

  ChatRoomModel({
    required this.id,
    this.lastMessage,
    this.lastTime,
    required this.isRead,
    required this.otherUser
  });
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    var chat = json['chatRoom'] ?? json['lastChat'];
    return ChatRoomModel(
      id: chat != null ? chat['id'].toString() : "",
      lastMessage: chat != null ? chat['lastMessage'] : "Bắt đầu trò chuyện",
      lastTime: (chat != null && chat['lastTime'] != null)
          ? DateTime.parse(chat['lastTime'])
          : null,
      isRead: chat != null ? (chat['isRead'] ?? true) : true,
      otherUser: OtherUserInfo.fromJson(json['otherUser'] ?? {}),
    );
  }
}
class OtherUserInfo {
  final String id;
  final String displayName;
  final String? avatarUrl;

  OtherUserInfo({
    required this.id,
    required this.displayName,
    this.avatarUrl
  });

  factory OtherUserInfo.fromJson(Map<String, dynamic> json) {
    return OtherUserInfo(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName'] ?? "Người dùng",
      avatarUrl: ImageHelper.formatImageUrl(json['avatarUrl']),
    );
  }
}
class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.createdAt
  });
  factory MessageModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    DateTime parsedDate;
    var rawDate = json['createdAt'];

    if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else {
      // Trường hợp dự phòng nếu ngày tháng bị null hoặc sai định dạng
      parsedDate = DateTime.now();
    }

    return MessageModel(
      // docId được truyền từ doc.id của Firebase Firestore
      id: docId ?? json['id']?.toString() ?? '',
      chatRoomId: json['chatRoomId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      content: json['content'] ?? '',
      createdAt: parsedDate,
    );
  }

  /// Helper để chuyển sang Map nếu cần lưu ngược lại hoặc debug
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}