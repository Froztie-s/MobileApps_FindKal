import 'dart:io';
import 'package:flutter/material.dart';
import 'models/unggahan.dart';
import 'services/api_service.dart';
import 'services/auth_state.dart';

class UnggahanDetailPage extends StatelessWidget {
  final Unggahan unggahan;

  const UnggahanDetailPage({super.key, required this.unggahan});

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
              "Unggahan",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          BookmarkButton(unggahan: unggahan),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage: _getAvatarImage(),
                  child: _getAvatarImage() == null
                      ? const Icon(Icons.person, color: Colors.white, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unggahan.userName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      unggahan.usernameHandle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildImageGallery(context),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    unggahan.placeName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4AA5A6),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < unggahan.rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFD700),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Alamat",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4AA5A6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unggahan.address,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ulasan",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4AA5A6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unggahan.review,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Budget per orang",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4AA5A6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unggahan.budget,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
        ),
      ),
    );
  }

  ImageProvider _imageProvider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    return FileImage(File(path));
  }

  ImageProvider? _getAvatarImage() {
    final user = AuthState.currentUser ?? {};
    final isCurrentUser = unggahan.usernameHandle.replaceAll('@', '') == user['username'];
    
    String? avatarSource = unggahan.userAvatar;
    if (isCurrentUser && user['profile_photo'] != null) {
      avatarSource = user['profile_photo'] as String;
    }

    if (avatarSource != null && avatarSource.isNotEmpty) {
      return _imageProvider(avatarSource);
    }
    return null;
  }

  Widget _buildClickableImage(BuildContext context, int index, {double? width, double? height}) {
    final path = unggahan.imagePaths[index];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageViewer(
              imagePaths: unggahan.imagePaths,
              initialIndex: index,
            ),
          ),
        );
      },
      child: path.startsWith('http')
          ? Image.network(path, fit: BoxFit.cover, width: width, height: height)
          : Image.asset(path, fit: BoxFit.cover, width: width, height: height),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    int imageCount = unggahan.imagePaths.length;
    if (imageCount == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildClickableImage(context, 0, width: double.infinity, height: 250),
      );
    } else if (imageCount == 2) {
      return Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildClickableImage(context, 0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildClickableImage(context, 1),
              ),
            ),
          ),
        ],
      );
    } else if (imageCount == 3) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildClickableImage(context, 0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AspectRatio(
                    aspectRatio: 1.4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildClickableImage(context, 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildClickableImage(context, 2),
              ),
            ),
          ],
        ),
      );
    } else if (imageCount >= 4) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildClickableImage(context, 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildClickableImage(context, 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildClickableImage(context, 2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildClickableImage(context, 3),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          '${_currentIndex + 1} / ${widget.imagePaths.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: widget.imagePaths[index].startsWith('http')
                ? Image.network(widget.imagePaths[index], fit: BoxFit.contain, width: double.infinity, height: double.infinity)
                : Image.asset(widget.imagePaths[index], fit: BoxFit.contain, width: double.infinity, height: double.infinity),
          );
        },
      ),
    );
  }
}

class BookmarkButton extends StatefulWidget {
  final Unggahan unggahan;

  const BookmarkButton({super.key, required this.unggahan});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool isBookmarked = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF4AA5A6),
              ),
            )
          : Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: const Color(0xFF4AA5A6),
              size: 28,
            ),
      onPressed: _loading ? null : _toggle,
    );
  }

  Future<void> _toggle() async {
    final userId = AuthState.currentUser?['id'];
    final unggahanId = widget.unggahan.id;
    if (userId == null || unggahanId == null) return;

    setState(() => _loading = true);
    try {
      if (isBookmarked) {
        await ApiService.removeBookmark(userId as int, unggahanId);
      } else {
        await ApiService.addBookmark(userId as int, unggahanId);
      }
      if (!mounted) return;
      setState(() => isBookmarked = !isBookmarked);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBookmarked ? 'Disimpan ke Markah' : 'Dihapus dari Markah',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF4AA5A6),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal. Coba lagi.', style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
