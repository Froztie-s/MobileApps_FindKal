import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/auth_state.dart';
import '../map/map_page.dart';
import 'search_overlay_page.dart';
import '../unggahan/buat_unggahan.dart';
import '../profile/profile.dart';
import '../../models/unggahan.dart';
import '../unggahan/unggahan_detail_page.dart';
import '../../services/api_service.dart';
import '../ai_plan/ai_trip_plan_page.dart';
import '../ai_plan/trip_plan_selection_page.dart';
import '../settingpage/survey_intro_page.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  final Future<void> Function()? pendingUpload;

  const HomePage({super.key, this.initialIndex = 0, this.pendingUpload});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  bool _hasUnreadNotification = true;
  List<Unggahan> _unggahans = [];
  bool _loadingFeed = true;

  final MapController _mapController = MapController();
  static const _defaultLocation = LatLng(-6.302640076739822, 106.63938340127805);
  LatLng? _userLocation;
  bool _locating = true; // true until GPS position (or denial) is resolved

  // Location permission state
  bool _locationGranted = false;
  bool _locationPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _initLocation();

    if (widget.pendingUpload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePendingUpload();
      });
    }
  }

  Future<void> _handlePendingUpload() async {
    // Tampilkan snackbar loading (atau apa saja)
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final topMargin = MediaQuery.of(context).size.height - 180;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Mengunggah postingan...', style: TextStyle(fontFamily: 'Inter')),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: topMargin, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        duration: const Duration(days: 1), // Tahan sampai selesai
      ),
    );

    try {
      await widget.pendingUpload!();
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Postingan kamu sudah berhasil ter-upload!',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: const Color(0xFF4AA5A6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: topMargin, left: 16, right: 16),
          duration: const Duration(seconds: 5),
        ),
      );
      // Refresh list kalau ada
      final loc = _userLocation;
      _fetchUnggahans(
        _locationGranted && loc != null ? loc.latitude : null,
        _locationGranted && loc != null ? loc.longitude : null,
      );
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah: $e', style: const TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: topMargin, left: 16, right: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// Request location permission, get GPS fix, then fetch nearby places.
  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _locationPermanentlyDenied = true;
          _locationGranted = false;
          _locating = false;
          _userLocation = _defaultLocation;
        });
        _mapController.move(_defaultLocation, 15);
      }
      await _fetchUnggahans(null, null);
      return;
    }

    if (permission == LocationPermission.denied) {
      // User tapped "Don't allow" on the dialog
      if (mounted) {
        setState(() {
          _locationGranted = false;
          _locating = false;
          _userLocation = _defaultLocation;
        });
        _mapController.move(_defaultLocation, 15);
      }
      await _fetchUnggahans(null, null);
      return;
    }

    // Permission granted — get actual position
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _locationGranted = true;
          _locating = false;
          _userLocation = LatLng(pos.latitude, pos.longitude);
        });
        _mapController.move(_userLocation!, 15);
      }
      await _fetchUnggahans(pos.latitude, pos.longitude);
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationGranted = true;
          _locating = false;
          _userLocation = _defaultLocation;
        });
        _mapController.move(_defaultLocation, 15);
      }
      await _fetchUnggahans(null, null);
    }
  }

  Future<void> _fetchUnggahans(double? lat, double? lng) async {
    try {
      final user = AuthState.currentUser ?? {};
      final currentUserUsername = user['username'] ?? '';

      final data = await ApiService.fetchUnggahans(lat: lat, lng: lng)
          .timeout(const Duration(seconds: 20));
      if (mounted) {
        setState(() {
          final allUnggahans = data.map((j) => Unggahan.fromJson(j)).toList();
          _unggahans = allUnggahans
              .where((u) => u.usernameHandle.replaceAll('@', '') != currentUserUsername)
              .toList();
          _loadingFeed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFeed = false);
    }
  }

  void _showVerificationRequiredSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.lock_outline_rounded, size: 48, color: Color(0xFF4AA5A6)),
            const SizedBox(height: 16),
            const Text(
              'Verifikasi Warga Lokal Diperlukan',
              style: TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Hanya warga lokal terverifikasi yang dapat mengunggah postingan. Selesaikan survei singkat untuk mendapatkan akses.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SurveyIntroPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4AA5A6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text('Mulai Verifikasi', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchOverlayPage()),
    );
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
        RefreshIndicator(
          onRefresh: () {
            final loc = _userLocation;
            return _fetchUnggahans(
              _locationGranted && loc != null ? loc.latitude : null,
              _locationGranted && loc != null ? loc.longitude : null,
            );
          },
          color: const Color(0xFF4AA5A6),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                                      initialCenter: _userLocation ?? _defaultLocation,
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
                                                  border: Border.all(color: Colors.white, width: 3),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.3),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _locationGranted
                          ? "Eksplorasi terdekat (15 km)"
                          : "Eksplorasi tempat",
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location denied banner
                  if (!_locationGranted)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_off_outlined, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationPermanentlyDenied
                                    ? 'Izin lokasi ditolak. Aktifkan di Pengaturan untuk melihat tempat terdekat.'
                                    : 'Aktifkan lokasi untuk melihat tempat dalam radius 15 km.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Horizontal Scrollable Cards
                  SizedBox(
                    height: 240,
                    child: _loadingFeed
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4AA5A6)))
                        : _unggahans.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    _locationGranted
                                        ? 'Belum ada rekomendasi di area sekitarmu saat ini.'
                                        : 'Belum ada unggahan.',
                                    style: const TextStyle(fontFamily: 'Inter', color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(left: 16, right: 8),
                                itemCount: _unggahans.length,
                                itemBuilder: (context, index) {
                                  return _buildExplorasiCard(_unggahans[index]);
                                },
                              ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
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
                    if (!AuthState.isWargaLokal) {
                      _showVerificationRequiredSheet();
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BuatUnggahanPage()),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildCircularButton(
                    imageAsset: 'assets/images/location.png', 
                    size: 26,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TripPlanSelectionPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
  }

  Widget _buildExplorasiCard(Unggahan unggahan) {
    final user = AuthState.currentUser ?? {};
    final isCurrentUser = unggahan.usernameHandle.replaceAll('@', '') == user['username'];
    
    String? avatarSource = unggahan.userAvatar;
    if (isCurrentUser && user['profile_photo'] != null) {
      avatarSource = user['profile_photo'] as String;
    }

    ImageProvider? avatarProvider;
    if (avatarSource != null && avatarSource.isNotEmpty) {
      if (avatarSource.startsWith('http')) {
        avatarProvider = NetworkImage(avatarSource);
      } else {
        avatarProvider = FileImage(File(avatarSource));
      }
    }

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
                    backgroundImage: avatarProvider,
                    child: avatarProvider == null
                        ? const Icon(Icons.person, size: 16, color: Colors.white)
                        : null,
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
                    image: unggahan.imagePaths.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(unggahan.imagePaths.first),
                            fit: BoxFit.cover,
                          )
                        : null,
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
