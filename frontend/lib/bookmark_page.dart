import 'package:flutter/material.dart';
import 'models/unggahan.dart';
import 'services/api_service.dart';
import 'services/auth_state.dart';
import 'unggahan_detail_page.dart';

// ── Main Page ────────────────────────────────────────────────────────────────
class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Unggahan> _bookmarks = [];
  List<Unggahan> _filtered = [];
  bool _isEditMode = false;
  bool _loading = true;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookmarks() async {
    final userId = AuthState.currentUser?['id'];
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await ApiService.fetchBookmarks(userId as int);
      final list = data.map((j) => Unggahan.fromJson(j)).toList();
      if (mounted) {
        setState(() {
          _bookmarks = list;
          _filtered = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filtered = List.from(_bookmarks);
      } else {
        _filtered = _bookmarks
            .where((b) =>
                b.placeName.toLowerCase().contains(query.trim().toLowerCase()))
            .toList();
      }
    });
  }

  // ── Edit mode ──────────────────────────────────────────────────────────────
  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
      _selectedIds.clear();
    });
  }

  void _exitEditMode() {
    setState(() {
      _isEditMode = false;
      _selectedIds.clear();
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _filtered.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_filtered.map((b) => b.id!));
      }
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Yakin hapus daftar tempat\nyang dipilih?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _deleteSelected();
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Ya, hapus tempat',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSelected() async {
    final userId = AuthState.currentUser?['id'];
    if (userId == null) return;
    for (final id in _selectedIds) {
      try {
        await ApiService.removeBookmark(userId as int, id);
      } catch (_) {}
    }
    setState(() {
      _bookmarks.removeWhere((b) => _selectedIds.contains(b.id));
      _filtered.removeWhere((b) => _selectedIds.contains(b.id));
      _selectedIds.clear();
      _isEditMode = false;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool allSelected =
        _filtered.isNotEmpty && _selectedIds.length == _filtered.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── APP BAR ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  if (!_isEditMode) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF4AA5A6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Text(
                    'Markah',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // ── SEARCH BAR ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF4AA5A6),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search, color: Color(0xFF4AA5A6), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Cari tempat',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── STATUS BAR (normal / edit mode) ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _isEditMode
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pilih semua
                        GestureDetector(
                          onTap: _selectAll,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: allSelected
                                  ? const Color(0xFF4AA5A6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF4AA5A6),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              'Pilih semua',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: allSelected
                                    ? Colors.white
                                    : const Color(0xFF4AA5A6),
                              ),
                            ),
                          ),
                        ),
                        // Batalkan
                        GestureDetector(
                          onTap: _exitEditMode,
                          child: const Text(
                            'Batalkan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4AA5A6),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          _searchController.text.trim().isEmpty
                              ? 'Berikut daftar tempat yang sudah disimpan. '
                              : 'Hasil pencarian (${_filtered.length} dari ${_bookmarks.length} ditemukan)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_searchController.text.trim().isEmpty)
                          GestureDetector(
                            onTap: _enterEditMode,
                            child: const Text(
                              'Edit daftar tempat.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4AA5A6),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF4AA5A6),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),

            // ── LIST ───────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4AA5A6)),
                    )
                  : _bookmarks.isEmpty
                      ? _buildEmptyState()
                      : _filtered.isEmpty
                          ? _buildNoResult()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: _filtered.length,
                              itemBuilder: (context, index) {
                                final item = _filtered[index];
                                final isSelected = _selectedIds.contains(item.id);
                                return _buildCard(item, isSelected);
                              },
                            ),
            ),
          ],
        ),
      ),

      // ── BOTTOM DELETE BAR (edit mode) ──────────────────────────────
      bottomSheet: _isEditMode
          ? GestureDetector(
              onTap: _selectedIds.isEmpty ? null : _showDeleteDialog,
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFF4AA5A6).withOpacity(0.4),
                        width: 2.5,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete_rounded,
                        size: 24,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hapus item yang dipilih',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
              ),
            )
          : null,
    );
  }

  // ── Card ───────────────────────────────────────────────────────────────────
  Widget _buildCard(Unggahan item, bool isSelected) {
    final firstImage = item.imagePaths.isNotEmpty ? item.imagePaths.first : null;

    return GestureDetector(
      onTap: _isEditMode
          ? () => _toggleSelect(item.id!)
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UnggahanDetailPage(unggahan: item),
                ),
              );
            },
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF4AA5A6), width: 2.5)
              : null,
        ),
        child: Stack(
          children: [
            // Image area
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: firstImage != null
                  ? Image.network(
                      firstImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Icon(Icons.image_outlined,
                              size: 40, color: Colors.white.withOpacity(0.6)),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Icon(Icons.image_outlined,
                            size: 40, color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
            ),

            // Gradient overlay bawah
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Nama tempat
            Positioned(
              bottom: 14,
              left: 14,
              child: Text(
                item.placeName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Checklist (edit mode)
            if (_isEditMode)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4AA5A6)
                        : Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4AA5A6)
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.search, size: 80, color: Colors.grey.shade300),
              Positioned(
                bottom: 4,
                right: 4,
                child: Icon(Icons.close, size: 30, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Kamu belum menyimpan\ntempat apa pun!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ── No search result ───────────────────────────────────────────────────────
  Widget _buildNoResult() {
    return Center(
      child: Text(
        'Tidak ada hasil untuk\n"${_searchController.text}"',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
