import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../friend_provider.dart'; 
import '../../user/user_provider.dart';
import '../../user/user_search_dto.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key, required Map<String, dynamic> user});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Tải cả danh sách bạn bè và lời mời chờ xử lý
      context.read<FriendProvider>().initFriendData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<UserProvider>().searchUsers(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 2, // Mặc định mở Tab Tìm bạn mới
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          centerTitle: true,
          title: const Text(
            "Mạng lưới Hub",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Bạn bè"),
              Tab(text: "Lời mời"),
              Tab(text: "Tìm bạn mới"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFriendsTab(), // Tab 0
            _buildPendingTab(), // Tab 1
            _buildSearchTab(),  // Tab 2
          ],
        ),
      ),
    );
  }

  // =============================
  // TAB 0: DANH SÁCH BẠN BÈ
  // =============================
  // lib/pages/friend/friend_list_page.dart
  Widget _buildFriendsTab() {
    return Consumer<FriendProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        return RefreshIndicator(
          onRefresh: () => provider.loadFriends(),
          child: provider.friends.isEmpty
              ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 100),
              Center(child: Text("Bạn chưa có người bạn nào")),
              Center(child: Text("Vuốt xuống để tải lại", style: TextStyle(color: Colors.grey, fontSize: 12))),
            ],
          )
              : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: provider.friends.length,
            itemBuilder: (context, index) {
              final friend = provider.friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (friend.avatarUrl != null)
                      ? NetworkImage(friend.avatarUrl!)
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
                title: Text(friend.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(friend.subtitle),
                trailing: TextButton(
                  onPressed: () => _showUnfriendDialog(friend.id, friend.displayName),
                  child: const Text("Hủy kết bạn", style: TextStyle(color: Colors.red)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // =============================
  // TAB 1: LỜI MỜI KẾT BẠN
  // =============================
  Widget _buildPendingTab() {
    return Consumer<FriendProvider>(
      builder: (context, provider, child) {
        if (provider.pendingRequests.isEmpty) return const Center(child: Text("Không có lời mời nào"));

        return ListView.builder(
          itemCount: provider.pendingRequests.length,
          itemBuilder: (context, index) {
            final req = provider.pendingRequests[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: (req['avatarUrl'] != null)
                    ? NetworkImage(req['avatarUrl'])
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              ),
              title: Text(req['displayName'] ?? "Sinh viên Hub", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Đã gửi lời mời cho bạn"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await provider.acceptFriend(req['id']);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text("Chấp nhận"),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => provider.declineFriend(req['id']),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =============================
  // TAB 2: TÌM BẠN MỚI
  // =============================
  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Tìm kiếm sinh viên ...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: Consumer<UserProvider>(
            builder: (context, provider, child) {
              if (provider.isSearching) return const Center(child: CircularProgressIndicator());
              if (provider.searchResults.isEmpty) return const Center(child: Text("Nhập tên để tìm kiếm"));

              return ListView.builder(
                itemCount: provider.searchResults.length,
                itemBuilder: (context, index) {
                  final user = provider.searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (user.avatarUrl != null)
                          ? NetworkImage(user.avatarUrl!)
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    ),
                    title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user.bio),
                    trailing: _buildSearchActionButton(user),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchActionButton(UserSearchDto user) {
    if (user.isFriend) return const Text("Bạn bè", style: TextStyle(color: Colors.grey));
    if (user.hasSentRequest) return const Text("Đã gửi", style: TextStyle(color: Colors.blue));

    if (user.isIncomingRequest) {
      return OutlinedButton(
        onPressed: () => DefaultTabController.of(context).animateTo(1),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)),
        child: const Text("Phản hồi"),
      );
    }

    return ElevatedButton(
      onPressed: () => context.read<UserProvider>().sendRequest(user.id),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50], foregroundColor: Colors.blue),
      child: const Text("Kết bạn"),
    );
  }

  void _showUnfriendDialog(String friendId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hủy kết bạn"),
        content: Text("Bạn có chắc chắn muốn hủy kết bạn với $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Quay lại")),
          TextButton(
            onPressed: () {
              context.read<FriendProvider>().handleUnfriend(friendId);
              Navigator.pop(context);
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}