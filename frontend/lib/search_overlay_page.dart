
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/unggahan.dart';
import 'unggahan_detail_page.dart';
import 'place_detail_page.dart';

class SearchOverlayPage extends StatefulWidget {
  const SearchOverlayPage({super.key});

  @override
  State<SearchOverlayPage> createState() => _SearchOverlayPageState();
}

class PlaceSummary {
  final String placeName;
  final String imagePath;
  final int postCount;
  final double averageRating;
  final Unggahan sampleUnggahan;
  final List<Unggahan> unggahans;

  PlaceSummary({
    required this.placeName,
    required this.imagePath,
    required this.postCount,
    required this.averageRating,
    required this.sampleUnggahan,
    required this.unggahans,
  });
}

class _SearchOverlayPageState extends State<SearchOverlayPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<PlaceSummary> _allPlaces = [];
  List<PlaceSummary> _displayedPlaces = [];
  bool _loading = true;

  int _selectedFilter = 0; // 0 = Terbaru, 1 = Populer, 2 = Terfavorit

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    try {
      final jsonList = await ApiService.fetchUnggahans();
      final unggahans = jsonList.map((j) => Unggahan.fromJson(j)).toList();

      final Map<String, List<Unggahan>> grouped = {};
      for (var u in unggahans) {
        grouped.putIfAbsent(u.placeName, () => []).add(u);
      }

      final List<PlaceSummary> summaries = [];
      grouped.forEach((placeName, list) {
        final totalRating = list.fold(0, (sum, u) => sum + u.rating);
        final avgRating = totalRating / list.length;
        
        final images = list.expand((u) => u.imagePaths).toList();
        final firstImage = images.isNotEmpty ? images.first : '';

        summaries.add(PlaceSummary(
          placeName: placeName,
          imagePath: firstImage,
          postCount: list.length,
          averageRating: avgRating,
          sampleUnggahan: list.first, // or we can handle a new page to list them
          unggahans: list,
        ));
      });

      if (mounted) {
        setState(() {
          _allPlaces = summaries;
          _displayedPlaces = List.from(summaries);
          _loading = false;
          _applyFilter();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _displayedPlaces = List.from(_allPlaces);
    } else {
      // Find exact matches
      var exactMatches = _allPlaces.where((p) => p.placeName.toLowerCase().contains(q)).toList();
      
      // If no exact match, we do fuzzy match (any word matches)
      if (exactMatches.isEmpty) {
        final words = q.split(' ');
        exactMatches = _allPlaces.where((p) {
          final pLower = p.placeName.toLowerCase();
          return words.any((w) => w.isNotEmpty && pLower.contains(w));
        }).toList();
      }
      
      _displayedPlaces = exactMatches;
    }
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 0) {
        // Terbaru - assume id sorting if no date, or just leave as is
        _displayedPlaces.sort((a, b) => b.sampleUnggahan.id?.compareTo(a.sampleUnggahan.id ?? 0) ?? 0);
      } else if (_selectedFilter == 1) {
        // Populer - sort by post count desc
        _displayedPlaces.sort((a, b) => b.postCount.compareTo(a.postCount));
      } else if (_selectedFilter == 2) {
        // Terfavorit - sort by averageRating desc
        _displayedPlaces.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH BAR AND BACK
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4AA5A6), size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
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
                          const Icon(Icons.search, color: Color(0xFF4AA5A6), size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Mau ke mana hari ini?',
                                hintStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: const Color(0xFF4AA5A6).withValues(alpha: 0.8),
                                  fontStyle: FontStyle.italic,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            GestureDetector(
                                onTap: () {
                                _controller.clear();
                                _onSearchChanged('');
                                },
                                child: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.close, color: Colors.grey, size: 20),
                                ),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // FILTER ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.tune, color: Colors.black87, size: 20),
                    ),
                    _buildFilterChip("Terbaru", 0),
                    _buildFilterChip("Populer", 1),
                    _buildFilterChip("Terfavorit", 2),
                  ],
                ),
              ),
            ),
            
            // LIST VIEW RESULTS
            Expanded(
              child: _loading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4AA5A6)))
                : _displayedPlaces.isEmpty
                    ? const Center(child: Text("Tidak ada hasil yang cocok.", style: TextStyle(fontFamily: 'Inter', color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _displayedPlaces.length,
                        itemBuilder: (context, index) {
                          final place = _displayedPlaces[index];
                          return GestureDetector(
                            onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PlaceDetailPage(place: place)),
                                );
                            },
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFE5E9E9), // Matching grey box in screenshot
                                    borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                        // Image section
                                        ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(24),
                                                topRight: Radius.circular(24),
                                            ),
                                            child: Container(
                                                height: 180,
                                                color: Colors.grey.shade300,
                                                child: place.imagePath.isNotEmpty 
                                                    ? Image.network(
                                                        place.imagePath,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (ctx, err, curr) => const Icon(Icons.broken_image, color: Colors.grey),
                                                    )
                                                    : const Icon(Icons.image, size: 50, color: Colors.grey),
                                            )
                                        ),
                                        // Text section
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    Expanded(
                                                        child: Text(
                                                            place.placeName,
                                                            style: const TextStyle(
                                                                color: Color(0xFF4AA5A6),
                                                                fontFamily: 'Inter',
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                        ),
                                                    ),
                                                    Row(
                                                        children: [
                                                            if (place.averageRating > 0)
                                                                Row(children: [
                                                                    const Icon(Icons.star, color: Colors.orange, size: 18),
                                                                    const SizedBox(width: 4),
                                                                    Text(place.averageRating.toStringAsFixed(1), style: TextStyle(color: Colors.grey.shade700, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                                                                    const SizedBox(width: 8),
                                                                ]),
                                                            Text(
                                                                "(${place.postCount})",
                                                                style: TextStyle(
                                                                    color: Colors.grey.shade600,
                                                                    fontFamily: 'Inter',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w600,
                                                                ),
                                                            ),
                                                        ]
                                                    )
                                                ],
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                          );
                        },
                    )
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, int index) {
    bool isSelected = _selectedFilter == index;
    return GestureDetector(
        onTap: () {
            setState(() {
                _selectedFilter = index;
                _applyFilter();
            });
        },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: isSelected ? const Color(0xFF4AA5A6) : Colors.grey.shade400,
                    width: isSelected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
                label,
                style: TextStyle(
                    color: isSelected ? const Color(0xFF4AA5A6) : Colors.grey.shade500,
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                )
            ),
        ),
    );
  }
}
