import 'package:flutter/material.dart';
import 'user_api.dart';
import '../../core/storage/token_storage.dart';

class UserProvider extends ChangeNotifier {
  bool isLoading = false;
  Map<String, dynamic>? userData;

  bool get isLoggedIn => userData != null;

  Future<bool> loadMe() async {
    _setLoading(true);
    try {
      userData = await UserApi.getMe();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Load Me Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String? displayName, String? bio) async {
    _setLoading(true);
    try {
      await UserApi.updateProfile(
        displayName: displayName,
        bio: bio,
      );

      userData = await UserApi.getMe();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Update Profile Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAvatar(String filePath) async {
    _setLoading(true);
    try {
      await UserApi.updateAvatar(filePath);

      userData = await UserApi.getMe();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Update Avatar Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    userData = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}