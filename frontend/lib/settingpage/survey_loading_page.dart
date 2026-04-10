import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import 'survey_result_page.dart';

class SurveyLoadingPage extends StatefulWidget {
  final List<Map<String, dynamic>> answers;
  const SurveyLoadingPage({super.key, required this.answers});

  @override
  State<SurveyLoadingPage> createState() => _SurveyLoadingPageState();
}

class _SurveyLoadingPageState extends State<SurveyLoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _clockCtrl;
  late Animation<double> _pulse;
  late Animation<double> _clock;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _clockCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulse = Tween<double>(begin: 0.92, end: 1.06)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _clock = Tween<double>(begin: 0, end: 1).animate(_clockCtrl);

    _submitAndNavigate();
  }

  Future<void> _submitAndNavigate() async {
    // Run API call and minimum display time in parallel
    final userId = AuthState.currentUser?['id'] as int?;

    final futures = await Future.wait([
      Future.delayed(const Duration(milliseconds: 2800)),
      userId != null
          ? ApiService.submitSurveyAnswers(userId: userId, answers: widget.answers)
              .catchError((e) => <String, dynamic>{'passed': false, 'score': 0, 'error': e.toString()})
          : Future.value(<String, dynamic>{'passed': false, 'score': 0}),
    ]);

    final result = futures[1] as Map<String, dynamic>;

    // Update local auth state if passed
    if (result['passed'] == true && AuthState.currentUser != null) {
      AuthState.currentUser!['is_warga_lokal'] = true;
    }
    // Update attempt info in local state
    if (AuthState.currentUser != null) {
      if (result['locked_until'] != null) {
        AuthState.currentUser!['locked_until'] = result['locked_until'];
      }
      if (result['attempts_remaining'] != null) {
        final used = 3 - (result['attempts_remaining'] as int);
        AuthState.currentUser!['attempts_used'] = used;
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SurveyResultPage(result: result),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _clockCtrl.dispose();
    super.dispose();
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 130,
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, child) => Transform.scale(
                          scale: _pulse.value,
                          child: child,
                        ),
                        child: Positioned(
                          top: 10,
                          left: 10,
                          child: Icon(
                            Icons.hourglass_bottom_rounded,
                            size: 88,
                            color: const Color(0xFF9ACAD0).withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _clock,
                          builder: (_, child) => Transform.rotate(
                            angle: _clock.value * 0.5,
                            child: child,
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            size: 56,
                            color: Color(0xFF4AA5A6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                const Text(
                  'Verifikasi sedang memuat..',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Proses verifikasi mungkin membutuhkan\nwaktu hingga 2 menit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.6,
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
