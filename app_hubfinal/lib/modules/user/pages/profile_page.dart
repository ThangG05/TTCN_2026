import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_hubfinal/core/config/app_config.dart';
import 'package:app_hubfinal/modules/friend/pages/friend_list_page.dart';
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
    // Sử dụng microtask để tránh lỗi notify khi đang build
    Future.microtask(() => context.read<UserProvider>().loadMe());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    // 🔵 TRƯỜNG HỢP 1: ĐANG TẢI DỮ LIỆU
    if (provider.isLoading && provider.userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
      );
    }

    final user = provider.userData;

    // 🔵 TRƯỜNG HỢP 2: LỖI HOẶC KHÔNG CÓ DỮ LIỆU
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
              const SizedBox(height: 15),
              const Text("Không thể tải thông tin cá nhân",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => provider.loadMe(),
                child: const Text("Thử lại"),
              ),
            ],
          ),
        ),
      );
    }

    // 🔵 TRƯỜNG HỢP 3: CÓ DỮ LIỆU - HIỂN THỊ GIAO DIỆN
    final avatarUrl = user['avatarUrl'];
    ImageProvider? avatarImage;
    if (avatarUrl != null && avatarUrl.toString().isNotEmpty) {
      avatarImage = NetworkImage("${AppConfig.serverUrl}$avatarUrl");
    }

    final List<dynamic> posts = user['posts'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Trang cá nhân",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadMe(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user, avatarImage),
              _buildBio(user),
              _buildEditButton(context),
              const SizedBox(height: 25),
              _buildStats(context, user),
              const SizedBox(height: 25),
              _buildPostsGrid(posts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> user, ImageProvider? avatarImage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            backgroundImage: avatarImage,
            child: avatarImage == null ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['displayName'] ?? user['username'] ?? "N/A",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(user['studentCode'] ?? "",
                  style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBio(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(user['bio'] ?? "Chưa có tiểu sử", style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          child: const Text("Chỉnh sửa trang cá nhân", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, Map<String, dynamic> user) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(user['postCount']?.toString() ?? "0", "Bài đăng"),
          const VerticalDivider(color: Colors.grey),
          _buildStatItem(
            user['friendCount']?.toString() ?? "0",
            "Bạn bè",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => FriendListPage(user: user))),
          ),
          const VerticalDivider(color: Colors.grey),
          _buildStatItem(user['groupCount']?.toString() ?? "0", "Nhóm"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(List<dynamic> posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        posts.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Chưa có bài đăng nào")))
            : GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final imageUrl = posts[index]['imageUrl'];
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: imageUrl != null ? DecorationImage(
                    image: NetworkImage("${AppConfig.serverUrl}$imageUrl"), fit: BoxFit.cover) : null,
              ),
            );
          },
        ),
      ],
    );
  }
}