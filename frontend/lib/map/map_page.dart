import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'map_search_result_page.dart';
import '../services/search_history.dart';

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

  @override
  void initState() {
    super.initState();
    _requestLocationAndMove();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationAndMove() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (mounted) {
      setState(() => _userLocation = _defaultLocation);
      _mapController.move(_defaultLocation, 15);
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
                                    onSubmitted: (_) => _onSearch(),
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
