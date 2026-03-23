import 'package:flutter/material.dart';
import 'services/auth_state.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = AuthState.currentUser ?? {};
    final name = user['name'] ?? "user";
    final username = user['username'] ?? "username";
    final bio = user['bio'] ?? "Belum ada bio";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Action Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_border, size: 30, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 30, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profile Image
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF4AA5A6),
            backgroundImage: user['profile_photo'] != null ? NetworkImage(user['profile_photo']) : null,
            child: user['profile_photo'] == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
          ),
          const SizedBox(height: 16),

          // Name and Username
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "@$username",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),

          // Bio Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              bio,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Edit Profil Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
                if (result == true) {
                  setState(() {}); // Refresh UI with new data
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5AB2B2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Edit Profil",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Posts Section Title
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Postingan yang sudah pernah dibagikan",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Post Placeholder Container
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}