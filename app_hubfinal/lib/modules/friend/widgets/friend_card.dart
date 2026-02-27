import 'package:flutter/material.dart';
import 'package:app_hubfinal/core/config/app_config.dart';
import '../friend_model.dart';

class FriendCard extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback? onUnfriend;
  final VoidCallback? onTap;

  const FriendCard({
    super.key,
    required this.friend,
    this.onUnfriend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 55,
          height: 55,
          color: Colors.grey[200],
          child: friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
              ? Image.network(
            "${AppConfig.serverUrl}${friend.avatarUrl}",
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.grey),
          )
              : const Icon(Icons.person, color: Colors.grey),
        ),
      ),
      title: Text(
        friend.displayName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        friend.subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz, color: Colors.black54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onSelected: (value) {
          if (value == 'unfriend' && onUnfriend != null) {
            onUnfriend!();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'unfriend',
            child: Row(
              children: [
                Icon(Icons.person_remove_outlined, color: Colors.redAccent, size: 20),
                SizedBox(width: 10),
                Text("Hủy kết bạn", style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}