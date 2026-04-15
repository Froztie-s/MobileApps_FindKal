import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ai_trip_theme_selection_page.dart';

const String _apiBase = 'https://api-regional-indonesia.vercel.app/api';

class AiTripPlanPage extends StatefulWidget {
  const AiTripPlanPage({super.key});

  @override
  State<AiTripPlanPage> createState() => _AiTripPlanPageState();
}

class _AiTripPlanPageState extends State<AiTripPlanPage> {
  final _nameController = TextEditingController();
  final _durationController = TextEditingController(text: '1');

  String? _selectedBudget;       // display label
  String? _selectedBudgetId;     // id sent to API

  // Location state
  String? _selectedProvinceId;
  String? _selectedProvince;
  String? _selectedCity;

  List<Map<String, String>> _provinces = [];
  List<Map<String, String>> _cities = [];

  bool _loadingProvinces = false;
  bool _loadingCities = false;

  bool get _canProceed =>
      _nameController.text.trim().isNotEmpty &&
      _selectedProvince != null &&
      _selectedBudgetId != null;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<List<Map<String, String>>> _fetch(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => {'id': e['id'].toString(), 'name': e['name'].toString()})
        .toList();
  }

  Future<void> _loadProvinces() async {
    setState(() => _loadingProvinces = true);
    try {
      final list = await _fetch('$_apiBase/provinces');
      setState(() => _provinces = list);
    } catch (_) {
    } finally {
      setState(() => _loadingProvinces = false);
    }
  }

  Future<void> _onProvinceChanged(String id, String name) async {
    setState(() {
      _selectedProvinceId = id;
      _selectedProvince = name;
      _selectedCity = null;
      _cities = [];
      _loadingCities = true;
    });

    if (name.toLowerCase() != 'banten') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Saat ini dalam mode demo, hanya Provinsi Banten yang tersedia.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13),
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    try {
      final list = await _fetch('$_apiBase/cities/$id');
      setState(() => _cities = list);
    } catch (_) {
    } finally {
      setState(() => _loadingCities = false);
    }
  }

  void _onCityChanged(String id, String name) {
    setState(() {
      _selectedCity = name;
    });
  }

  @override
  Widget build(BuildContext context) {

    // ── Form ──────────────────────────────────────────────────────────────
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
                      'Mulai Rencanakan Perjalananmu',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Biarkan AI yang membantu merencanakan\nperjalananmu kali ini.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildTextField(label: 'Nama perjalanan', controller: _nameController),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      label: 'Provinsi',
                      items: _provinces,
                      value: _selectedProvince,
                      loading: _loadingProvinces,
                      onChanged: (id, name) => _onProvinceChanged(id, name),
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      label: 'Kota (Opsional)',
                      items: _cities,
                      value: _selectedCity,
                      loading: _loadingCities,
                      onChanged: _selectedProvinceId != null
                          ? (id, name) => _onCityChanged(id, name)
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'Durasi (hari)',
                      controller: _durationController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      label: 'Budget (Per hari)',
                      items: [
                        {'id': 'hemat',    'name': '💸 Hemat — < Rp100.000'},
                        {'id': 'budget',   'name': '💵 Budget — Rp100.000 – Rp300.000'},
                        {'id': 'menengah', 'name': '💳 Menengah — Rp300.000 – Rp700.000'},
                        {'id': 'premium',  'name': '💎 Premium — Rp700.000 – Rp1.500.000'},
                        {'id': 'luxury',   'name': '🏝 Luxury — > Rp1.500.000'},
                      ],
                      value: _selectedBudget,
                      onChanged: (id, name) {
                        setState(() {
                          _selectedBudgetId = id;
                          _selectedBudget = name;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama perjalanan harus diisi.')),
                      );
                      return;
                    }
                    if (_selectedProvince == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Provinsi harus dipilih.')),
                      );
                      return;
                    }
                    if (_selectedBudgetId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget harus dipilih.')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AiTripThemeSelectionPage(
                          tripName: _nameController.text,
                          duration: _durationController.text,
                          province: _selectedProvince,
                          city: _selectedCity,
                          budget: _selectedBudget,
                          budgetId: _selectedBudgetId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canProceed
                        ? const Color(0xFF9CCCD0)
                        : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lanjutkan',
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4AA5A6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey)),
          TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 4, bottom: 4),
            ),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<Map<String, String>> items,
    required String? value,
    required void Function(String id, String name)? onChanged,
    bool loading = false,
  }) {
    final bool enabled = !loading && items.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4AA5A6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey)),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4AA5A6)),
              ),
            )
          else
            SizedBox(
              height: 24,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: value,
                  hint: Text(
                    enabled ? 'Pilih $label' : '',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black54),
                  ),
                  icon: const Icon(Icons.unfold_more, size: 20, color: Colors.black54),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: enabled
                      ? (selectedName) {
                          if (selectedName == null) return;
                          final item = items.firstWhere((e) => e['name'] == selectedName);
                          onChanged!(item['id']!, item['name']!);
                        }
                      : null,
                  items: items
                      .map((e) => DropdownMenuItem<String>(
                            value: e['name'],
                            child: Text(e['name']!, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
