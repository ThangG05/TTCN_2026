import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/api/api_client.dart';

class UserApi {

  // =============================
  // GET CURRENT USER
  // =============================

  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await ApiClient.dio.get('/users/me');

      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }

      return null;
    } catch (e) {
      debugPrint("GetMe Error: $e");
      return null;
    }
  }

  // =============================
  // UPDATE PROFILE
  // =============================

  static Future<bool> updateProfile({
    String? displayName,
    String? bio,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (displayName != null) data['displayName'] = displayName;
      if (bio != null) data['bio'] = bio;

      final response = await ApiClient.dio.put(
        '/users/update-profile',
        data: data,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("UpdateProfile Error: $e");
      return false;
    }
  }

  // =============================
  // UPDATE AVATAR
  // =============================

  static Future<String?> updateAvatar(String filePath) async {
    try {
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
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['avatarUrl']?.toString();
      }

      return null;
    } catch (e) {
      debugPrint("UpdateAvatar Error: $e");
      return null;
    }
  }

  // =============================
  // SEARCH USERS
  // =============================

  static Future<List<dynamic>?> searchUsers(String name) async {
    try {
      final response = await ApiClient.dio.get(
        '/users/search',
        queryParameters: {'name': name},
      );

      if (response.statusCode == 200 && response.data != null) {
        return List<dynamic>.from(response.data);
      }

      return null;
    } on DioException catch (e) {
      debugPrint("SearchUsers DioError: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("SearchUsers Error: $e");
      return null;
    }
  }

  // =============================
  // SEND FRIEND REQUEST
  // =============================

  static Future<bool> sendFriendRequest(String receiverId) async {
    try {
      final response =
      await ApiClient.dio.post('/users/send-request/$receiverId');

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("SendFriendRequest DioError: ${e.response?.data}");
      return false;
    } catch (e) {
      debugPrint("SendFriendRequest Error: $e");
      return false;
    }
  }

  // =============================
  // GET PENDING REQUESTS
  // =============================

  static Future<List<dynamic>?> getPendingRequests() async {
    try {
      final response =
      await ApiClient.dio.get('/users/pending-requests');

      if (response.statusCode == 200 && response.data != null) {
        return List<dynamic>.from(response.data);
      }

      return null;
    } catch (e) {
      debugPrint("GetPendingRequests Error: $e");
      return null;
    }
  }

  // =============================
  // ACCEPT FRIEND
  // =============================

  static Future<bool> acceptRequest(int requestId) async {
    try {
      final response =
      await ApiClient.dio.post('/users/accept-request/$requestId');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("AcceptRequest Error: $e");
      return false;
    }
  }

  // =============================
  // DECLINE FRIEND
  // =============================

  static Future<bool> declineRequest(int requestId) async {
    try {
      final response =
      await ApiClient.dio.delete('/users/decline-request/$requestId');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("DeclineRequest Error: $e");
      return false;
    }
  }
}