import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'map_direction_page.dart';

class _PlaceResult {
  final String displayName;
  final double lat;
  final double lon;
  final double? distanceMeters;

  _PlaceResult({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.distanceMeters,
  });

  factory _PlaceResult.fromJson(Map<String, dynamic> json) {
    return _PlaceResult(
      displayName: json['display_name'] as String,
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
    );
  }

  _PlaceResult withDistance(double meters) => _PlaceResult(
      displayName: displayName, lat: lat, lon: lon, distanceMeters: meters);
}

/// Haversine distance in meters between two lat/lon points.
double _haversine(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

String _formatDistance(double meters) {
  if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
  return '${meters.toInt()} m';
}

// ─────────────────────────────────────────────────────────────────────────────

class MapSearchResultPage extends StatefulWidget {
  final String query;
  const MapSearchResultPage({super.key, required this.query});

  @override
  State<MapSearchResultPage> createState() => _MapSearchResultPageState();
}

class _MapSearchResultPageState extends State<MapSearchResultPage> {
  final MapController _mapController = MapController();
  late final TextEditingController _searchController;

  LatLng? _userLocation;
  List<_PlaceResult> _results = [];
  _PlaceResult? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _initLocationThenSearch(widget.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get user location first, then search so results can be sorted by distance.
  Future<void> _initLocationThenSearch(String query) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (mounted) {
      setState(() => _userLocation = const LatLng(-6.302640076739822, 106.63938340127805));
    }
    await _search(query);
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Build query — add viewbox around user so nearby results rank first
      final params = <String, String>{
        'q': trimmed,
        'format': 'json',
        'limit': '15',
        'addressdetails': '1',
      };
      if (_userLocation != null) {
        final lat = _userLocation!.latitude;
        final lon = _userLocation!.longitude;
        // ±1 degree box (~110 km) — bounded=0 still allows results outside
        params['viewbox'] = '${lon - 1},${lat + 1},${lon + 1},${lat - 1}';
        params['bounded'] = '0';
      }
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);
      final res = await http.get(uri, headers: {
        'User-Agent': 'FindKalApp/1.0',
        'Accept-Language': 'id,en',
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        List<_PlaceResult> results = data
            .map((e) => _PlaceResult.fromJson(e as Map<String, dynamic>))
            .toList();

        // Attach distance and sort nearest first if we have user location
        if (_userLocation != null) {
          results = results.map((r) {
            final d = _haversine(_userLocation!.latitude,
                _userLocation!.longitude, r.lat, r.lon);
            return r.withDistance(d);
          }).toList()
            ..sort((a, b) => a.distanceMeters!.compareTo(b.distanceMeters!));
        }

        setState(() {
          _results = results;
          _selected = results.isNotEmpty ? results.first : null;
          _loading = false;
        });
        if (_selected != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(LatLng(_selected!.lat, _selected!.lon), 15);
          });
        }
      } else {
        setState(() {
          _error = 'Gagal mencari lokasi (${res.statusCode})';
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Tidak dapat terhubung ke server';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── FULL SCREEN MAP ───────────────────────────────────────────
          _buildMap(),

          // ── TOP SEARCH BAR OVERLAY ────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                          const Icon(Icons.search,
                              color: Color(0xFF4AA5A6), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _search,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 14),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _search(_searchController.text),
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
          ),

          // ── LOADING OVERLAY ───────────────────────────────────────────
          if (_loading)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4AA5A6)),
              ),
            ),

          // ── BOTTOM RESULTS PANEL ──────────────────────────────────────
          if (!_loading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.42,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    if (_error != null || _results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              _error ?? 'Lokasi tidak ditemukan',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Results list
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          itemCount: _results.length,
                          separatorBuilder: (context, i) =>
                              const Divider(height: 1, indent: 52),
                          itemBuilder: (context, i) {
                            final r = _results[i];
                            final isSelected = r == _selected;
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.location_on,
                                color: isSelected
                                    ? const Color(0xFF4AA5A6)
                                    : Colors.grey.shade400,
                                size: 22,
                              ),
                              title: Text(
                                r.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF4AA5A6)
                                      : Colors.black87,
                                ),
                              ),
                              trailing: r.distanceMeters != null
                                  ? Text(
                                      _formatDistance(r.distanceMeters!),
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: isSelected
                                            ? const Color(0xFF4AA5A6)
                                            : Colors.grey.shade500,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                setState(() => _selected = r);
                                _mapController.move(LatLng(r.lat, r.lon), 15);
                              },
                            );
                          },
                        ),
                      ),

                      // Arahkan button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        child: GestureDetector(
                          onTap: _selected == null
                              ? null
                              : () async {
                                  final result = await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, _, _) =>
                                          MapDirectionPage(
                                        destinationName:
                                            _selected!.displayName,
                                        destination: LatLng(
                                            _selected!.lat, _selected!.lon),
                                      ),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                  if (result != null && context.mounted) {
                                    Navigator.pop(context, result);
                                  }
                                },
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selected == null
                                  ? Colors.grey.shade300
                                  : const Color(0xFF4AA5A6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.directions,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Arahkan',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),

      // ── BOTTOM NAVIGATION BAR ─────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
          if (index == 2) {
            // Pop back to MapPage carrying result 2 so HomePage opens Profile
            Navigator.pop(context, 2);
          }
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

  Widget _buildMap() {
    if (_selected == null && !_loading) {
      return Container(color: Colors.grey.shade200);
    }
    final center = _selected != null
        ? LatLng(_selected!.lat, _selected!.lon)
        : const LatLng(-0.5022, 117.1536);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.findkal.app',
          keepBuffer: 5,
        ),
        if (_userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _userLocation!,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4AA5A6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        if (_selected != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_selected!.lat, _selected!.lon),
                child: const Icon(
                  Icons.location_pin,
                  color: Color(0xFFE53935),
                  size: 42,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
