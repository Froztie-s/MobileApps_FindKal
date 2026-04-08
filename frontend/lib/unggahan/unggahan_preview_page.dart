import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_state.dart';
import '../services/api_service.dart';
import '../homepage/home.dart';

class UnggahanPreviewPage extends StatefulWidget {
  final List<XFile> images;
  final String locationName;
  final int rating;
  final String address;
  final String review;
  final String budget;

  const UnggahanPreviewPage({
    super.key,
    required this.images,
    required this.locationName,
    required this.rating,
    required this.address,
    required this.review,
    required this.budget,
  });

  @override
  State<UnggahanPreviewPage> createState() => _UnggahanPreviewPageState();
}

class _UnggahanPreviewPageState extends State<UnggahanPreviewPage> {
  Future<void> _uploadFn() async {
    final userId = AuthState.currentUser?['id'] as int?;
    if (userId == null) throw const ApiException('User tidak ditemukan.');

    await ApiService.uploadUnggahan(
      userId: userId,
      namaTempat: widget.locationName,
      alamat: widget.address,
      ulasan: widget.review,
      rating: widget.rating,
      budget: widget.budget,
      imagePaths: widget.images.map((x) => x.path).toList(),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Yakin untuk unggah\npostingan ini?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Ya, unggah
                          Navigator.pop(dialogContext, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4AA5A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Ya, unggah",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Batal
                          Navigator.pop(dialogContext, false);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        // Go back to home page (index 2 for profile) and pass pending callback
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(initialIndex: 2, pendingUpload: _uploadFn),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4AA5A6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF4AA5A6),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AuthState.currentUser?['name'] ?? 'Nama Pengguna',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter', fontSize: 16),
                    ),
                    Text(
                      "@${AuthState.currentUser?['username'] ?? 'username'}",
                      style: TextStyle(color: Colors.grey.shade500, fontFamily: 'Inter', fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Collages
            _buildImageCollage(),
            const SizedBox(height: 16),

            // Location Name and Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.locationName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4AA5A6),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < widget.rating ? Colors.amber : Colors.grey.shade300,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Address
            const Text("Alamat", style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4AA5A6))),
            const SizedBox(height: 4),
            Text(widget.address, style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
            const SizedBox(height: 16),

            // Review
            const Text("Ulasan", style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4AA5A6))),
            const SizedBox(height: 4),
            Text(widget.review, style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
            const SizedBox(height: 16),

            // Budget
            const Text("Budget per orang", style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4AA5A6))),
            const SizedBox(height: 4),
            Text(widget.budget, style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
        decoration: const BoxDecoration(color: Colors.white),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _showConfirmDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9ACAD0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text(
              "Unggah",
              style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCollage() {
    if (widget.images.isEmpty) return const SizedBox();

    final files = widget.images.map((x) => File(x.path)).toList();

    if (files.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(files[0], width: double.infinity, height: 260, fit: BoxFit.cover),
      );
    } else if (files.length == 2) {
      return SizedBox(
        height: 260,
        child: Row(
          children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)), child: Image.file(files[0], height: 260, fit: BoxFit.cover))),
            const SizedBox(width: 4),
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)), child: Image.file(files[1], height: 260, fit: BoxFit.cover))),
          ],
        ),
      );
    } else if (files.length == 3) {
      return SizedBox(
        height: 260,
        child: Row(
          children: [
            Expanded(
              flex: 1, 
              child: Column(
                children: [
                  Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)), child: Image.file(files[0], width: double.infinity, fit: BoxFit.cover))),
                  const SizedBox(height: 4),
                  Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)), child: Image.file(files[1], width: double.infinity, fit: BoxFit.cover))),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 1, 
              child: ClipRRect(borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)), child: Image.file(files[2], height: 260, fit: BoxFit.cover))
            ),
          ],
        ),
      );
    } else { // 4 images
      return SizedBox(
        height: 260,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)), child: Image.file(files[0], width: double.infinity, fit: BoxFit.cover))),
                  const SizedBox(width: 4),
                  Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(topRight: Radius.circular(12)), child: Image.file(files[1], width: double.infinity, fit: BoxFit.cover))),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)), child: Image.file(files[2], width: double.infinity, fit: BoxFit.cover))),
                  const SizedBox(width: 4),
                  Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)), child: Image.file(files[3], width: double.infinity, fit: BoxFit.cover))),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
