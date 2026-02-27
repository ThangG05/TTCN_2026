import 'package:app_hubfinal/modules/user/user_search_dto.dart';
import 'package:flutter/material.dart';
import 'user_api.dart';
import '../../core/storage/token_storage.dart';
// Giả sử bạn đặt UserSearchDto ở cùng thư mục hoặc file models

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  // --- PHẦN MỚI CHO TÌM KIẾM ---
  List<UserSearchDto> _searchResults = [];
  bool _isSearching = false;

  // Getters
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _userData != null;

  // Getters cho tìm kiếm
  List<UserSearchDto> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  // --- LOGIC CŨ ---
  Future<void> loadMe() async {
    _isLoading = true;
    try {
      final data = await UserApi.getMe();
      if (data != null) {
        _userData = data;
      }
    } catch (e) {
      debugPrint("❌ Load Me Error: $e");
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- LOGIC TÌM KIẾM MỚI ---
  Future<void> searchUsers(String name) async {
    if (name.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      // Gọi đến hàm searchUsers trong UserApi (bạn cần cập nhật UserApi nữa)
      final List<dynamic>? data = await UserApi.searchUsers(name);

      if (data != null) {
        _searchResults = data.map((e) => UserSearchDto.fromJson(e)).toList();
      } else {
        _searchResults = [];
      }
    } catch (e) {
      debugPrint("❌ Search Error: $e");
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // --- CÁC HÀM CẬP NHẬT DỮ LIỆU ---
  Future<bool> updateProfile(String? displayName, String? bio) async {
    _setLoading(true);
    try {
      final success = await UserApi.updateProfile(displayName: displayName, bio: bio);
      if (success) await loadMe();
      return success;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAvatar(String filePath) async {
    _setLoading(true);
    try {
      final avatarUrl = await UserApi.updateAvatar(filePath);
      if (avatarUrl != null) await loadMe();
      return avatarUrl != null;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    _userData = null;
    _searchResults = []; // Xóa kết quả tìm kiếm khi logout
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  // --- THÊM HÀM NÀY VÀO TRONG USERPROVIDER ---
  Future<bool> sendRequest(String receiverId) async {
    try {
      // Gọi API gửi lời mời kết bạn
      final bool success = await UserApi.sendFriendRequest(receiverId);

      if (success) {
        // Cập nhật trạng thái hiển thị của User đó trong danh sách kết quả ngay lập tức
        final index = _searchResults.indexWhere((u) => u.id == receiverId);
        if (index != -1) {
          _searchResults[index] = UserSearchDto(
            id: _searchResults[index].id,
            displayName: _searchResults[index].displayName,
            avatarUrl: _searchResults[index].avatarUrl,
            isFriend: _searchResults[index].isFriend,
            hasSentRequest: true, // Đánh dấu là đã gửi để UI đổi nút
          );
          notifyListeners(); // Vẽ lại giao diện
        }
      }
      return success;
    } catch (e) {
      debugPrint("❌ Send Request Error: $e");
      return false;
    }
  }
}