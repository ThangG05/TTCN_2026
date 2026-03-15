import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../core/storage/token_storage.dart';
import '../chat_provider.dart';
import '../chat_model.dart';

class ChatDetailPage extends StatefulWidget {
  final String roomId;
  final String receiverId;
  final String receiverName;

  const ChatDetailPage({
    super.key,
    required this.roomId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  String? myId;

  @override
  void initState() {
    super.initState();
    _loadMyIdAndInitChat();
  }

  /// Hàm khởi tạo: Lấy ID của mình và bắt đầu lắng nghe tin nhắn
  Future<void> _loadMyIdAndInitChat() async {
    // 1. Lấy Token và giải mã để lấy UserId (Sub claim)
    final token = await TokenStorage.get();
    if (token != null) {
      // Decode JWT đơn giản để lấy ID người dùng hiện tại
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        final Map<String, dynamic> data = jsonDecode(payload);
        setState(() {
          // Tùy vào Backend bạn đặt là 'sub' hoặc 'nameid'
          myId = data['sub'] ?? data['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
        });
      }
    }

    // 2. Tải lịch sử và bắt đầu nghe Firebase Realtime
    if (mounted) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.fetchMessages(widget.roomId); // Lấy từ SQL
      if (widget.roomId.isNotEmpty) {
        chatProvider.listenToMessages(widget.roomId); // Nghe từ Firebase
      }
    }
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && myId != null) {
      context.read<ChatProvider>().sendMessage(
        roomId: widget.roomId,
        senderId: myId!,
        receiverId: widget.receiverId,
        content: text,
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch để UI tự update khi có tin nhắn mới từ Firebase
    final messages = context.watch<ChatProvider>().messages;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: myId == null
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(child: Text("Hãy bắt đầu trò chuyện!"))
                : ListView.builder(
              reverse: true, // Quan trọng: Tin nhắn mới ở dưới cùng
              padding: const EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final MessageModel msg = messages[index];
                // Kiểm tra nếu senderId trùng với ID của mình
                final bool isMe = msg.senderId == myId;

                return _buildMessageBubble(msg.content, isMe);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isMe ? 15 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 15),
          ),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _onSend(),
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _onSend,
            child: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}