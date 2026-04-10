import 'package:flutter/material.dart';

class SurveyResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const SurveyResultPage({super.key, required this.result});

  bool get _success => result['passed'] == true;
  int get _score => (result['score'] as int?) ?? 0;
  int get _attemptsRemaining => (result['attempts_remaining'] as int?) ?? 0;
  String? get _lockedUntil => result['locked_until'] as String?;

  String get _failMessage {
    if (_lockedUntil != null) {
      final dt = DateTime.tryParse(_lockedUntil!);
      final formatted = dt != null
          ? '${dt.day}/${dt.month}/${dt.year} pukul ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}'
          : _lockedUntil!;
      return 'Kamu menjawab $_score dari 5 pertanyaan dengan benar. '
          'Kamu telah kehabisan percobaan. Coba lagi setelah $formatted.';
    }
    return 'Kamu menjawab $_score dari 5 pertanyaan dengan benar. '
        'Minimal 4 jawaban benar diperlukan untuk menjadi warga lokal terverifikasi. '
        'Sisa percobaan: $_attemptsRemaining.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFF4AA5A6),
            ),
          ),
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                height: 240,
                color: const Color(0xFF9ACAD0).withValues(alpha: 0.4),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                _success ? _buildSuccessIllustration() : _buildFailIllustration(),
                const SizedBox(height: 36),
                Text(
                  _success ? 'Verifikasi Berhasil!' : 'Verifikasi Gagal',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _success ? Colors.black87 : Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _success
                        ? 'Identitas kamu sudah terverifikasi. Sekarang kamu punya akses penuh untuk berbagi moment.'
                        : _failMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.65,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9ACAD0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _success ? 'Mulai Eksplorasi' : 'Kembali ke Beranda',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIllustration() {
    return SizedBox(
      width: 160,
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 120,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF2D6B6B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 14,
                    top: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 32,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 10,
                    child: Column(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 34,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(17),
                              topRight: Radius.circular(17),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF4AA5A6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4AA5A6).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailIllustration() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Icon(Icons.close_rounded, size: 56, color: Colors.red.shade400),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(size.width * 0.75, size.height - 80, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
