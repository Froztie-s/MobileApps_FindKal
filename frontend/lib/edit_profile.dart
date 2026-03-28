import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/auth_state.dart';
import 'models/edit_profile_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final ImagePicker _picker = ImagePicker();

  XFile? _newPhoto;
  bool _photoDeleted = false;

  @override
  void initState() {
    super.initState();
    final user = AuthState.currentUser ?? {};
    _nameController = TextEditingController(text: user['name'] ?? 'user');
    _bioController = TextEditingController(text: user['bio'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ── Photo helpers ──────────────────────────────────────────────────────────

  String? get _existingPhotoUrl => AuthState.currentUser?['profile_photo'] as String?;

  bool get _hasAnyPhoto =>
      _newPhoto != null || (!_photoDeleted && _existingPhotoUrl != null);

  void _onPhotoTap() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF4AA5A6)),
              title: const Text('Pilih dari galeri',
                  style: TextStyle(fontFamily: 'Inter')),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (_hasAnyPhoto)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Hapus foto profil',
                    style: TextStyle(
                        fontFamily: 'Inter', color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _newPhoto = null;
                    _photoDeleted = true;
                  });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _newPhoto = file;
          _photoDeleted = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka galeri: $e',
              style: const TextStyle(fontFamily: 'Inter')),
        ),
      );
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  EditProfileModel get _currentModel => EditProfileModel(
        name: _nameController.text,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text,
        existingPhotoUrl: _existingPhotoUrl,
        newPhoto: _newPhoto,
        photoDeleted: _photoDeleted,
      );

  void _saveProfile() {
    final model = _currentModel;
    if (AuthState.currentUser != null) {
      AuthState.currentUser!['name'] = model.name.trim();
      AuthState.currentUser!['bio'] = model.bio;
      if (model.photoDeleted) {
        AuthState.currentUser!['profile_photo'] = null;
      } else if (model.newPhoto != null) {
        // Store the local path temporarily; replace with upload URL in production
        AuthState.currentUser!['profile_photo'] = model.newPhoto!.path;
      }
    }
    debugPrint(model.toString());
    Navigator.pop(context, true);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile photo ────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _onPhotoTap,
                child: Stack(
                  children: [
                    _buildAvatar(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF4AA5A6),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Name ────────────────────────────────────────────────
            const Text(
              'Profil',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            const SizedBox(height: 24),

            // ── Bio ──────────────────────────────────────────────────
            const Text(
              'Biografi',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: Color(0xFF4AA5A6), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            const SizedBox(height: 48),

            // ── Save button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9ACAD0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    ImageProvider? imageProvider;

    if (_newPhoto != null) {
      imageProvider = FileImage(File(_newPhoto!.path));
    } else if (!_photoDeleted && _existingPhotoUrl != null) {
      imageProvider = NetworkImage(_existingPhotoUrl!);
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: const Color(0xFF4AA5A6),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? const Icon(Icons.person, size: 50, color: Colors.white)
          : null,
    );
  }
}