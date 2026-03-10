import 'package:flutter/material.dart';
import 'friend_api.dart';
import 'friend_model.dart';

class FriendProvider extends ChangeNotifier {
  List<FriendModel> _friends = [];
  List<dynamic> _pendingRequests = [];
  bool _isLoading = false;

  List<FriendModel> get friends => _friends;
  List<dynamic> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;

  // Tải toàn bộ dữ liệu bạn bè & lời mời
  Future<void> initFriendData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Future.wait giúp tải song song cả 2 để tiết kiệm thời gian
      await Future.wait([
        loadFriends(),
        loadPendingRequests(),
      ]);
    } catch (e) {
      debugPrint("Lỗi initFriendData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // LẤY DANH SÁCH BẠN BÈ - Sửa lỗi cập nhật UI ở đây
  Future<void> loadFriends() async {
    try {
      final data = await FriendApi.getMyFriends();
      // Chuyển đổi dữ liệu từ JSON sang Model
      _friends = data.map((item) => FriendModel.fromJson(item)).toList();

      // Quan trọng: In log để kiểm tra nếu danh sách trống do Server hay do App
      debugPrint("Số lượng bạn bè đã tải: ${_friends.length}");

      notifyListeners(); // Thông báo cho UI vẽ lại Tab 0
    } catch (e) {
      debugPrint("Lỗi loadFriends: $e");
    }
  }

  Future<void> loadPendingRequests() async {
    try {
      final data = await FriendApi.getPendingRequests();
      _pendingRequests = data;
      notifyListeners(); // Thông báo cho UI vẽ lại Tab 1
    } catch (e) {
      debugPrint("Lỗi loadPendingRequests: $e");
    }
  }

  // Chấp nhận: Sửa để đảm bảo Tab bạn bè hiện ra ngay
  Future<bool> acceptFriend(int requestId) async {
    try {
      final success = await FriendApi.acceptRequest(requestId);
      if (success) {
        // 1. Xóa lời mời vừa chấp nhận khỏi danh sách chờ
        _pendingRequests.removeWhere((req) => req['id'] == requestId);

        // 2. Gọi lại loadFriends để Server trả về danh sách bạn bè mới nhất
        await loadFriends();

        // 3. Thông báo cập nhật cho cả Tab Lời mời và Tab Bạn bè
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Lỗi acceptFriend: $e");
    }
    return false;
  }

  // Từ chối
  Future<bool> declineFriend(int requestId) async {
    try {
      final success = await FriendApi.declineRequest(requestId);
      if (success) {
        _pendingRequests.removeWhere((req) => req['id'] == requestId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Lỗi declineFriend: $e");
    }
    return false;
  }

  // Hủy kết bạn
  Future<bool> handleUnfriend(String friendId) async {
    try {
      final success = await FriendApi.unfriend(friendId);
      if (success) {
        // Xóa trực tiếp khỏi list cục bộ để UI mượt mà (Optimistic UI)
        _friends.removeWhere((f) => f.id == friendId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Lỗi handleUnfriend: $e");
    }
    return false;
  }
}