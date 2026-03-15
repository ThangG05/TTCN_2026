import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/storage/token_storage.dart';
import 'chat_api.dart';
import 'chat_model.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ChatRoomModel> rooms = [];
  List<MessageModel> messages = [];
  bool isLoading = false;

  // 1. Thay thế initConnection (Không cần kết nối Socket nữa)
  // Bạn có thể dùng hàm này để khởi tạo các cấu hình cần thiết của Firebase nếu muốn
  Future<void> initConnection() async {
    debugPrint("==> ChatProvider: Firebase đã sẵn sàng (Thay thế SignalR)");
  }

  // 2. Lắng nghe tin nhắn Realtime từ Firebase
  // Thay vì chờ Socket đẩy về, ta dùng Stream của Firestore
  void listenToMessages(String roomId) {
    if (roomId.isEmpty) return;

    _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {

      messages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;


        return MessageModel.fromJson(data, doc.id);
      }).toList();

      notifyListeners();
    });
  }

  // 3. Hàm gửi tin nhắn mới (Đã fix lỗi Empty RoomId)
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    if (content.isEmpty) return;

    String activeRoomId = roomId;

    try {
      // --- KIỂM TRA VÀ TẠO ROOM NẾU TRỐNG ---
      if (activeRoomId.isEmpty) {
        debugPrint("==> RoomId rỗng. Đang tạo phòng chat mới tại SQL Server...");

        // Gọi API để lấy hoặc tạo RoomId từ SQL Server
        // Bạn cần bổ sung hàm getOrCreateRoomId trong ChatApi
        final newId = await ChatApi.getOrCreateRoomId(receiverId);

        if (newId != null && newId.isNotEmpty) {
          activeRoomId = newId;
          debugPrint("==> Đã tạo RoomId mới: $activeRoomId");
        } else {
          throw Exception("Không thể khởi tạo RoomId từ Server.");
        }
      }

      final timestamp = DateTime.now().toIso8601String();

      // Bước A: Đẩy lên Firebase (Sử dụng activeRoomId đã được đảm bảo không rỗng)
      await _firestore
          .collection('chat_rooms')
          .doc(activeRoomId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'createdAt': timestamp,
      });

      // Bước B: Gọi API ASP.NET để đồng bộ vào SQL Server
      await ChatApi.syncMessageToSql(
        roomId: activeRoomId,
        senderId: senderId,
        content: content,
      );

      // Cập nhật lại danh sách phòng để hiển thị tin nhắn cuối cùng ở trang chủ
      fetchRooms();

    } catch (e) {
      debugPrint("==> ChatProvider Error (Gửi tin): $e");
      // Có thể thông báo cho người dùng qua UI nếu cần
    }
  }

  // 4. Lấy danh sách phòng chat (Lấy từ SQL Server qua API ASP.NET)
  Future<void> fetchRooms() async {
    isLoading = true;
    notifyListeners();
    try {
      rooms = await ChatApi.getFriendsToChat();
    } catch (e) {
      debugPrint("==> ChatProvider Error (Fetch Rooms): $e");
    }
    isLoading = false;
    notifyListeners();
  }

  // 5. Lấy lịch sử tin nhắn (Vẫn có thể dùng API cũ để lấy tin từ SQL)
  Future<void> fetchMessages(String roomId) async {
    if (roomId.isEmpty) {
      messages = [];
    } else {
      try {
        messages = await ChatApi.getMessages(roomId);
        // Sau khi lấy lịch sử xong, bắt đầu nghe Realtime từ Firebase
        listenToMessages(roomId);
      } catch (e) {
        debugPrint("==> ChatProvider Error (Fetch Messages): $e");
        messages = [];
      }
    }
    notifyListeners();
  }
}