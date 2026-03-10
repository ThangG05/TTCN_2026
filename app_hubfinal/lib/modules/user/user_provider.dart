import 'package:flutter/material.dart';
import 'package:app_hubfinal/modules/user/user_search_dto.dart';

import 'user_api.dart';
import '../../core/storage/token_storage.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSearching = false;

  Map<String, dynamic>? _userData;

  List<UserSearchDto> _searchResults = [];
  List<Map<String, dynamic>> _pendingRequests = [];

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isLoggedIn => _userData != null;

  Map<String, dynamic>? get userData => _userData;

  List<UserSearchDto> get searchResults => _searchResults;

  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;

  // =============================
  // LOAD CURRENT USER
  // =============================

  Future<void> loadMe() async {
    _setLoading(true);

    try {
      final data = await UserApi.getMe();
      _userData = data;
    } catch (e) {
      debugPrint("LoadMe Error: $e");
      _userData = null;
    }

    _setLoading(false);
  }

  // =============================
  // SEARCH USERS
  // =============================

  Future<void> searchUsers(String name) async {
    if (name.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final List<dynamic>? data = await UserApi.searchUsers(name);

      if (data != null) {
        _searchResults =
            data.map((e) => UserSearchDto.fromJson(e)).toList();
      } else {
        _searchResults = [];
      }
    } catch (e) {
      debugPrint("SearchUsers Error: $e");
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  // =============================
  // UPDATE PROFILE
  // =============================

  Future<bool> updateProfile(String? displayName, String? bio) async {
    _setLoading(true);

    try {
      final success = await UserApi.updateProfile(
        displayName: displayName,
        bio: bio,
      );

      if (success) {
        await loadMe();
      }

      return success;
    } catch (e) {
      debugPrint("UpdateProfile Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // UPDATE AVATAR
  // =============================

  Future<bool> updateAvatar(String filePath) async {
    _setLoading(true);

    try {
      final avatarUrl = await UserApi.updateAvatar(filePath);

      if (avatarUrl != null) {
        await loadMe();
      }

      return avatarUrl != null;
    } catch (e) {
      debugPrint("UpdateAvatar Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // SEND FRIEND REQUEST
  // =============================

  Future<bool> sendRequest(String receiverId) async {
    try {
      final success = await UserApi.sendFriendRequest(receiverId);

      if (!success) return false;

      final index =
      _searchResults.indexWhere((user) => user.id == receiverId);

      if (index != -1) {
        final user = _searchResults[index];

        // CẬP NHẬT Ở ĐÂY: Thêm isIncomingRequest
        _searchResults[index] = UserSearchDto(
          id: user.id,
          displayName: user.displayName,
          bio: user.bio,
          avatarUrl: user.avatarUrl,
          isFriend: user.isFriend,
          hasSentRequest: true, // Đánh dấu đã gửi thành công
          isIncomingRequest: user.isIncomingRequest, // Giữ nguyên trạng thái cũ
        );

        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint("SendRequest Error: $e");
      return false;
    }
  }
  // =============================
  // LOAD FRIEND REQUESTS
  // =============================

  Future<void> loadPendingRequests() async {
    try {
      final data = await UserApi.getPendingRequests();

      if (data != null) {
        _pendingRequests = List<Map<String, dynamic>>.from(data);
      } else {
        _pendingRequests = [];
      }

      debugPrint("PendingRequests: $_pendingRequests");
    } catch (e) {
      debugPrint("LoadPendingRequests Error: $e");
      _pendingRequests = [];
    }

    notifyListeners();
  }

  // =============================
  // ACCEPT FRIEND
  // =============================

  Future<bool> acceptFriend(int requestId) async {
    try {
      final success = await UserApi.acceptRequest(requestId);

      if (success) {
        _pendingRequests.removeWhere((req) => req['id'] == requestId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint("AcceptFriend Error: $e");
      return false;
    }
  }

  // =============================
  // DECLINE FRIEND
  // =============================

  Future<bool> declineFriend(int requestId) async {
    try {
      final success = await UserApi.declineRequest(requestId);

      if (success) {
        _pendingRequests.removeWhere((req) => req['id'] == requestId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint("DeclineFriend Error: $e");
      return false;
    }
  }

  // =============================
  // LOGOUT
  // =============================

  Future<void> logout() async {
    await TokenStorage.clear();

    _userData = null;
    _searchResults = [];
    _pendingRequests = [];

    notifyListeners();
  }

  // =============================
  // HELPER
  // =============================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}