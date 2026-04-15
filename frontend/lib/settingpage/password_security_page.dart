import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';

class PasswordSecurityPage extends StatefulWidget {
  const PasswordSecurityPage({super.key});

  @override
  State<PasswordSecurityPage> createState() => _PasswordSecurityPageState();
}

class _PasswordSecurityPageState extends State<PasswordSecurityPage> {
  void _showDeleteAccountDialog() {
    final user = AuthState.currentUser ?? {};
    final name = user['name'] ?? 'User';
    final email = user['email'] ?? 'email@gmail.com';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yakin untuk hapus akun kamu?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // User info box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF4AA5A6),
                      child: const Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Tidak perlu masukan email atau ingat password lagi! Login lebih mudah dan aman dengan simpan info login-mu.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  // Ya, hapus
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        AuthState.currentUser = null;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Ya, hapus',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Batalkan
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Text(
                            'Batalkan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthState.currentUser ?? {};
    final email = user['email'] ?? 'email@gmail.com';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4AA5A6),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          'Password & Keamanan',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
        children: [
          // ── ROW EMAIL ──────────────────────────────────────────────
          _buildRow(
            label: 'Alamat email',
            value: email,
            onEdit: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangeEmailPage(),
                ),
              );
              if (updated == true && mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Alamat email kamu sudah berhasil terganti dengan alamat email baru',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    backgroundColor: const Color(0xFF4AA5A6),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── ROW PASSWORD ───────────────────────────────────────────
          _buildRow(
            label: 'Kata sandi',
            value: '••••••••••',
            onEdit: () async {
              final messenger = ScaffoldMessenger.of(context);
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordPage(),
                ),
              );
              if (updated == true && mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Kata sandi kamu sudah berhasil diubah.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    backgroundColor: const Color(0xFF4AA5A6),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          const SizedBox(height: 20),

          // ── HAPUS AKUN ─────────────────────────────────────────────
          GestureDetector(
            onTap: _showDeleteAccountDialog,
            child: const Text(
              'Hapus akun',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
