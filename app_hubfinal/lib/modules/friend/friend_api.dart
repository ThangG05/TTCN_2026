import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_hubfinal/core/config/app_config.dart';
import 'package:app_hubfinal/core/storage/token_storage.dart';

class FriendApi {
  static const String _baseUrl = "${AppConfig.serverUrl}/api/friends";

  // Lấy header có Token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.get();
    return {
      'Authorization': 'Bearer ${token ?? ""}',
      'Content-Type': 'application/json',
    };
  }

  // 1. Danh sách bạn bè chính thức
  static Future<List<dynamic>> getMyFriends() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/my-friends"), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print("Error getMyFriends: $e"); }
    return [];
  }

  // 2. Danh sách lời mời đang chờ (Vẫn gọi UsersController hoặc chuyển sang FriendsController tùy bạn)
  static Future<List<dynamic>> getPendingRequests() async {
    try {
      final response = await http.get(
          Uri.parse("${AppConfig.serverUrl}/api/users/pending-requests"),
          headers: await _getHeaders()
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print("Error getPendingRequests: $e"); }
    return [];
  }

  // 3. Chấp nhận kết bạn
  static Future<bool> acceptRequest(int requestId) async {
    try {
      final response = await http.post(Uri.parse("$_baseUrl/accept/$requestId"), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // 4. Từ chối/Gỡ lời mời
  static Future<bool> declineRequest(int requestId) async {
    try {
      final response = await http.delete(Uri.parse("$_baseUrl/decline/$requestId"), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // 5. Hủy kết bạn
  static Future<bool> unfriend(String friendId) async {
    try {
      final response = await http.delete(Uri.parse("$_baseUrl/unfriend/$friendId"), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}