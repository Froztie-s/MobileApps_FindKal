import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'map_page.dart';
import 'search_overlay_page.dart';
import 'buat_unggahan.dart';
import 'profile.dart';
import 'models/unggahan.dart';
import 'unggahan_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _hasUnreadNotification = true;

  final MapController _mapController = MapController();
  static const _fallback = LatLng(-0.5022, 117.1536);
  LatLng? _userLocation;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _requestLocationAndMove();
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchOverlayPage()),
    );
  }

  Future<void> _requestLocationAndMove() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (mounted) setState(() => _locating = false);

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _moveToCurrentLocation();
    }
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      ).catchError((e) async {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) return lastKnown;
        throw e;
      });
      final loc = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() => _userLocation = loc);
        _mapController.move(loc, 15);
      }
    } catch (_) {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onItemTapped(int index) async {
  if (index == 1) {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MapPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    if (result != null && result is int) {
      setState(() {
        _selectedIndex = result;
      });
    }
    return;
  }
  setState(() {
    _selectedIndex = index;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _selectedIndex == 2
            ? const ProfilePage()
            : _buildHomeContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
            label: 'Location',
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

  Widget _buildHomeContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _openSearch,
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
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.search,
                                    color: Color(0xFF4AA5A6),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Mau ke mana hari ini?",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: const Color(
                                        0xFF4AA5A6,
                                      ).withValues(alpha: 0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(context, '/notification');
                            if (mounted) setState(() => _hasUnreadNotification = false);
                          },
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications,
                                color: Color(0xFF4AA5A6),
                                size: 30,
                              ),
                              if (_hasUnreadNotification)
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Greeting Placeholder
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Selamat datang, User! ⛅",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Map Preview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 350,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _locating
                            ? const Center(
                                child: CircularProgressIndicator(color: Color(0xFF4AA5A6)),
                              )
                            : GestureDetector(
                                onPanDown: (_) {},
                                onTap: () => _onItemTapped(1),
                                behavior: HitTestBehavior.translucent,
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: _userLocation ?? _fallback,
                                      initialZoom: 15,
                                      interactionOptions: const InteractionOptions(
                                        flags: InteractiveFlag.none,
                                      ),
                                    ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.findkal.app',
                                  ),
                                  if (_userLocation != null)
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: _userLocation!,
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
                             ),
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Eksplorasi terdekat
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Eksplorasi terdekat",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Scrollable Cards
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      itemCount: dummyUnggahans.length,
                      itemBuilder: (context, index) {
                        return _buildExplorasiCard(dummyUnggahans[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Floating Action Buttons on bottom right
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircularButton(icon: Icons.add, size: 28, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BuatUnggahanPage()),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildCircularButton(imageAsset: 'assets/images/location.png', size: 26),
                ],
              ),
            ),
          ],
        );
  }

  Widget _buildExplorasiCard(Unggahan unggahan) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnggahanDetailPage(unggahan: unggahan),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User section
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey.shade400,
                    backgroundImage: AssetImage(unggahan.imagePaths.first),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      unggahan.usernameHandle.replaceAll('@', ''),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Image Placeholder
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(unggahan.imagePaths.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                unggahan.placeName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    IconData? icon,
    String? imageAsset,
    double? size,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEE8),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF4AA5A6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: imageAsset != null
              ? Image.asset(
                  imageAsset,
                  width: size ?? 26,
                  height: size ?? 26,
                )
                  : Icon(icon, color: const Color(0xFF4AA5A6), size: size),
        ),
      ),
    );
  }
}
