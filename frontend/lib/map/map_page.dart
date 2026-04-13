import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'map_search_result_page.dart';
import '../services/search_history.dart';
import '../services/api_service.dart';

class _MapSuggestion {
  final String label;
  final double? lat;
  final double? lng;
  _MapSuggestion({required this.label, this.lat, this.lng});
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  static const _defaultLocation = LatLng(-6.302640076739822, 106.63938340127805);
  LatLng _userLocation = _defaultLocation;

  List<_MapSuggestion> _postSuggestions = [];
  List<_MapSuggestion> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _requestLocationAndMove();
    _loadPostSuggestions();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPostSuggestions() async {
    try {
      final data = await ApiService.fetchUnggahans();
      final seen = <String>{};
      final list = <_MapSuggestion>[];
      for (final j in data) {
        final name = j['placeName'] as String? ?? '';
        final lat = (j['lat'] as num?)?.toDouble();
        final lng = (j['lng'] as num?)?.toDouble();
        if (name.isNotEmpty && seen.add(name) && lat != null && lng != null) {
          list.add(_MapSuggestion(label: name, lat: lat, lng: lng));
        }
      }
      if (mounted) setState(() => _postSuggestions = list);
    } catch (_) {}
  }

  void _onSearchTextChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _buildSuggestions(query.trim()));
  }

  Future<void> _buildSuggestions(String query) async {
    final q = query.toLowerCase();
    final postMatches = _postSuggestions
        .where((s) => s.label.toLowerCase().contains(q))
        .take(3)
        .toList();

    final nominatimMatches = <_MapSuggestion>[];
    final remaining = 5 - postMatches.length;
    if (remaining > 0) {
      try {
        final lat = _userLocation.latitude;
        final lon = _userLocation.longitude;
        final params = <String, String>{
          'q': query,
          'format': 'json',
          'limit': '$remaining',
          'addressdetails': '0',
          'viewbox': '${lon - 1},${lat + 1},${lon + 1},${lat - 1}',
          'bounded': '0',
        };
        final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);
        final res = await http.get(uri, headers: {'User-Agent': 'FindKalApp/1.0', 'Accept-Language': 'id,en'});
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as List;
          nominatimMatches.addAll(data.map((e) => _MapSuggestion(label: e['display_name'] as String)));
        }
      } catch (_) {}
    }

    if (mounted) setState(() => _suggestions = [...postMatches, ...nominatimMatches]);
  }

  Future<void> _requestLocationAndMove() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (mounted) {
        setState(() => _userLocation = _defaultLocation);
        _mapController.move(_defaultLocation, 15);
      }
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        final loc = LatLng(pos.latitude, pos.longitude);
        setState(() => _userLocation = loc);
        _mapController.move(loc, 15);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _userLocation = _defaultLocation);
        _mapController.move(_defaultLocation, 15);
      }
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    SearchHistory.add(query);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MapSearchResultPage(query: query),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
                children: [
                  // ── MAP ──────────────────────────────────────────────────────
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _userLocation,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.findkal.app',
                      ),
                      MarkerLayer(
                          markers: [
                            Marker(
                              point: _userLocation,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4AA5A6),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // ── SEARCH BAR OVERLAY ────────────────────────────────────────
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF4AA5A6),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 14),
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFF4AA5A6),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onSubmitted: (_) {
                                      setState(() => _suggestions = []);
                                      _onSearch();
                                    },
                                    onChanged: _onSearchTextChanged,
                                    decoration: InputDecoration(
                                      hintText: 'Cari lokasi...',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 14),
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _onSearch,
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4AA5A6),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Text(
                                      'Cari',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── AUTOCOMPLETE SUGGESTIONS ─────────────────────────────────
                  if (_suggestions.isNotEmpty)
                    Positioned(
                      top: 72,
                      left: 70,
                      right: 16,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _suggestions.map((s) {
                              final isPost = s.lat != null && s.lng != null;
                              return InkWell(
                                onTap: () {
                                  _searchController.text = s.label;
                                  setState(() => _suggestions = []);
                                  _debounce?.cancel();
                                  if (isPost) {
                                    // Jump map directly to post's stored coordinates
                                    _mapController.move(LatLng(s.lat!, s.lng!), 16);
                                  } else {
                                    SearchHistory.add(s.label);
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, anim, secAnim) => MapSearchResultPage(query: s.label),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration: Duration.zero,
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isPost ? Icons.place : Icons.place_outlined,
                                        size: 18,
                                        color: const Color(0xFF4AA5A6),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          s.label,
                                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isPost)
                                        const Text('Tempat', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF4AA5A6))),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                  // ── MY LOCATION FAB ───────────────────────────────────────────
                  Positioned(
                    bottom: 20,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () => _mapController.move(_defaultLocation, 15),
                      backgroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(
                        Icons.my_location,
                        color: Color(0xFF4AA5A6),
                      ),
                    ),
                  ),
                ],
        ),
      ),

      // ── BOTTOM NAVIGATION BAR ─────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          // Your version: pop with index so HomePage state machine handles routing
          if (index == 0) Navigator.pop(context, 0);
          if (index == 2) Navigator.pop(context, 2);
        },
        selectedItemColor: const Color(0xFF4AA5A6),
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 30,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
