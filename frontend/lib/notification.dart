import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false, // We'll build our own leading
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF4AA5A6),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              "Notifikasi",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          _buildNotificationItem(
            title: "Tempat Ini Favoritnya Warlok!",
            message:
                "Tempat-tempat viral di Tangerang buat dikunjungi bareng teman-temanmu. Yuk, intip dulu tempat-tempat ini!",
          ),
          _buildNotificationItem(
            title: "Jangan Lupa Mampir!",
            message:
                "Kamu nambahin tempat-tempat ini di markah kamu. Berkunjung sekarang juga, yuk!",
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.grey,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
        const SizedBox(height: 4),
      ],
    );
  }
}
