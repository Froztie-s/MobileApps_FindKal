import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_state.dart';
import 'unggahan_preview_page.dart';

class BuatUnggahanPage extends StatefulWidget {
  const BuatUnggahanPage({super.key});

  @override
  State<BuatUnggahanPage> createState() => _BuatUnggahanPageState();
}

class _BuatUnggahanPageState extends State<BuatUnggahanPage> {
  int _selectedRating = 0;
  String _selectedBudget = "";
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _selectedImages.isNotEmpty &&
      _selectedRating > 0 &&
      _nameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty &&
      _reviewController.text.trim().isNotEmpty &&
      _selectedBudget.isNotEmpty;

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maksimal 4 gambar dapat dipilih", style: TextStyle(fontFamily: 'Inter'))),
      );
      return;
    }

    int remaining = 4 - _selectedImages.length;
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          if (pickedFiles.length > remaining) {
            _selectedImages.addAll(pickedFiles.sublist(0, remaining));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Hanya 4 gambar pertama yang ditambahkan", style: TextStyle(fontFamily: 'Inter'))),
            );
          } else {
            _selectedImages.addAll(pickedFiles);
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuka galeri: Pastikan aplikasi sudah di-restart ulang secara penuh (Stop & Run). Error: $e", style: const TextStyle(fontFamily: 'Inter'))),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _onBudgetSelected(String budget) {
    setState(() {
      _selectedBudget = budget;
    });
  }

  void _onRatingSelected(int rating) {
    setState(() {
      _selectedRating = rating;
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
        title: const Text(
          "Buat unggahan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User section
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
                      AuthState.currentUser?['name'] ?? "Zaenal Yudha Zala",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                    ),
                    Text(
                      "@${AuthState.currentUser?['username'] ?? 'username'}",
                      style: TextStyle(color: Colors.grey.shade500, fontFamily: 'Inter', fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Gambar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Gambar", style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
                if (_selectedImages.isNotEmpty && _selectedImages.length < 4)
                  GestureDetector(
                    onTap: _pickImages,
                    child: const Text("+ Tambah", style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF4AA5A6), fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedImages.isEmpty)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade400, width: 0.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.add_photo_alternate, color: Colors.grey, size: 40),
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12, top: 8),
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                              image: FileImage(File(_selectedImages[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => _onRatingSelected(index + 1),
                  icon: Icon(
                    Icons.star,
                    color: index < _selectedRating ? Colors.amber : Colors.grey.shade300,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Form inputs
            const Text("Nama tempat", style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
            const SizedBox(height: 8),
            _buildTextField(controller: _nameController),
            const SizedBox(height: 16),

            const Text("Alamat", style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
            const SizedBox(height: 8),
            _buildTextField(maxLines: 2, controller: _addressController),
            const SizedBox(height: 16),

            const Text("Ulasan", style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
            const SizedBox(height: 8),
            _buildTextField(maxLines: 2, controller: _reviewController),
            const SizedBox(height: 24),

            // Budget
            const Text(
              "Berapa budget yang kamu untuk pergi ke sini (per orang)?",
              style: TextStyle(fontFamily: 'Inter', fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBudgetChip("Rp 1k - Rp 50k"),
                _buildBudgetChip("Rp 50k - Rp 100k"),
                _buildBudgetChip("Rp 100k - Rp 150k"),
                _buildBudgetChip("Rp 150k - Rp 200k"),
                _buildBudgetChip("Rp 250k+"),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isFormValid ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UnggahanPreviewPage(
                  images: _selectedImages,
                  locationName: _nameController.text,
                  rating: _selectedRating,
                  address: _addressController.text,
                  review: _reviewController.text,
                  budget: _selectedBudget,
                ),
              ),
            );
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9ACAD0),
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: Text(
            "Lanjutkan",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isFormValid ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    ),
  ],
),
      ),
    );
  }

  Widget _buildTextField({int maxLines = 1, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4AA5A6)),
        ),
      ),
    );
  }

  Widget _buildBudgetChip(String text) {
    final isSelected = _selectedBudget == text;
    return InkWell(
      onTap: () => _onBudgetSelected(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4AA5A6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4AA5A6) : Colors.grey.shade400,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
