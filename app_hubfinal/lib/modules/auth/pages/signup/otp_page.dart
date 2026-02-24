import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../auth_provider.dart';
import 'create_password_page.dart';

class OtpPage extends StatelessWidget {
  final String email;
  OtpPage({super.key, required this.email});

  final otpCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      // SỬA Ở ĐÂY: Thêm SingleChildScrollView để chống tràn khi hiện bàn phím
      body: SingleChildScrollView(
        child: Container(
          // Đảm bảo container chiếm ít nhất toàn bộ chiều cao màn hình để Spacer() hoặc bố cục không bị vỡ
          height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nhập mã xác thực', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Nhập mã đã được gửi qua email', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              Center(
                child: Pinput(
                  length: 6,
                  controller: otpCtrl,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 6),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                children: [
                  const Text("Chưa nhận được mã? "),
                  GestureDetector(
                    onTap: () {},
                    child: const Text("Gửi lại trong 01:00", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Spacer(), // Spacer sẽ đẩy nút xuống dưới cùng
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    try {
                      await context.read<AuthProvider>().verifyOtp(email, otpCtrl.text);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreatePasswordPage(email: email)),
                        );
                      }
                    } catch (e) {
                      // Hiện thông báo lỗi nếu Backend trả về lỗi (như lỗi 500 bạn vừa gặp)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: ${e.toString()}")),
                      );
                    }
                  },
                  child: const Text('Tiếp tục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}