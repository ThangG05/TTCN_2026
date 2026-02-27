import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_hubfinal/core/config/app_config.dart';

// Import Providers
import '../friend_provider.dart';
import '../../user/user_provider.dart';

// Import Models
import '../friend_model.dart';
import '../../user/user_search_dto.dart';

// Import Widgets
import '../widgets/friend_card.dart';

class FriendListPage extends StatefulWidget {
  final Map<String, dynamic> user; // Nhận từ ProfilePage
  const FriendListPage({super.key, required this.user});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 3 Tab: Bạn bè, Lời mời, Tìm bạn
    _tabController = TabController(length: 3, vsync: this);

    // Load danh sách bạn bè hiện tại (Tab 1)
    Future.microtask(() => context.read<FriendProvider>().loadFriends());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendProvider = context.watch<FriendProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mạng lưới Hub",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Header người dùng
          _buildUserHeader(),

          // 2. TabBar điều hướng
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue[800],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue[800],
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Bạn bè"),
              Tab(text: "Lời mời"),
              Tab(text: "Tìm bạn mới"),
            ],
          ),

          // 3. Nội dung các Tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendListTab(friendProvider), // Tab 1
                const Center(child: Text("Danh sách lời mời trống")), // Tab 2
                _buildSearchTab(), // Tab 3 (Tìm kiếm tích hợp)
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CÁC TAB ---

  // Tab 1: Danh sách bạn bè chính thức
  Widget _buildFriendListTab(FriendProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.friends.isEmpty) {
      return const Center(child: Text("Bạn chưa có người bạn nào", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: provider.friends.length,
      itemBuilder: (context, index) => FriendCard(
        friend: provider.friends[index],
        onUnfriend: () => _showUnfriendConfirm(provider.friends[index]),
      ),
    );
  }

  // Tab 3: Tìm kiếm người dùng mới
  Widget _buildSearchTab() {
    final userProvider = context.watch<UserProvider>();

    return Column(
      children: [
        // Thanh Search
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => context.read<UserProvider>().searchUsers(value),
            decoration: InputDecoration(
              hintText: "Nhập tên hiển thị sinh viên...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Kết quả tìm kiếm
        Expanded(
          child: userProvider.isSearching
              ? const Center(child: CircularProgressIndicator())
              : userProvider.searchResults.isEmpty
              ? const Center(child: Text("Tìm bạn bè để cùng học tập nào!"))
              : ListView.builder(
            itemCount: userProvider.searchResults.length,
            itemBuilder: (context, index) {
              final user = userProvider.searchResults[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage("${AppConfig.serverUrl}${user.avatarUrl}")
                      : null,
                  child: user.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Sinh viên Hub"),
                trailing: _buildSearchActionBtn(user),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- NÚT BẤM LOGIC CHO TÌM KIẾM ---
  Widget _buildSearchActionBtn(UserSearchDto user) {
    // Trường hợp đã là bạn
    if (user.isFriend) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    // Trường hợp đã gửi yêu cầu (Status = 0)
    if (user.hasSentRequest) {
      return TextButton(
          onPressed: null,
          child: Text("Đã gửi", style: TextStyle(color: Colors.blue[300]))
      );
    }

    // Trường hợp chưa có quan hệ -> Nút Kết bạn
    return ElevatedButton(
      onPressed: () async {
        final success = await context.read<UserProvider>().sendRequest(user.id);
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Đã gửi lời mời tới ${user.displayName}")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text("Kết bạn", style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  // --- CÁC WIDGET PHỤ ---

  Widget _buildUserHeader() {
    final avatarUrl = widget.user['avatarUrl'];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: avatarUrl != null && avatarUrl.toString().isNotEmpty
                ? NetworkImage("${AppConfig.serverUrl}$avatarUrl")
                : null,
            child: avatarUrl == null ? const Icon(Icons.person, size: 35) : null,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user['displayName'] ?? "Người dùng Hub",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(widget.user['studentCode'] ?? "Mã sinh viên trống"),
            ],
          ),
        ],
      ),
    );
  }

  void _showUnfriendConfirm(FriendModel friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hủy kết bạn"),
        content: Text("Bạn có muốn xóa ${friend.displayName} khỏi danh sách?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<FriendProvider>().handleUnfriend(friend.id);
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}