import 'package:flutter/material.dart';
import 'auth_api.dart';
import '../../core/storage/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? tempEmail;

  // 1. Hàm Đăng ký (Gửi OTP lần đầu)
  Future<bool> register(String email) async {
    _setLoading(true);
    tempEmail = email;
    try {
      await AuthApi.register(email);
      return true;
    } catch (e) {
      debugPrint("Register Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 2. Hàm Xác thực OTP (Dùng cho cả Register và Forgot Password)
  Future<bool> verifyOtp(String email, String code) async {
    _setLoading(true);
    try {
      await AuthApi.verifyOtp(email, code);
      return true;
    } catch (e) {
      debugPrint("Verify OTP Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 3. Hàm Tạo mật khẩu mới (Chỉ dùng cho đăng ký mới - Lần đầu thiết lập)
  Future<bool> createPassword(String email, String password) async {
    _setLoading(true);
    try {
      await AuthApi.createPassword(email, password);
      return true;
    } catch (e) {
      debugPrint("Create Password Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 4. Hàm Đặt lại mật khẩu (Dùng cho luồng QUÊN MẬT KHẨU - MỚI THÊM)
  // Hàm này gọi đến endpoint /auth/reset-password để tránh lỗi 400 "Tài khoản đã tồn tại"
  Future<bool> resetPassword(String email, String password) async {
    _setLoading(true);
    try {
      await AuthApi.resetPassword(email, password);
      return true;
    } catch (e) {
      debugPrint("Reset Password Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 5. Hàm Đăng nhập
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final token = await AuthApi.login(email, password);
      await TokenStorage.save(token);
      return true;
    } catch (e) {
      debugPrint("Login Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 6. Hàm Quên mật khẩu (Yêu cầu gửi OTP khôi phục)
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    tempEmail = email;
    try {
      await AuthApi.forgotPassword(email);
      return true;
    } catch (e) {
      debugPrint("Forgot Password Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Hàm bổ trợ quản lý trạng thái loading
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}