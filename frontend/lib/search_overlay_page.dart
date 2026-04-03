
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/unggahan.dart';
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
  final Set<String> _bookmarkedPlaces = {}; // Local state to track bookmarked places

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
      backgroundColor: const Color(0xFFF8FAFA), // Softer off-white background
      body: SafeArea(
        child: Column(
          children: [
            // FLOATING SEARCH BAR
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari tempat atau lokasi...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.search, color: Colors.grey, size: 22),
                    ),
                ],
              ),
            ),
            
            // FILTER ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 36, // Smaller, strictly defined height for modern pills
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.tune, color: Colors.black87, size: 18),
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text("Tidak ada hasil yang cocok.", style: TextStyle(fontFamily: 'Inter', color: Colors.grey.shade500, fontSize: 16)),
                          ],
                        ),
                      )
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
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                        // Image section
                                        Stack(
                                          children: [
                                            ClipRRect(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                                child: Container(
                                                    height: 200,
                                                    width: double.infinity,
                                                    color: Colors.grey.shade200,
                                                    child: place.imagePath.isNotEmpty 
                                                        ? Image.network(
                                                            place.imagePath,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (ctx, err, curr) => const Icon(Icons.broken_image, color: Colors.grey),
                                                        )
                                                        : const Icon(Icons.image, size: 50, color: Colors.grey),
                                                )
                                            ),
                                            // Top Right Bookmark (Functional)
                                            Positioned(
                                              top: 12,
                                              right: 12,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (_bookmarkedPlaces.contains(place.placeName)) {
                                                      _bookmarkedPlaces.remove(place.placeName);
                                                      ScaffoldMessenger.of(context).clearSnackBars();
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('${place.placeName} dihapus dari bookmark'), 
                                                          duration: const Duration(seconds: 1),
                                                        ),
                                                      );
                                                    } else {
                                                      _bookmarkedPlaces.add(place.placeName);
                                                      ScaffoldMessenger.of(context).clearSnackBars();
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('${place.placeName} ditambahkan ke bookmark'), 
                                                          duration: const Duration(seconds: 1),
                                                        ),
                                                      );
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.9),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    _bookmarkedPlaces.contains(place.placeName) 
                                                        ? Icons.bookmark 
                                                        : Icons.bookmark_border, 
                                                    size: 20, 
                                                    color: _bookmarkedPlaces.contains(place.placeName) 
                                                        ? const Color(0xFF4AA5A6) 
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Bottom Left Rating Badge
                                            if (place.averageRating > 0)
                                              Positioned(
                                                bottom: 12,
                                                left: 12,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.95),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.star, color: Colors.orange, size: 16),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        place.averageRating.toStringAsFixed(1), 
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Inter'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        // Text section
                                        Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                            child: Text(
                                                                place.placeName,
                                                                style: const TextStyle(
                                                                    color: Colors.black87,
                                                                    fontFamily: 'Inter',
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                            ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          "(${place.postCount} ulasan)",
                                                          style: TextStyle(
                                                              color: Colors.grey.shade500,
                                                              fontFamily: 'Inter',
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade400),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            place.sampleUnggahan.address,
                                                            style: TextStyle(
                                                              color: Colors.grey.shade600,
                                                              fontFamily: 'Inter',
                                                              fontSize: 13,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(right: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4AA5A6) : Colors.white,
                border: Border.all(
                    color: isSelected ? const Color(0xFF4AA5A6) : Colors.grey.shade300,
                    width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
                label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                )
            ),
        ),
    );
  }
}
