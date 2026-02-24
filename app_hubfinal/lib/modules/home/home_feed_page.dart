import 'package:flutter/material.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HVNH Hub"),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: const Center(
        child: Text("News Feed"),
      ),
    );
  }
}
