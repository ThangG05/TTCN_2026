import 'package:flutter/material.dart';

class WelcomeBackPage extends StatelessWidget {
  const WelcomeBackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Khu vực minh họa dùng Emoji và các hạt trang trí
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Các hạt trang trí xung quanh (Dots & Stars)
                    _buildDot(top: 20, left: 60, size: 12, color: Colors.orange),
                    _buildDot(bottom: 30, left: 40, size: 14, color: Colors.orangeAccent),
                    _buildDot(top: 80, right: 50, size: 10, color: Colors.orange),
                    const Positioned(
                      top: 40,
                      right: 70,
                      child: Text('⭐', style: TextStyle(fontSize: 20)),
                    ),
                    const Positioned(
                      bottom: 50,
                      right: 60,
                      child: Text('⭐', style: TextStyle(fontSize: 18)),
                    ),

                    // Vòng tròn nền nhạt phía sau Emoji
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[50], // Màu nền rất nhạt
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Emoji chính - Thay thế cho hình ảnh phức tạp
                    const Text(
                      '🥳', // Bạn có thể đổi thành '👩🏽‍🎓' hoặc '🎉' tùy ý
                      style: TextStyle(fontSize: 100),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tiêu đề
              const Text(
                'Chào mừng trở lại',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60), // Khoảng cách lớn để đẩy nút xuống

              // Nút Tiếp tục
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Xóa hết các page trước đó và về Login
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/signin',
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E), // Xanh Navy chuẩn UI
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tiếp tục',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tạo các chấm tròn trang trí
  Widget _buildDot({double? top, double? left, double? right, double? bottom, required double size, required Color color}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}