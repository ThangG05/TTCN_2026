import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../chat_provider.dart';
import 'chat_detail_page.dart';
import '../chat_api.dart'; // Đảm bảo import Api để gọi tạo phòng nếu cần

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();

      // Không cần initConnection (Socket) nữa vì ta dùng Firebase
      // Nhưng bạn có thể giữ nếu dùng để khởi tạo Firebase
      chatProvider.initConnection();

      // Tải danh sách phòng từ SQL Server (ASP.NET)
      chatProvider.fetchRooms();
    });
  }

  /// Hàm xử lý khi nhấn vào một người bạn
  Future<void> _handleRoomTap(dynamic room) async {
    String finalRoomId = room.id;

    // TRƯỜNG HỢP LẦN ĐẦU CHAT: roomId rỗng
    if (finalRoomId.isEmpty) {
      // Hiển thị loading nhẹ trong lúc tạo phòng
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Giả sử bạn có hàm này trong ChatApi hoặc ChatService bên Backend
        // Bạn truyền vào myId và friendId để lấy RoomId từ SQL
        // Ở đây tôi giả định bạn gọi API GetOrCreateRoom
        // finalRoomId = await ChatApi.getOrCreateRoomId(room.otherUser.id);

        // Sau khi có ID, hãy cập nhật lại danh sách phòng
        await context.read<ChatProvider>().fetchRooms();

        if (mounted) Navigator.pop(context); // Tắt loading
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể khởi tạo phòng chat")),
          );
        }
        return;
      }
    }

    // Chuyển sang trang chi tiết
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            roomId: finalRoomId,
            receiverId: room.otherUser.id,
            receiverName: room.otherUser.displayName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.rooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.rooms.isEmpty) {
            return const Center(child: Text("Chưa có bạn bè nào trong danh sách."));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchRooms(),
            child: ListView.separated(
              itemCount: provider.rooms.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final room = provider.rooms[index];
                final otherUser = room.otherUser;

                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: otherUser.avatarUrl != null
                        ? NetworkImage(otherUser.avatarUrl!)
                        : null,
                    child: otherUser.avatarUrl == null
                        ? Text(otherUser.displayName[0].toUpperCase())
                        : null,
                  ),
                  title: Text(
                    otherUser.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    room.lastMessage ?? "Bắt đầu cuộc trò chuyện...",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: room.lastMessage == "Bắt đầu cuộc trò chuyện" ? Colors.grey : Colors.black54,
                    ),
                  ),
                  trailing: room.lastTime != null
                      ? Text(
                    DateFormat('HH:mm').format(room.lastTime!),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  )
                      : null,
                  onTap: () => _handleRoomTap(room),
                );
              },
            ),
          );
        },
      ),
    );
  }
}