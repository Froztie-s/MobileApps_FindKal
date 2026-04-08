import 'package:flutter/material.dart';
import 'survey_loading_page.dart';

class _Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  const _Question(this.text, this.options, this.correctIndex);
}

// Placeholder — nanti diganti data dari API
const List<_Question> _questions = [
  _Question(
    'Pertanyaan 1\n"{[Pertanyaan tentang daerahmu akan muncul di sini dari database]}"',
    ['Pilihan A', 'Pilihan B', 'Pilihan C', 'Pilihan D'],
    0,
  ),
  _Question(
    'Pertanyaan 2\n"[Pertanyaan tentang daerahmu akan muncul di sini dari database]"',
    ['Pilihan A', 'Pilihan B', 'Pilihan C', 'Pilihan D'],
    1,
  ),
  _Question(
    'Pertanyaan 3\n"[Pertanyaan tentang daerahmu akan muncul di sini dari database]"',
    ['Pilihan A', 'Pilihan B', 'Pilihan C', 'Pilihan D'],
    2,
  ),
  _Question(
    'Pertanyaan 4\n"[Pertanyaan tentang daerahmu akan muncul di sini dari database]"',
    ['Pilihan A', 'Pilihan B', 'Pilihan C', 'Pilihan D'],
    3,
  ),
  _Question(
    'Pertanyaan 5\n"[Pertanyaan tentang daerahmu akan muncul di sini dari database]"',
    ['Pilihan A', 'Pilihan B', 'Pilihan C', 'Pilihan D'],
    0,
  ),
];

class SurveyQuestionPage extends StatefulWidget {
  const SurveyQuestionPage({super.key});

  @override
  State<SurveyQuestionPage> createState() => _SurveyQuestionPageState();
}

class _SurveyQuestionPageState extends State<SurveyQuestionPage> {
  int _current = 0;
  int? _selected;
  int _correct = 0;

  void _next() {
    if (_selected == null) return;
    if (_selected == _questions[_current].correctIndex) _correct++;

    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SurveyLoadingPage(correctCount: _correct),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_current];
    final progress = (_current + 1) / _questions.length;

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
      color: const Color(0xFF9ACAD0).withOpacity(0.4),
    ),
  ),
),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Kotak pertanyaan — abu muda dengan teks hitam
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      q.text,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Pilihan jawaban 2x2
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.6,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(q.options.length, (i) {
                      final isSelected = _selected == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4AA5A6).withOpacity(0.08)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4AA5A6)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              q.options[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF4AA5A6)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF2D2D2D)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_current + 1} of ${_questions.length}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol lanjut
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selected == null ? null : _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9ACAD0),
                        disabledBackgroundColor:
                            const Color(0xFF9ACAD0).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _current < _questions.length - 1
                            ? 'Pertanyaan berikutnya'
                            : 'Selesai',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
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