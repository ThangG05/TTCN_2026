import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';
import 'welcome_after_register_page.dart';

class CreatePasswordPage extends StatefulWidget {
  final String email;
  const CreatePasswordPage({super.key, required this.email});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool _isObscure = true;
  bool _isObscureConfirm = true;

  // Giải phóng bộ nhớ khi đóng trang
  @override
  void dispose() {
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  // Hàm hiển thị thông báo lỗi nhanh
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

  // Hàm kiểm tra các điều kiện mật khẩu
  bool _validatePassword() {
    String password = passCtrl.text;
    String confirm = confirmCtrl.text;

    // Định nghĩa Regex: ít nhất 1 chữ hoa, 1 ký tự đặc biệt
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thiết lập mật khẩu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Điều kiện: > 6 ký tự, 1 chữ hoa và 1 ký tự đặc biệt',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Trường Mật khẩu
            _buildLabel('Mật khẩu'),
            const SizedBox(height: 8),
            TextField(
              controller: passCtrl,
              obscureText: _isObscure,
              decoration: _inputDecoration(
                hint: 'Nhập mật khẩu',
                isObscure: _isObscure,
                onToggle: () => setState(() => _isObscure = !_isObscure),
              ),
            ),

            const SizedBox(height: 20),

            // Trường Xác nhận mật khẩu
            _buildLabel('Xác nhận mật khẩu'),
            const SizedBox(height: 8),
            TextField(
              controller: confirmCtrl,
              obscureText: _isObscureConfirm,
              decoration: _inputDecoration(
                hint: 'Nhập lại mật khẩu',
                isObscure: _isObscureConfirm,
                onToggle: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
              ),
            ),

            const Spacer(),

            // Nút Hoàn thành
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  // Gọi hàm kiểm tra điều kiện trước khi xử lý
                  if (_validatePassword()) {
                    await context
                        .read<AuthProvider>()
                        .createPassword(widget.email, passCtrl.text);

                    if (context.mounted) {
                      _showSnackBar('Tạo mật khẩu thành công!', Colors.green);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomeAfterRegisterPage()),
                            (_) => false,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Hoàn thành',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget phụ trợ cho Label
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  // Widget phụ trợ cho Decoration của TextField
  InputDecoration _inputDecoration({required String hint, required bool isObscure, required VoidCallback onToggle}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: IconButton(
        icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggle,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    );
  }
}