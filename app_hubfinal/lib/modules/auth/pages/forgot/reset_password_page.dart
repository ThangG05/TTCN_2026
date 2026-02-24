import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, this.email = ""});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool _isObscurePass = true;
  bool _isObscureConfirm = true;

  @override
  void dispose() {
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  // Hàm hiển thị thông báo nhanh
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Hàm kiểm tra các điều kiện mật khẩu (Đồng bộ với CreatePasswordPage)
  bool _validatePassword() {
    String password = passCtrl.text;
    String confirm = confirmPassCtrl.text;

    final hasUppercase = RegExp(r'[A-Z]');
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    if (password.isEmpty || confirm.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin', Colors.orange);
      return false;
    }
    if (password.length <= 6) {
      _showSnackBar('Mật khẩu phải dài hơn 6 ký tự', Colors.redAccent);
      return false;
    }
    if (!hasUppercase.hasMatch(password)) {
      _showSnackBar('Mật khẩu phải có ít nhất 1 chữ hoa', Colors.redAccent);
      return false;
    }
    if (!hasSpecialChar.hasMatch(password)) {
      _showSnackBar('Mật khẩu phải có ít nhất 1 ký tự đặc biệt', Colors.redAccent);
      return false;
    }
    if (password != confirm) {
      _showSnackBar('Mật khẩu xác nhận không khớp', Colors.redAccent);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // Lấy email linh hoạt từ widget hoặc Provider
    final String effectiveEmail = widget.email.isNotEmpty ? widget.email : (auth.tempEmail ?? "");

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
      body: SafeArea(
        child: SingleChildScrollView( // Tránh lỗi tràn màn hình khi hiện bàn phím
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mật khẩu mới',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Điều kiện: > 6 ký tự, 1 chữ hoa và 1 ký tự đặc biệt',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                _buildLabel('Mật khẩu mới'),
                const SizedBox(height: 8),
                TextField(
                  controller: passCtrl,
                  obscureText: _isObscurePass,
                  decoration: _inputStyle(
                    hint: 'Nhập mật khẩu mới',
                    isObscure: _isObscurePass,
                    onToggle: () => setState(() => _isObscurePass = !_isObscurePass),
                  ),
                ),

                const SizedBox(height: 20),

                _buildLabel('Xác nhận mật khẩu'),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: _isObscureConfirm,
                  decoration: _inputStyle(
                    hint: 'Xác nhận lại mật khẩu',
                    isObscure: _isObscureConfirm,
                    onToggle: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                      // 1. Kiểm tra điều kiện đầu vào
                      if (_validatePassword()) {

                        // 2. GỌI HÀM resetPassword (ĐÃ FIX TỪ createPassword)
                        bool success = await context
                            .read<AuthProvider>()
                            .resetPassword(effectiveEmail, passCtrl.text);

                        if (success && context.mounted) {
                          _showSnackBar('Đặt lại mật khẩu thành công!', Colors.green);

                          // 3. Chuyển hướng về trang Welcome Back và xóa stack cũ
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/welcome-back',
                                (route) => false,
                          );
                        } else if (!success && context.mounted) {
                          _showSnackBar('Không thể đổi mật khẩu. Thử lại sau!', Colors.red);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Xác nhận',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  InputDecoration _inputStyle({
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey,
        ),
        onPressed: onToggle,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
      ),
    );
  }
}