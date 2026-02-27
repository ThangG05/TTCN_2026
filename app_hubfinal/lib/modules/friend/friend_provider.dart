import 'package:flutter/material.dart';
import 'friend_api.dart';
import 'friend_model.dart';

class FriendProvider extends ChangeNotifier {
  List<FriendModel> _friends = [];
  bool _isLoading = false;

  List<FriendModel> get friends => _friends;
  bool get isLoading => _isLoading;

  // Tải danh sách bạn bè
  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await FriendApi.getMyFriends();
      _friends = data.map((item) => FriendModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Lỗi tải bạn bè: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xử lý hủy kết bạn
  Future<bool> handleUnfriend(String friendId) async {
    final success = await FriendApi.unfriend(friendId);
    if (success) {
      _friends.removeWhere((f) => f.id == friendId);
      notifyListeners(); // Cập nhật giao diện ngay lập tức
    }
    return success;
  }
}