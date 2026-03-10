import 'dart:io';
import 'package:app_hubfinal/core/config/app_config.dart';
import 'package:app_hubfinal/modules/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _displayController = TextEditingController();
  final _bioController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Sử dụng WidgetsBinding để đảm bảo context đã sẵn sàng để đọc Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserProvider>();
      final user = provider.userData;
      if (user != null) {
        _displayController.text = user['displayName'] ?? '';
        _bioController.text = user['bio'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _displayController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      File fileToUpload = File(picked.path);

      // Xử lý chuyển đổi định dạng ảnh Apple (HEIC) sang JPG
      final String pathLower = picked.path.toLowerCase();
      if (pathLower.endsWith('.heif') || pathLower.endsWith('.heic')) {
        final bytes = await fileToUpload.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        if (decodedImage != null) {
          final jpgBytes = img.encodeJpg(decodedImage, quality: 85);
          final newPath = picked.path.replaceAll(RegExp(r'\.(heif|heic)$', caseSensitive: false), '.jpg');
          final convertedFile = File(newPath);
          await convertedFile.writeAsBytes(jpgBytes);
          fileToUpload = convertedFile;
        }
      }

      // Thực hiện upload avatar ngay khi chọn xong
      final success = await context.read<UserProvider>().updateAvatar(fileToUpload.path);

      if (success && mounted) {
        setState(() {
          _selectedImage = fileToUpload;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật ảnh đại diện thất bại")),
        );
      }
    }
  }

  // Hàm xây dựng Provider cho ảnh đại diện
  ImageProvider? _buildAvatarProvider(Map<String, dynamic>? user) {
    // Ưu tiên 1: Ảnh vừa mới chọn (File local)
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    // Ưu tiên 2: Ảnh từ server (URL)
    final avatarUrl = user?['avatarUrl']?.toString();
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      String baseUrl = AppConfig.serverUrl;
      if (!baseUrl.endsWith('/')) baseUrl += '/';

      String cleanPath = avatarUrl;
      if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);

      return NetworkImage("$baseUrl$cleanPath?v=$timestamp");
    }

    // Mặc định: Trả về null nếu không có ảnh
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final user = provider.userData;
    final avatarProvider = _buildAvatarProvider(user);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Chỉnh sửa trang cá nhân"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // KHU VỰC ẢNH ĐẠI DIỆN
            GestureDetector(
              onTap: provider.isLoading ? null : _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    // Hiển thị ảnh nếu có
                    foregroundImage: avatarProvider,

                    // 🔥 FIX LỖI ASSERTION TẠI ĐÂY:
                    // Chỉ truyền hàm xử lý lỗi khi avatarProvider KHÁC null.
                    onForegroundImageError: avatarProvider != null
                        ? (exception, stackTrace) {
                      debugPrint("Lỗi tải ảnh: $exception");
                    }
                        : null,

                    // Nếu ảnh load lỗi hoặc không có ảnh, child (Icon) sẽ hiện ra
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),

                  // Icon camera phía góc ảnh
                  if (!provider.isLoading)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // TRƯỜNG NHẬP LIỆU: TÊN
            TextField(
              controller: _displayController,
              decoration: InputDecoration(
                labelText: "Tên hiển thị",
                prefixIcon: const Icon(Icons.badge),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // TRƯỜNG NHẬP LIỆU: TIỂU SỬ
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Tiểu sử",
                prefixIcon: const Icon(Icons.info_outline),
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),

            // NÚT LƯU THÔNG TIN
            provider.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () async {
                  final success = await provider.updateProfile(
                    _displayController.text.trim(),
                    _bioController.text.trim(),
                  );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã lưu thay đổi thành công")),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                    "Lưu thay đổi",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}