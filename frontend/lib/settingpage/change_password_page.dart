import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _currentController.text.isNotEmpty &&
      _newController.text.isNotEmpty &&
      _confirmController.text.isNotEmpty;

  void _onSimpan() async {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kata sandi baru tidak cocok.',
              style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        ),
      );
      return;
    }

    if (newPass == current) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kata sandi baru tidak boleh sama dengan yang lama.',
              style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        ),
      );
      return;
    }

    final userId = AuthState.currentUser?['id'];
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.changePassword(
        userId: userId as int,
        currentPassword: current,
        newPassword: newPass,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message, style: const TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Terjadi kesalahan. Coba lagi.',
              style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF4AA5A6),
                  size: 20,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Ubah kata sandi',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan kata sandi saat ini lalu buat kata sandi baru.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              _buildPasswordField(
                label: 'Kata sandi saat ini',
                controller: _currentController,
                visible: _showCurrent,
                onToggle: () => setState(() => _showCurrent = !_showCurrent),
              ),
              const SizedBox(height: 16),

              _buildPasswordField(
                label: 'Kata sandi baru',
                controller: _newController,
                visible: _showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
              ),
              const SizedBox(height: 16),

              _buildPasswordField(
                label: 'Konfirmasi kata sandi baru',
                controller: _confirmController,
                visible: _showConfirm,
                onToggle: () => setState(() => _showConfirm = !_showConfirm),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canSubmit && !_isLoading ? _onSimpan : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4AA5A6),
                    disabledBackgroundColor: const Color(0xFF9ACAD0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            obscureText: !visible,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  visible ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}
