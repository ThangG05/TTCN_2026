import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class UserApi {

  static Future<Map<String, dynamic>> getMe() async {
    final response = await ApiClient.dio.get('/users/me');

    if (response.data == null) {
      throw Exception("User data is null");
    }

    return Map<String, dynamic>.from(response.data);
  }

  static Future<void> updateProfile({
    String? displayName,
    String? bio,
  }) async {

    final Map<String, dynamic> data = {};

    if (displayName != null) {
      data['displayName'] = displayName;
    }

    if (bio != null) {
      data['bio'] = bio;
    }

    await ApiClient.dio.put(
      '/users/update-profile',
      data: data,
    );
  }

  // 🔥 SỬA QUAN TRỌNG NHẤT Ở ĐÂY
  static Future<void> updateAvatar(String filePath) async {
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

    await ApiClient.dio.put(
      '/users/update-avatar',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }
}