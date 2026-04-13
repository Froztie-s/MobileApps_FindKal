import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'map_page.dart';

double _haversineSimple(double lat1, double lon1, double lat2, double lon2) {
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

class MapDirectionPage extends StatefulWidget {
  final String destinationName;
  final LatLng destination;
  final String? destinationAddress;

  const MapDirectionPage({
    super.key,
    required this.destinationName,
    required this.destination,
    this.destinationAddress,
  });

  @override
  State<MapDirectionPage> createState() => _MapDirectionPageState();
}

class _MapDirectionPageState extends State<MapDirectionPage> {
  final MapController _mapController = MapController();
  late final TextEditingController _searchController;

  // Current destination (can be changed by user)
  late LatLng _currentDestination;
  late String _currentDestinationName;

  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  double? _distanceMeters;
  double? _durationSeconds;
  bool _loading = true;
  String? _error;

  // Transport mode: 'car', 'motorcycle', 'walking'
  String _selectedMode = 'car';

  List<String> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentDestination = widget.destination;
    _currentDestinationName = widget.destinationName;
    _searchController = TextEditingController(text: _currentDestinationName);
    if (widget.destinationAddress != null && widget.destinationAddress!.isNotEmpty) {
      _geocodeAddressThenRoute(widget.destinationAddress!);
    } else {
      _loadRoute();
    }
  }

  /// Geocode a text address via Nominatim, then load the route.
  Future<void> _geocodeAddressThenRoute(String address) async {
    try {
      final query = '${widget.destinationName} $address';
      final params = <String, String>{
        'q': query,
        'format': 'json',
        'limit': '5',
        'addressdetails': '1',
      };
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);
      final res = await http.get(uri, headers: {
        'User-Agent': 'FindKalApp/1.0',
        'Accept-Language': 'id,en',
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        if (data.isNotEmpty) {
          final place = data.first as Map<String, dynamic>;
          _currentDestination = LatLng(
            double.parse(place['lat'] as String),
            double.parse(place['lon'] as String),
          );
        }
      }
    } catch (_) {
      // Keep widget.destination as fallback
    }
    await _loadRoute();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _fetchSuggestions(query.trim()));
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final params = <String, String>{
        'q': query,
        'format': 'json',
        'limit': '5',
        'addressdetails': '0',
      };
      if (_userLocation != null) {
        final lat = _userLocation!.latitude;
        final lon = _userLocation!.longitude;
        params['viewbox'] = '${lon - 1},${lat + 1},${lon + 1},${lat - 1}';
        params['bounded'] = '0';
      }
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);
      final res = await http.get(uri, headers: {'User-Agent': 'FindKalApp/1.0', 'Accept-Language': 'id,en'});
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          _suggestions = data.map((e) => e['display_name'] as String).toList();
        });
      }
    } catch (_) {}
  }

  /// Geocode [query] via Nominatim, update destination, then refetch route.
  Future<void> _searchNewDestination(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Add viewbox around user so the nearest match is picked first
      final params = <String, String>{
        'q': trimmed,
        'format': 'json',
        'limit': '5',
      };
      if (_userLocation != null) {
        final lat = _userLocation!.latitude;
        final lon = _userLocation!.longitude;
        params['viewbox'] = '${lon - 1},${lat + 1},${lon + 1},${lat - 1}';
        params['bounded'] = '0';
      }
      final uri =
          Uri.https('nominatim.openstreetmap.org', '/search', params);
      final res = await http.get(uri, headers: {
        'User-Agent': 'FindKalApp/1.0',
        'Accept-Language': 'id,en',
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        if (data.isEmpty) {
          setState(() {
            _error = 'Lokasi "$trimmed" tidak ditemukan';
            _loading = false;
          });
          return;
        }
        // Pick the nearest result to the user if location is known
        final places = data.cast<Map<String, dynamic>>();
        Map<String, dynamic> place = places.first;
        if (_userLocation != null) {
          double best = double.infinity;
          for (final p in places) {
            final d = _haversineSimple(
              _userLocation!.latitude,
              _userLocation!.longitude,
              double.parse(p['lat'] as String),
              double.parse(p['lon'] as String),
            );
            if (d < best) {
              best = d;
              place = p;
            }
          }
        }
        _currentDestination = LatLng(
          double.parse(place['lat'] as String),
          double.parse(place['lon'] as String),
        );
        _currentDestinationName = place['display_name'] as String;
        _searchController.text = _currentDestinationName;
        setState(() {
          _routePoints = [];
          _distanceMeters = null;
          _durationSeconds = null;
        });
        await _loadRoute();
      } else {
        setState(() {
          _error = 'Gagal mencari lokasi';
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

  Future<void> _loadRoute() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Izin lokasi ditolak. Aktifkan di pengaturan.';
          _loading = false;
        });
        return;
      }

      LatLng origin;
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        origin = LatLng(pos.latitude, pos.longitude);
      } catch (_) {
        origin = const LatLng(-6.302640076739822, 106.63938340127805);
      }
      setState(() => _userLocation = origin);

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${_currentDestination.longitude},${_currentDestination.latitude}'
        '?overview=full&geometries=geojson',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if ((data['routes'] as List).isEmpty) {
          setState(() {
            _error = 'Rute tidak ditemukan';
            _loading = false;
          });
          return;
        }
        final route = (data['routes'] as List).first as Map<String, dynamic>;
        final coords =
            (route['geometry']['coordinates'] as List).cast<List<dynamic>>();
        final points = coords
            .map((c) => LatLng(
                  (c[1] as num).toDouble(),
                  (c[0] as num).toDouble(),
                ))
            .toList();

        setState(() {
          _routePoints = points;
          _distanceMeters = (route['distance'] as num).toDouble();
          _durationSeconds = (route['duration'] as num).toDouble();
          _loading = false;
        });

        // Fit map after tiles have had a chance to load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (points.isEmpty) return;
          double minLat = origin.latitude, maxLat = origin.latitude;
          double minLon = origin.longitude, maxLon = origin.longitude;
          for (final p in [...points, _currentDestination]) {
            if (p.latitude < minLat) minLat = p.latitude;
            if (p.latitude > maxLat) maxLat = p.latitude;
            if (p.longitude < minLon) minLon = p.longitude;
            if (p.longitude > maxLon) maxLon = p.longitude;
          }
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds(
                LatLng(minLat, minLon),
                LatLng(maxLat, maxLon),
              ),
              padding: const EdgeInsets.fromLTRB(40, 120, 40, 160),
            ),
          );
        });
      } else {
        setState(() {
          _error = 'Gagal mendapatkan rute (${res.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Tidak dapat terhubung ke server';
        _loading = false;
      });
    }
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toInt()} m';
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).round();
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return m == 0 ? '$h jam' : '$h jam $m menit';
    }
    return '$mins menit';
  }

  /// Estimated duration in seconds for each transport mode.
  double _durationFor(String mode) {
    final dist = _distanceMeters ?? 0;
    final carSecs = _durationSeconds ?? 0;
    switch (mode) {
      case 'motorcycle':
        // Motorcycles average ~40 km/h in urban areas
        return (dist / (40000 / 3600));
      case 'walking':
        // Walking average ~5 km/h
        return (dist / (5000 / 3600));
      case 'car':
      default:
        return carSecs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── FULL SCREEN MAP ─────────────────────────────────────────
          _buildMap(),

          // ── TOP HEADER OVERLAY ──────────────────────────────────────
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
                      height: 46,
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
                          const Icon(Icons.directions,
                              color: Color(0xFF4AA5A6), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: (q) {
                                setState(() => _suggestions = []);
                                _searchNewDestination(q);
                              },
                              onChanged: _onSearchTextChanged,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _searchNewDestination(_searchController.text),
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
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
                                  fontSize: 12,
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

          // ── LOADING OVERLAY ─────────────────────────────────────────
          if (_loading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4AA5A6)),
                    SizedBox(height: 12),
                    Text(
                      'Mencari rute...',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
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
                    children: _suggestions.map((name) {
                      return InkWell(
                        onTap: () {
                          _searchController.text = name;
                          setState(() => _suggestions = []);
                          _debounce?.cancel();
                          _searchNewDestination(name);
                        },
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 18, color: Color(0xFF4AA5A6)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

          // ── ERROR OVERLAY ────────────────────────────────────────────
          if (!_loading && _error != null)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 36, color: Colors.grey.shade500),
                    const SizedBox(height: 8),
                    Text(_error!,
                        style: TextStyle(
                            fontFamily: 'Inter', color: Colors.grey.shade600),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _loadRoute,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4AA5A6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── INFO CARD OVERLAY (bottom) ───────────────────────────────
          if (!_loading && _error == null && _distanceMeters != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destination name + distance
                    Row(
                      children: [
                        const Icon(Icons.location_pin,
                            color: Color(0xFFE53935), size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentDestinationName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.straighten,
                                size: 13, color: Color(0xFF4AA5A6)),
                            const SizedBox(width: 3),
                            Text(
                              _formatDistance(_distanceMeters!),
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Transport mode selector
                    Row(
                      children: [
                        _modeChip(
                          mode: 'car',
                          icon: Icons.directions_car,
                          label: 'Mobil',
                        ),
                        const SizedBox(width: 8),
                        _modeChip(
                          mode: 'motorcycle',
                          icon: Icons.two_wheeler,
                          label: 'Motor',
                        ),
                        const SizedBox(width: 8),
                        _modeChip(
                          mode: 'walking',
                          icon: Icons.directions_walk,
                          label: 'Jalan',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // ── BOTTOM NAVIGATION BAR ─────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          }
          if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MapPage()),
              (route) => false,
            );
          }
          if (index == 2) {
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

  Widget _modeChip({
    required String mode,
    required IconData icon,
    required String label,
  }) {
    final selected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF4AA5A6)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? Colors.white : Colors.black54),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDuration(_durationFor(mode)),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (_error != null && _userLocation == null) {
      // No location at all — show plain grey
      return Container(color: Colors.grey.shade200);
    }
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLocation ?? _currentDestination,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.findkal.app',
          // Keep tiles in memory while camera moves
          keepBuffer: 5,
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: const Color(0xFF4AA5A6),
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (_userLocation != null)
              Marker(
                point: _userLocation!,
                child: Container(
                  width: 22,
                  height: 22,
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
            Marker(
              point: _currentDestination,
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
