import 'package:flutter/material.dart';
import 'services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Curved Header Section
          Stack(
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9ACAD0), // Bottom layer (peeks out)
                  ),
                ),
              ),
              ClipPath(
                clipper: HeaderClipperSecondary(),
                child: Container(
                  height: 85,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4FA8A4), // Top layer overlay
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Welcome Text
          const Text(
            "Selamat Datang!",
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Masuk untuk mengakses layanan Anda",
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 60),

          // Form Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Username atau Email",
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(fontFamily: 'Arial', fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Kata sandi",
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontFamily: 'Arial', fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final identifier = _usernameController.text.trim();
                      final password = _passwordController.text;

                      if (identifier.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Username/Email dan kata sandi wajib diisi.', style: TextStyle(fontFamily: 'Inter')),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
                          ),
                        );
                        return;
                      }

                      try {
                        final user = await ApiService.login(identifier, password);
                        if (!mounted) return;
                        // Navigate to Home Page
                        Navigator.pushReplacementNamed(context, '/home');
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
                      } catch (e) {
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA5D1D6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Masuk",
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/reset-password');
                    },
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    child: const Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF4AA5A6),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF4AA5A6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Link
          Center(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: const Text(
                "Belum punya akun? Daftar sekarang!",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF4AA5A6),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF4AA5A6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

// Custom Clippers for the header waves
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeaderClipperSecondary extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 70,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
