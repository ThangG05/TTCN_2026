import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import '../user_search_dto.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm theo tên hiển thị...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            context.read<UserProvider>().searchUsers(value);
          },
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.searchResults.isEmpty) {
            return const Center(child: Text("Nhập tên để tìm kiếm bạn bè"));
          }

          return ListView.builder(
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final user = provider.searchResults[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
                title: Text(user.displayName),
                trailing: _buildActionButton(user),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButton(UserSearchDto user) {
    if (user.isFriend) {
      return const Text("Bạn bè", style: TextStyle(color: Colors.grey));
    }
    if (user.hasSentRequest) {
      return const ElevatedButton(onPressed: null, child: Text("Đã gửi"));
    }
    return ElevatedButton(
      onPressed: () {
        // Gọi hàm gửi lời mời kết bạn ở đây
      },
      child: const Text("Kết bạn"),
    );
  }
}