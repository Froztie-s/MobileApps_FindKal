import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import 'survey_question_page.dart';

class SurveyIntroPage extends StatelessWidget {
  const SurveyIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isVerified = AuthState.isWargaLokal;
    final isLocked = AuthState.isLockedOut;
    final attemptsUsed = AuthState.attemptsUsed;
    final attemptsRemaining = (3 - attemptsUsed).clamp(0, 3);

    String? lockedUntilFormatted;
    if (isLocked && AuthState.lockedUntil != null) {
      final dt = DateTime.tryParse(AuthState.lockedUntil!);
      if (dt != null) {
        lockedUntilFormatted =
            '${dt.day}/${dt.month}/${dt.year} pukul ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          
          // ── TOP CURVED BACKGROUND (SMOOTH) ───────────────────────
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
      color: const Color(0xFF9ACAD0).withOpacity(0.4),
    ),
  ),
),

         

          // ── KONTEN ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Ikon pin lokasi
                SizedBox(
                  width: 90,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Body pin
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4AA5A6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4AA5A6).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      // Ekor pin
                      Positioned(
                        bottom: 0,
                        child: ClipPath(
                          clipper: _PinTailClipper(),
                          child: Container(
                            width: 28,
                            height: 40,
                            color: const Color(0xFF4AA5A6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 44),

                // Status / deskripsi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    isVerified
                        ? 'Kamu sudah menjadi warga lokal terverifikasi. Nikmati akses penuh untuk berbagi tempat favoritmu!'
                        : isLocked
                            ? 'Kamu telah kehabisan percobaan. Coba lagi setelah $lockedUntilFormatted.'
                            : 'Untuk menjaga komunitas kita tetap aman dan bebas dari gangguan bot, kami butuh bantuanmu untuk menjawab 5 pertanyaan singkat tentang daerahmu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: isVerified
                          ? const Color(0xFF4AA5A6)
                          : isLocked
                              ? Colors.red.shade400
                              : const Color(0xFF4AA5A6),
                      height: 1.65,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (!isVerified && !isLocked)
                  Text(
                    'Estimasi waktu : 3 menit  •  Sisa percobaan: $attemptsRemaining dari 3',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),

                const Spacer(flex: 3),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isVerified || isLocked
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SurveyQuestionPage()),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isVerified
                            ? Colors.green.shade400
                            : const Color(0xFF9ACAD0),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: Text(
                        isVerified
                            ? 'Sudah Terverifikasi ✓'
                            : isLocked
                                ? 'Akun Dikunci Sementara'
                                : 'Mulai verifikasi',
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
}

class _PinTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 60);

    // curve kiri
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 40,
    );

    // curve kanan
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 80,
      size.width,
      size.height - 50,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
