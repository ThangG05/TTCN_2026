
import '../core/config/app_config.dart';

class ImageHelper {
  static String? formatImageUrl(String? path) {
    if (path == null || path.isEmpty) return path;

    // Nếu bắt đầu bằng '/', nối với serverUrl
    if (path.startsWith('/')) {
      // Đảm bảo không bị thừa dấu '/' ở giữa
      final baseUrl = AppConfig.serverUrl.endsWith('/')
          ? AppConfig.serverUrl.substring(0, AppConfig.serverUrl.length - 1)
          : AppConfig.serverUrl;

      return "$baseUrl$path";
    }

    return path;
  }
}