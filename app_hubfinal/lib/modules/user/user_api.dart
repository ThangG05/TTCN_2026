import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../core/api/api_client.dart';

class UserApi {

  static Future<Map<String, dynamic>> getMe() async {
    final response = await ApiClient.dio.get('/users/me');

    if (response.data == null) {
      throw Exception("User data is null");
    }

    return Map<String, dynamic>.from(response.data);
  }

  // 1. Đổi Future<void> thành Future<bool>
  static Future<bool> updateProfile({
    String? displayName,
    String? bio,
  }) async {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (bio != null) data['bio'] = bio;

    final response = await ApiClient.dio.put(
      '/users/update-profile',
      data: data,
    );

    // Trả về true nếu status code là 200 (Thành công)
    return response.statusCode == 200;
  }


  // 2. Đổi Future<void> thành Future<String?>
  static Future<String?> updateAvatar(String filePath) async {
    if (filePath.isEmpty) {
      throw Exception("File path is empty");
    }

    final file = File(filePath);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await ApiClient.dio.put(
      '/users/update-avatar',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      // Trả về avatarUrl nhận được từ server (Ví dụ: response.data['avatarUrl'])
      return response.data['avatarUrl']?.toString();
    }
    return null;
  }
  // 3. Thêm hàm tìm kiếm người dùng
  static Future<List<dynamic>?> searchUsers(String name) async {
    try {
      // Gửi request GET kèm query parameter 'name'
      final response = await ApiClient.dio.get(
        '/users/search',
        queryParameters: {'name': name},
      );

      if (response.statusCode == 200 && response.data != null) {
        // Trả về danh sách dữ liệu (List<dynamic>) để Provider xử lý map sang Model
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      // Xử lý lỗi từ Dio (ví dụ: lỗi mạng, lỗi server 500)
      print("❌ UserApi Search Error: ${e.message}");
      return null;
    } catch (e) {
      print("❌ UserApi Unexpected Error: $e");
      return null;
    }
  }
  static Future<bool> sendFriendRequest(String receiverId) async {
    try {
      // Endpoint phải khớp với [HttpPost("send-request/{receiverId}")] ở Backend
      final response = await ApiClient.dio.post('/users/send-request/$receiverId');
      return response.statusCode == 200;
    } catch (e) {
        debugPrint("❌ API Send Request Error: $e");
      return false;
    }
  }


}