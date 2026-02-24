import '../../core/api/api_client.dart';

class AuthApi {
  // 1. Gửi OTP đăng ký
  static Future<void> register(String email) async {
    await ApiClient.dio.post(
      '/auth/register',
      data: {'email': email},
    );
  }

  // 2. Xác thực OTP (Dùng chung cho cả Đăng ký và Quên mật khẩu)
  static Future<void> verifyOtp(String email, String code) async {
    await ApiClient.dio.post(
      '/auth/verify-otp',
      data: {'email': email, 'code': code},
    );
  }

  // 3. Tạo mật khẩu LẦN ĐẦU (Dùng sau khi đăng ký thành công)
  static Future<void> createPassword(String email, String password) async {
    await ApiClient.dio.post(
      '/auth/create-password',
      data: {'email': email, 'password': password},
    );
  }

  // 4. ĐẶT LẠI mật khẩu (Dùng cho luồng Quên mật khẩu - ĐÃ FIX)
  static Future<void> resetPassword(String email, String password) async {
    await ApiClient.dio.post(
      '/auth/reset-password', // <--- Gọi đúng endpoint mới ở Backend
      data: {'email': email, 'password': password},
    );
  }

  // 5. Đăng nhập
  static Future<String> login(String email, String password) async {
    final res = await ApiClient.dio.post(
      '/auth/signin',
      data: {'email': email, 'password': password},
    );
    // Đảm bảo lấy đúng key 'token' từ response của Backend
    return res.data['token'];
  }

  // 6. Gửi OTP quên mật khẩu
  static Future<void> forgotPassword(String email) async {
    await ApiClient.dio.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }
}