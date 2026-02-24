import 'package:flutter/material.dart';
import 'package:app_hubfinal/modules/auth/pages/signup/register_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  int index = 0;

  final items = const [
    _OnboardingItem(
      title: 'Cập nhật các tin tức\nmới nhất',
      desc: 'Các tin tức mới nhất sẽ được cập nhật liên tục trên ứng dụng',
      emoji: '👩🏽‍🎓',
    ),
    _OnboardingItem(
      title: 'Mua bán, trao đổi\nđồ dùng',
      desc: 'Cho phép sinh viên mua bán, trao đổi đồ dùng trực tuyến',
      emoji: '😜',
    ),
    _OnboardingItem(
      title: 'Chia sẻ, tìm kiếm\ntài liệu học tập',
      desc: 'Các kiến thức, tài liệu học tập sẽ được chia sẻ giữa sinh viên',
      emoji: '😲',
    ),
    _OnboardingItem(
      title: 'Tìm kiếm bạn ở\ncùng',
      desc: 'Kết nối với sinh viên có cùng nhu cầu về phòng trọ',
      emoji: '🖐️',
    ),
  ];

  // --- ĐÂY LÀ PHẦN FIX LỖI ---
  void _goToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: items.length,
                onPageChanged: (i) => setState(() => index = i),
                itemBuilder: (_, i) => _buildPage(items[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2E8C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (index < items.length - 1) {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        } else {
                          _goToRegister(); // Gọi hàm đã sửa
                        }
                      },
                      child: Text(
                        index == items.length - 1 ? 'Bắt đầu' : 'Tiếp tục',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (index < items.length - 1)
                    OutlinedButton(
                      onPressed: _goToRegister, // Gọi hàm đã sửa
                      child: const Text('Bỏ qua'),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey.shade200,
          child: Text(item.emoji, style: const TextStyle(fontSize: 60)),
        ),
        const SizedBox(height: 32),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            item.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _OnboardingItem {
  final String title;
  final String desc;
  final String emoji;
  const _OnboardingItem({required this.title, required this.desc, required this.emoji});
}