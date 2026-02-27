import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_hubfinal/core/config/app_config.dart';
import 'package:app_hubfinal/core/storage/token_storage.dart'; // Đảm bảo import đúng

class FriendApi {
  // Lấy danh sách bạn bè
  static Future<List<dynamic>> getMyFriends() async {
    final token = await TokenStorage.get(); // Đã sửa từ getToken() thành get()

    try {
      final response = await http.get(
        Uri.parse("${AppConfig.serverUrl}/api/friends/my-friends"),
        headers: {
          'Authorization': 'Bearer ${token ?? ""}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Lỗi API getMyFriends: $e");
    }
    return [];
  }

  // Hủy kết bạn
  static Future<bool> unfriend(String friendId) async {
    final token = await TokenStorage.get(); // Đã sửa từ getToken() thành get()

    try {
      final response = await http.delete(
        Uri.parse("${AppConfig.serverUrl}/api/friends/unfriend/$friendId"),
        headers: {
          'Authorization': 'Bearer ${token ?? ""}',
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi API unfriend: $e");
      return false;
    }
  }
}