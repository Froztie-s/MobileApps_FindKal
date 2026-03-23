import 'dart:async';
import 'package:flutter/material.dart';
import 'register_address.dart';
import 'services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _sendingOtp = false;
  bool _isEmailVerified = false;
  String _verifiedEmail = '';

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (_isEmailVerified &&
          _emailController.text.trim() != _verifiedEmail) {
        setState(() => _isEmailVerified = false);
      }
    });
  }

  Future<void> _onVerifyTapped() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Masukkan email terlebih dahulu.', style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: const Color(0xFF4A4A4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        ),
      );
      return;
    }

    setState(() => _sendingOtp = true);
    try {
      await ApiService.sendVerificationEmail(email);
      if (!mounted) return;
      
      final verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _VerificationDialog(email: email);
        },
      );

      if (verified == true) {
        setState(() {
          _isEmailVerified = true;
          _verifiedEmail = email;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Email berhasil diverifikasi! ✓',
              style: TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: const Color(0xFF4AA5A6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
          content: const Text('Terjadi kesalahan. Coba lagi.', style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        ),
      );
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  void _onSelanjutnyaTapped() {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final errors = <String>[];

    if (name.isEmpty) errors.add('Nama lengkap wajib diisi.');
    if (username.isEmpty) errors.add('Username wajib diisi.');

    if (password.isEmpty) {
      errors.add('Password wajib diisi.');
    } else {
      if (password.length < 8) errors.add('Password terlalu pendek. Harus minimal 8 karakter.');
      if (RegExp(r'^\d+$').hasMatch(password)) errors.add('Password tidak boleh hanya berisi angka.');
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errors.join(' '),
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterAddressPage(
          name: name,
          username: username,
          password: password,
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Sign up Heading
              const Text(
                "Sign up",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 25),

              // Full Name Field
              const Text(
                "Nama lengkap",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
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
              ),
              const SizedBox(height: 16),

              // Username Field
              const Text(
                "Username",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _usernameController,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
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
              ),
              const SizedBox(height: 16),

              // Password Field
              const Text(
                "Password",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
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
              ),
              const SizedBox(height: 16),

              // Email Field + Verify Button
              const Text(
                "Email",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    // Email Input
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    // Verify Button
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: InkWell(
                        onTap: _sendingOtp ? null : _onVerifyTapped,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isEmailVerified
                                ? const Color(0xFF4AA5A6)
                                : const Color(0xFF9ACAD0),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.black54,
                              width: 0.5,
                            ),
                          ),
                          child: _sendingOtp
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : _isEmailVerified
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : const Text(
                                      "verify",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Button Selanjutnya — only enabled after email is verified
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isEmailVerified ? _onSelanjutnyaTapped : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA5D1D6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Selanjutnya",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sudah Punya Akun Link
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  child: const Text(
                    "Sudah punya akun? Masuk",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF4AA5A6),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF4AA5A6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationDialog extends StatefulWidget {
  final String email;

  const _VerificationDialog({required this.email});

  @override
  State<_VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<_VerificationDialog> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _verifying = false;
  bool _resending = false;
  Timer? _timer;
  int _start = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _start = 30);
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _onVerify() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length < 6) return;

    setState(() => _verifying = true);
    try {
      await ApiService.verifyEmailCode(widget.email, code);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message, style: const TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => _verifying = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Coba lagi.', style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => _verifying = false);
    }
  }

  Future<void> _onResend() async {
    if (_resending) return;
    setState(() => _resending = true);
    try {
      await ApiService.resendVerificationEmail(widget.email);
      if (!mounted) return;
      _startTimer();
    } catch (_) {
      if (!mounted) return;
      // error resending
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Verifikasi email kamu",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context, false),
                  child: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Kami telah mengirim 6 digit kode ke email kamu",
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return Container(
                  width: 40,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: "",
                      ),
                      onChanged: (value) => _onCodeChanged(value, index),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tidak menerima kode?",
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _start == 0 ? _onResend : null,
                      child: Text(
                        "Kirim kode baru",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: const Color(0xFF4AA5A6),
                          decoration: _start == 0 ? TextDecoration.underline : TextDecoration.none,
                          decorationColor: const Color(0xFF4AA5A6),
                        ),
                      ),
                    ),
                    if (_start > 0)
                      Text(
                        " dalam 00:${_start.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.black87),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  onPressed: _verifying ? null : _onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9ACAD0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _verifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Verify",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
}
