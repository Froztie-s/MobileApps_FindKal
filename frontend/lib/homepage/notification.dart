import 'package:flutter/material.dart';
import 'models/unggahan.dart';
import 'services/api_service.dart';
import 'services/auth_state.dart';
import 'bookmark_page.dart';
import 'unggahan_detail_page.dart';
import 'notification_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _bookmarks = [];
  List<Map<String, dynamic>> _allUnggahans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = AuthState.currentUser?['id'] as int?;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        ApiService.fetchBookmarks(userId),
        ApiService.fetchUnggahans(),
      ]);
      setState(() {
        _bookmarks = results[0];
        _allUnggahans = results[1];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<Widget> _buildNotifications() {
    final items = <Widget>[];
    final myUsername = AuthState.currentUser?['username'] as String? ?? '';

    // Notification 1: Bookmark Reminder
    if (_bookmarks.isNotEmpty) {
      final names = _bookmarks.take(3).map((b) => b['placeName'] as String).toList();
      final preview = names.join(', ') + (_bookmarks.length > 3 ? ', dan lainnya' : '');
      items.add(_buildNotificationItem(
        title: "Jangan Lupa Mampir!",
        message: "Kamu menyimpan $preview di markah kamu. Berkunjung sekarang juga, yuk!",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookmarkPage()),
        ),
      ));
    }

    // Notification 2: New posts on bookmarked places
    if (_bookmarks.isNotEmpty && _allUnggahans.isNotEmpty) {
      final bookmarkedNames = _bookmarks.map((b) => b['placeName'] as String).toSet();
      final related = _allUnggahans
          .where((u) => bookmarkedNames.contains(u['placeName']))
          .toList();
      if (related.isNotEmpty) {
        items.add(_buildNotificationItem(
          title: "Ada Ulasan Baru!",
          message:
              "Ada ${related.length} ulasan baru untuk tempat yang kamu tandai — termasuk ${related.first['placeName']}.",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UnggahanDetailPage(unggahan: Unggahan.fromJson(related.first)),
            ),
          ),
        ));
      }
    }

    // Notification 3: New posts from other users
    if (_allUnggahans.isNotEmpty) {
      final otherPosts = _allUnggahans
          .where((u) =>
              (u['usernameHandle'] as String).replaceAll('@', '') != myUsername)
          .toList();
      if (otherPosts.isNotEmpty) {
        final count = otherPosts.length;
        final message = count == 1
            ? "${otherPosts.first['userName']} baru saja berbagi tempat baru. Yuk, cek!"
            : "${otherPosts.first['userName']} dan ${count - 1} lainnya baru saja berbagi tempat baru. Yuk, cek!";
        items.add(_buildNotificationItem(
          title: "Tempat Baru Ditemukan!",
          message: message,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationDetailPage(
                title: 'Tempat Baru Ditemukan!',
                subtitle:
                    'Berikut tempat-tempat baru yang baru saja dibagikan oleh pengguna lain:',
                places: otherPosts.take(5).map((u) => Unggahan.fromJson(u)).toList(),
              ),
            ),
          ),
        ));
      }
    }

    if (items.isEmpty) {
      return [
        const SizedBox(height: 60),
        const Center(
          child: Text(
            'Belum ada notifikasi.',
            style: TextStyle(fontFamily: 'Inter', color: Colors.grey, fontSize: 14),
          ),
        ),
      ];
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4AA5A6)))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                children: _buildNotifications(),
              ),
            ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
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
      ),
    );
  }
}
