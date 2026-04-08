import 'package:flutter/material.dart';
import 'enter_code.dart';
import '../services/api_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _onLanjutkanTapped() async {
    final identifier = _inputController.text.trim();
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Masukkan username atau email terlebih dahulu.',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: const Color(0xFF4A4A4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final email = await ApiService.requestPasswordReset(identifier);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnterCodePage(
            email: email,
            mode: EnterCodeMode.passwordReset,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message, style: const TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Terjadi kesalahan. Coba lagi.',
              style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4AA5A6),
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Cari akun kamu",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Masukkan username atau email",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Username atau Email",
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFF4AA5A6)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _onLanjutkanTapped,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA5D1D6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        "Lanjutkan",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
