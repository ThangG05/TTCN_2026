import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Sử dụng GlobalKey để quản lý Form nếu cần validate sau này
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    // Luôn dispose controller để tránh rò rỉ bộ nhớ
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // watch để lắng nghe biến isLoading thay đổi và vẽ lại giao diện
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Tránh lỗi vệt đen vàng (Overflow) khi bàn phím hiện lên
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhập thông tin đăng nhập',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputStyle('Nhập email của bạn'),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Mật khẩu',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passCtrl,
                  obscureText: _isObscure,
                  decoration: _inputStyle('Nhập mật khẩu').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // KHU VỰC NÚT ĐĂNG NHẬP
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    // Vô hiệu hóa nút khi đang load để tránh bấm nhiều lần
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                      // Kiểm tra input trống cơ bản
                      if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                        _showError('Vui lòng nhập đầy đủ thông tin');
                        return;
                      }

                      // Gọi hàm login từ Provider
                      bool success = await context.read<AuthProvider>().login(
                        emailCtrl.text,
                        passCtrl.text,
                      );

                      if (context.mounted) {
                        if (success) {
                          // Nếu thành công -> Chuyển vào trang chủ
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          // Nếu thất bại -> Thông báo lỗi cho người dùng
                          _showError('Email hoặc mật khẩu không đúng!');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFF1A237E).withOpacity(0.6),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản? ', style: TextStyle(color: Colors.black)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/email'),
                      child: const Text(
                        'Đăng ký',
                        style: TextStyle(
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hiển thị thông báo lỗi nhanh
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

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
      ),
    );
  }
}