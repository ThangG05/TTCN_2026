import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';
import 'forgot_otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String email;
  const ForgotPasswordPage({super.key, this.email = ""});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailCtrl.text = widget.email;
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  // Hàm kiểm tra định dạng email sinh viên ngay tại Client
  bool _isValidStudentEmail(String email) {
    return email.trim().toLowerCase().endsWith("@hvnh.edu.vn");
  }

  @override
  Widget build(BuildContext context) {
    // Watch để nút bấm tự động cập nhật trạng thái (ngừng quay khi loading xong)
    final auth = context.watch<AuthProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quên mật khẩu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nhập email sinh viên để nhận mã khôi phục',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Email Học viện',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'vi_du@hvnh.edu.vn',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1A237E)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        disabledBackgroundColor: const Color(0xFF1A237E).withOpacity(0.6),
                      ),
                      // auth.isLoading = true thì nút sẽ mờ đi và không bấm được
                      onPressed: auth.isLoading ? null : () async {
                        String email = emailCtrl.text.trim();

                        // 1. Kiểm tra không được để trống
                        if (email.isEmpty) {
                          _showError("Vui lòng nhập email của bạn");
                          return;
                        }

                        // 2. Ràng buộc đuôi email @hvnh.edu.vn
                        if (!_isValidStudentEmail(email)) {
                          _showError("Chỉ chấp nhận email sinh viên @hvnh.edu.vn");
                          return;
                        }

                        // 3. Gọi Backend (Backend sẽ check email có tồn tại hay không)
                        bool success = await context.read<AuthProvider>().forgotPassword(email);

                        if (context.mounted) {
                          if (success) {
                            // Thành công -> Sang trang OTP
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotOtpPage(email: email),
                              ),
                            );
                          } else {
                            // Thất bại (Do Backend trả về lỗi 400 vì email không tồn tại)
                            _showError("Email này chưa được đăng ký trên hệ thống");
                          }
                        }
                      },
                      child: auth.isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
                        'Tiếp tục',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Quay lại "),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            color: Color(0xFF1A237E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}