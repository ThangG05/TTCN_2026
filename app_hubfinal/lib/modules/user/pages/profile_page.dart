import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_hubfinal/core/config/app_config.dart'; // Đảm bảo import cái này
import '../user_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProvider>().loadMe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = provider.userData;
    if (user == null) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    // 🔥 SỬA LOGIC HIỂN THỊ ẢNH Ở ĐÂY
    final avatarUrl = user['avatarUrl'];
    ImageProvider? avatarImage;

    if (avatarUrl != null && avatarUrl.toString().isNotEmpty) {
      // Ghép serverUrl với path từ database
      // Thêm timestamp để khi vừa đổi ảnh xong quay lại trang này nó cập nhật ngay
      final fullUrl = "${AppConfig.serverUrl}$avatarUrl?v=${DateTime.now().millisecondsSinceEpoch}";
      avatarImage = NetworkImage(fullUrl);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Trang cá nhân"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔵 HEADER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: avatarImage,
                    onBackgroundImageError: (e, s) => debugPrint("Lỗi load ảnh Profile: $e"),
                    child: avatarImage == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user['displayName'] ?? user['username'] ?? "N/A",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['studentCode'] ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user['bio'] ?? "Chưa có tiểu sử",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        // Đợi khi quay về từ trang Edit
                        await Navigator.pushNamed(context, '/edit-profile');
                        // Tải lại dữ liệu mới nhất (bao gồm avatarUrl mới)
                        if (mounted) {
                          context.read<UserProvider>().loadMe();
                        }
                      },
                      child: const Text("Chỉnh sửa trang cá nhân", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ... (Phần Stats và Posts giữ nguyên như cũ)
          ],
        ),
      ),
    );
  }
}