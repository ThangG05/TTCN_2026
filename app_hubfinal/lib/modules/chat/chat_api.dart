import '../../core/api/api_client.dart';
import 'chat_model.dart';

class ChatApi {
  /// 1. Lấy danh sách bạn bè đã kết bạn (Status = "1") và tin nhắn cuối cùng
  static Future<List<ChatRoomModel>> getFriendsToChat() async {
    try {
      final res = await ApiClient.dio.get('/chat/friends-chat');
      if (res.statusCode == 200) {
        final List data = res.data;
        return data.map((json) => ChatRoomModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Lỗi API getFriendsToChat: $e");
      return [];
    }
  }

  /// 2. Lấy lịch sử tin nhắn của một phòng chat cụ thể (từ SQL Server)
  static Future<List<MessageModel>> getMessages(String roomId) async {
    try {
      if (roomId.isEmpty) return [];
      final res = await ApiClient.dio.get('/chat/messages/$roomId');
      if (res.statusCode == 200) {
        final List data = res.data;
        return data.map((json) => MessageModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Lỗi API getMessages: $e");
      return [];
    }
  }
  static Future<String?> getOrCreateRoomId(String friendId) async {
    try {
      // Giả sử bạn đã viết endpoint này ở ChatController.cs
      // Nó nhận vào friendId và trả về roomId (Guid)
      final res = await ApiClient.dio.post('/chat/get-or-create-room/$friendId');

      if (res.statusCode == 200) {
        // Giả sử server trả về: { "roomId": "..." }
        return res.data['roomId'].toString();
      }
      return null;
    } catch (e) {
      print("Lỗi API getOrCreateRoomId: $e");
      return null;
    }
  }
  /// 3. HÀM MỚI: Đồng bộ tin nhắn từ Firebase về SQL Server
  /// Gọi sau khi đã push tin nhắn lên Firebase thành công
  static Future<bool> syncMessageToSql({
    required String roomId,
    required String senderId,
    required String content,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        '/chat/sync-message',
        data: {
          'roomId': roomId,
          'senderId': senderId,
          'content': content,
        },
      );

      // Nếu Backend trả về Ok (200)
      return res.statusCode == 200;
    } catch (e) {
      print("Lỗi API syncMessageToSql: $e");
      return false;
    }
  }
}