import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../auth_provider.dart';

class ForgotOtpPage extends StatefulWidget {
  final String email;
  const ForgotOtpPage({super.key, this.email = ""});

  @override
  State<ForgotOtpPage> createState() => _ForgotOtpPageState();
}

class _ForgotOtpPageState extends State<ForgotOtpPage> {
  final otpCtrl = TextEditingController();

  @override
  void dispose() {
    otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final String effectiveEmail = widget.email.isNotEmpty
        ? widget.email
        : (auth.tempEmail ?? "");

    final defaultPinTheme = PinTheme(
      width: 45,
      height: 55,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // FIX 1: Bọc body bằng GestureDetector để chạm ngoài là ẩn bàn phím
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          // FIX 2: Thêm SingleChildScrollView để tránh lỗi vạch đen vàng
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nhập OTP',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhập mã OTP đã được gửi đến email:\n$effectiveEmail',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  Center(
                    child: Pinput(
                      length: 6,
                      controller: otpCtrl,
                      defaultPinTheme: defaultPinTheme,
                      separatorBuilder: (index) => const SizedBox(width: 8),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Text("Chưa nhận được mã? ", style: TextStyle(fontSize: 14)),
                      GestureDetector(
                        onTap: auth.isLoading ? null : () {
                          context.read<AuthProvider>().forgotPassword(effectiveEmail);
                        },
                        child: const Text(
                          "Gửi lại mã",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),

                  // FIX 3: Thay Spacer() bằng SizedBox cố định hoặc dùng ConstrainedBox
                  const SizedBox(height: 80),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        disabledBackgroundColor: const Color(0xFF1A237E).withOpacity(0.6),
                      ),
                      onPressed: auth.isLoading ? null : () async {
                        // Gọi verifyOtp trả về bool (giống các trang trước đã hướng dẫn)
                        bool success = await context.read<AuthProvider>().verifyOtp(effectiveEmail, otpCtrl.text);

                        if (context.mounted) {
                          if (success) {
                            Navigator.pushNamed(
                              context,
                              '/reset-password',
                              arguments: effectiveEmail,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Mã OTP không chính xác hoặc đã hết hạn"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: auth.isLoading
                          ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                          : const Text(
                        'Xác nhận',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}