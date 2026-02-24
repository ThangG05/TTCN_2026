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
    final provider = context.read<UserProvider>();
    final user = provider.userData;

    if (user != null) {
      _displayController.text = user['displayName'] ?? '';
      _bioController.text = user['bio'] ?? '';
    }
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

      // 🔥 FIX 1: Đảm bảo giải mã được HEIF/HEIC trước khi convert
      if (picked.path.toLowerCase().endsWith('.heif') ||
          picked.path.toLowerCase().endsWith('.heic')) {

        final bytes = await fileToUpload.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        if (decodedImage != null) {
          final jpgBytes = img.encodeJpg(decodedImage, quality: 85);
          final newPath = picked.path.replaceAll(RegExp(r'\.\w+$'), '.jpg');
          final convertedFile = File(newPath);
          await convertedFile.writeAsBytes(jpgBytes);
          fileToUpload = convertedFile;
        }
      }

      final success = await context.read<UserProvider>().updateAvatar(fileToUpload.path);

      if (success && mounted) {
        setState(() {
          // Gán file local vào để UI cập nhật ngay lập tức mà không cần đợi Network
          _selectedImage = fileToUpload;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật avatar thất bại")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final user = provider.userData;

    ImageProvider? avatarProvider;

    if (_selectedImage != null) {
      avatarProvider = FileImage(_selectedImage!);
    }
    else if (user != null && user['avatarUrl'] != null && user['avatarUrl'].toString().isNotEmpty) {
      // 🔥 FIX 2: Thêm Timestamp để phá Cache (Tránh lỗi 404 khi file cũ bị xóa/thay thế)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fullUrl = "${AppConfig.serverUrl}${user['avatarUrl']}?v=$timestamp";

      avatarProvider = NetworkImage(fullUrl);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Chỉnh sửa trang cá nhân"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: avatarProvider,
                    // 🔥 FIX 3: Thêm xử lý lỗi trực tiếp nếu NetworkImage tèo
                    onBackgroundImageError: (exception, stackTrace) {
                      debugPrint("Lỗi load ảnh: $exception");
                    },
                    child: avatarProvider == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A237E),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _displayController,
              decoration: InputDecoration(
                labelText: "Tên hiển thị",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Tiểu sử",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            provider.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final success = await provider.updateProfile(
                    _displayController.text.trim(),
                    _bioController.text.trim(),
                  );
                  if (success && context.mounted) Navigator.pop(context);
                },
                child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}