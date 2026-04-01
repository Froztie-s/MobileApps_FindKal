import 'package:flutter/material.dart';

// ── Model sederhana untuk item bookmark ─────────────────────────────────────
class _BookmarkItem {
  final String id;
  final String name;
  final Color placeholderColor;

  const _BookmarkItem({
    required this.id,
    required this.name,
    required this.placeholderColor,
  });
}

// ── Dummy data placeholder ───────────────────────────────────────────────────
final List<_BookmarkItem> _dummyBookmarks = [
  _BookmarkItem(id: '1', name: 'Nama Tempat 1', placeholderColor: Colors.blueGrey),
  _BookmarkItem(id: '2', name: 'Nama Tempat 2', placeholderColor: Colors.teal),
  _BookmarkItem(id: '3', name: 'Nama Tempat 3', placeholderColor: Colors.indigo),
  _BookmarkItem(id: '4', name: 'Nama Tempat 4', placeholderColor: Colors.brown),
  _BookmarkItem(id: '5', name: 'Nama Tempat 5', placeholderColor: Colors.green),
  _BookmarkItem(id: '6', name: 'Nama Tempat 6', placeholderColor: Colors.deepOrange),
];

// ── Main Page ────────────────────────────────────────────────────────────────
class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final TextEditingController _searchController = TextEditingController();
  List<_BookmarkItem> _bookmarks = List.from(_dummyBookmarks);
  List<_BookmarkItem> _filtered = List.from(_dummyBookmarks);
  bool _isEditMode = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filtered = List.from(_bookmarks);
      } else {
        _filtered = _bookmarks
            .where((b) =>
                b.name.toLowerCase().contains(query.trim().toLowerCase()))
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
        _selectedIds.addAll(_filtered.map((b) => b.id));
      }
    });
  }

  void _toggleSelect(String id) {
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

  void _deleteSelected() {
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
              child: _bookmarks.isEmpty
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
          ? SafeArea(
              child: GestureDetector(
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
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
              ),
            )
          : null,
    );
  }

  // ── Card ───────────────────────────────────────────────────────────────────
  Widget _buildCard(_BookmarkItem item, bool isSelected) {
    return GestureDetector(
      onTap: _isEditMode ? () => _toggleSelect(item.id) : null,
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.placeholderColor.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF4AA5A6), width: 2.5)
              : null,
        ),
        child: Stack(
          children: [
            // Placeholder image area
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: item.placeholderColor.withOpacity(0.5),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.white.withOpacity(0.6),
                  ),
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
                item.name,
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