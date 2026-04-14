import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import 'ai_trip_detail_page.dart';

class AiTripThemeSelectionPage extends StatefulWidget {
  final String tripName;
  final String duration;
  final String? province;
  final String? city;
  final String? budget;
  final String? budgetId;

  const AiTripThemeSelectionPage({
    super.key,
    required this.tripName,
    required this.duration,
    this.province,
    this.city,
    this.budget,
    this.budgetId,
  });

  @override
  State<AiTripThemeSelectionPage> createState() => _AiTripThemeSelectionPageState();
}

class _AiTripThemeSelectionPageState extends State<AiTripThemeSelectionPage> {
  final List<String> _themes = [
    'Nature',
    'Shopping',
    'Wellness',
    'Entertainment',
    'Food & drinks',
    'Culture & History',
  ];

  final Set<String> _selectedThemes = {};
  bool _isGenerating = false;
  bool _isGenerated = false;
  Map<String, dynamic>? _generatedPlan;

  void _toggleTheme(String theme) {
    setState(() {
      if (_selectedThemes.contains(theme)) {
        _selectedThemes.remove(theme);
      } else {
        _selectedThemes.add(theme);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isGenerating) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset('assets/images/location.png', width: 150),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 64.0,
                  left: 64.0,
                  right: 64.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: Color(0xFFEBEBEB),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4AA5A6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGenerated && _generatedPlan != null) {
      final plan = _generatedPlan!;
      final placeCount = plan['place_count'] as int? ?? 0;
      final vibes = plan['vibes'] as String? ?? '';
      final places = (plan['places'] as List? ?? []).cast<Map<String, dynamic>>();
      final transport = (plan['transport'] as List? ?? []).cast<Map<String, dynamic>>();
      final coverImageUrl = places.isNotEmpty ? places[0]['image_url'] as String? : null;
      final title = widget.tripName.isNotEmpty ? widget.tripName : 'My Trip My Adventure';

      final lokasiParts = [
        ?widget.province,
        ?widget.city,
      ];
      final lokasiLabel = lokasiParts.isNotEmpty ? lokasiParts.join(', ') : '-';

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4AA5A6)),
            onPressed: () => setState(() => _isGenerated = false),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: coverImageUrl != null
                            ? Image.network(
                                coverImageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, e, stack) => _coverPlaceholder(),
                              )
                            : _coverPlaceholder(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Perjalananmu Sudah Siap!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4AA5A6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Terdapat $placeCount tempat yang akan kamu telusuri',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoPill('Lokasi: $lokasiLabel'),
                      const SizedBox(height: 16),
                      _buildInfoPill('Durasi: ${widget.duration} hari'),
                      const SizedBox(height: 16),
                      _buildInfoPill('Budget: ${widget.budget ?? "-"}'),
                      const SizedBox(height: 16),
                      _buildInfoPill('Tema: ${_selectedThemes.join(", ")}'),
                      const SizedBox(height: 16),
                      _buildInfoPill('Vibes: $vibes'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final userId = AuthState.currentUser?['id'];
                      if (userId != null) {
                        try {
                          await ApiService.saveTripPlan(
                            userId: userId as int,
                            name: title,
                            duration: widget.duration,
                            imageUrl: coverImageUrl ??
                                'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80',
                            places: places,
                          );
                        } catch (_) {}
                      }

                      if (!mounted) return;
                      nav.push(
                        MaterialPageRoute(
                          builder: (_) => AiTripDetailPage(
                            tripName: title,
                            places: places,
                            transport: transport,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9CCCD0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lihat detail perjalananmu',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4AA5A6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Tema Perjalanan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih minimal 1 tema yang paling sesuai dengan preferensi liburanmu kali ini.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 16.0,
                      children: _themes.map((theme) {
                        final isSelected = _selectedThemes.contains(theme);
                        return GestureDetector(
                          onTap: () => _toggleTheme(theme),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4AA5A6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF4AA5A6),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  theme,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF4AA5A6),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedThemes.isEmpty
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _isGenerating = true);
                          try {
                            final plan = await ApiService.generateTripPlan(
                              province: widget.province ?? '',
                              city: widget.city,
                              duration: int.tryParse(widget.duration) ?? 1,
                              budgetId: widget.budgetId ?? 'menengah',
                              themes: _selectedThemes.toList(),
                            );
                            if (mounted) {
                              setState(() {
                                _generatedPlan = plan;
                                _isGenerating = false;
                                _isGenerated = true;
                              });
                            }
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _isGenerating = false);
                            messenger.showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedThemes.isEmpty
                        ? Colors.grey.shade400
                        : const Color(0xFF9CCCD0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Generate Rencana Perjalanan',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _coverPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.map, size: 50, color: Colors.grey),
    );
  }

  Widget _buildInfoPill(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4AA5A6)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}
