import 'package:flutter/material.dart';

class AiTripDetailPage extends StatefulWidget {
  final String tripName;

  const AiTripDetailPage({super.key, required this.tripName});

  @override
  State<AiTripDetailPage> createState() => _AiTripDetailPageState();
}

class _AiTripDetailPageState extends State<AiTripDetailPage> {
  List<Map<String, dynamic>> timelineItems = [
    {
      'time': '06.00 AM',
      'title': 'Pemandangan Diatas Koja Cliff Goa Gozila',
      'details':
          'Tiket masuk: Rp15.000\nParkir: Rp5.000 - Rp10.000\nSewa Perahu: Rp20.000',
      'imageUrl':
          'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?auto=format&fit=crop&w=300&q=80',
    },
    {
      'time': '11.00 AM',
      'title': 'Telang Garden Cafe Makanan Autentik Indonesia',
      'details':
          'Menu Utama (Ayam Pecak): Rp30.000 - Rp45.000\nMinuman Signature Telang: Rp10.000 - Rp15.000\nTotal per orang: Rp50.000 - Rp75.000',
      'imageUrl':
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=300&q=80',
    },
    {
      'time': '03.00 PM',
      'title': 'Broadway Alam Sutera Dari Alam ke New York Dalam 15 Menit',
      'details': 'Parkir: Rp5.000 - Rp10.000\nCamilan: Rp25.000 - Rp50.000',
      'imageUrl':
          'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?auto=format&fit=crop&w=300&q=80',
    },
  ];

  void _editPlan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah Rencana',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4AA5A6),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(timelineItems.length, (index) {
                  final item = timelineItems[index];
                  TextEditingController timeController = TextEditingController(
                    text: item['time'],
                  );
                  TextEditingController titleController = TextEditingController(
                    text: item['title'],
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destinasi ${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: timeController,
                                decoration: InputDecoration(
                                  labelText: 'Waktu',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (val) {
                                  timelineItems[index]['time'] = val;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 5,
                              child: TextField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: 'Tempat',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (val) {
                                  timelineItems[index]['title'] = val;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9CCCD0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4AA5A6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map Placeholder
                    MapPreviewCard(items: timelineItems),
                    const SizedBox(height: 24),
                    Text(
                      'Rencana Kegiatanmu: ${widget.tripName}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4AA5A6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Timeline Title
                    Row(
                      children: const [
                        SizedBox(width: 4),
                        Icon(Icons.circle, size: 12, color: Color(0xFFE0E0E0)),
                        SizedBox(width: 16),
                        Text(
                          'Tempat',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4AA5A6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Timeline Items
                    ...List.generate(timelineItems.length, (index) {
                      final item = timelineItems[index];
                      return _buildTimelineItem(
                        time: item['time'],
                        title: item['title'],
                        details: item['details'],
                        imageUrl: item['imageUrl'],
                        isLast: false, // Dots continue to the transport section
                      );
                    }),
                    _buildTransportSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Selesai Action - return to home (pop until first)
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9CCCD0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _editPlan,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF9CCCD0),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Ubah rencana',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9CCCD0), // Teal text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String details,
    required String imageUrl,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line & dots column
        Column(
          children: [
            const SizedBox(height: 4),
            const Icon(Icons.circle, size: 10, color: Color(0xFFE0E0E0)),
            if (!isLast) ...[
              const SizedBox(height: 8),
              const Icon(Icons.circle, size: 6, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 8),
              const Icon(Icons.circle, size: 6, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 8),
              const Icon(Icons.circle, size: 6, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 8),
              const Icon(Icons.circle, size: 6, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 8),
              const Icon(Icons.circle, size: 6, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 8),
              const Icon(Icons.circle, size: 6, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 8),
              const Icon(Icons.circle, size: 6, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 8),
              const Icon(Icons.circle, size: 6, color: Color(0xFFE0E0E0)),
            ],
          ],
        ),
        const SizedBox(width: 16),
        // Card Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), // Light grey background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: Colors.grey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransportSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dots continuation
        Column(
          children: [
            const SizedBox(height: 4),
            const Icon(Icons.circle, size: 10, color: Color(0xFFE0E0E0)),
            ...List.generate(
              15,
              (index) => const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Icon(Icons.circle, size: 6, color: Color(0xFFE0E0E0)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bisa naik transportasi ini!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4AA5A6),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height:
                    360, // Fixed height to allow right side scrolling while left sticks
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side (Sticky)
                    Expanded(
                      flex: 11,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAEAEA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Rekomendasi transportasi',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            _buildTransportCard(
                              icon: Icons.motorcycle,
                              name: 'Motor',
                              time: '40',
                              isWhite: true,
                            ),
                            const SizedBox(height: 12),
                            _buildTransportCard(
                              icon: Icons.directions_car,
                              name: 'Mobil',
                              time: '50',
                              isWhite: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Side (Scrollable)
                    Expanded(
                      flex: 10,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildTransportCard(
                            icon: Icons.directions_car,
                            name: 'Mobil',
                            time: '50',
                            isWhite: false,
                          ),
                          const SizedBox(height: 12),
                          _buildTransportCard(
                            icon: Icons.motorcycle,
                            name: 'Motor',
                            time: '40',
                            isWhite: false,
                          ),
                          const SizedBox(height: 12),
                          _buildTransportCard(
                            icon: Icons.directions_transit,
                            name: 'Kereta',
                            time: '35',
                            isWhite: false,
                          ),
                          const SizedBox(height: 12),
                          _buildTransportCard(
                            icon: Icons.directions_bus,
                            name: 'Bus',
                            time: '55',
                            isWhite: false,
                          ),
                          const SizedBox(height: 12),
                          _buildTransportCard(
                            icon: Icons.directions_walk,
                            name: 'Jalan kaki',
                            time: '120',
                            isWhite: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransportCard({
    required IconData icon,
    required String name,
    required String time,
    required bool isWhite,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isWhite ? Colors.white : const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isWhite ? const Color(0xFFF0F0F0) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: Colors.black87),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lama waktu tempuh:',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4AA5A6),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Menit',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MapPreviewCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const MapPreviewCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Map Background (Satellite/Realistic style)
                Image.network(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[300]),
                ),
                // Subtle dark gradient overlay to improve readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),

                // Route Line
                CustomPaint(
                  size: Size(constraints.maxWidth, 320),
                  painter: _RoutePainter(),
                ),

                // Place 1
                if (items.isNotEmpty) ...[
                  _buildFloatingCard(
                    top: 16,
                    left: constraints.maxWidth * 0.05,
                    title: items[0]['title'],
                    imageUrl: items[0]['imageUrl'],
                    info: items[0]['time'],
                  ),
                  _buildMarker(top: 86, left: constraints.maxWidth * 0.25),
                ],

                // Place 2
                if (items.length > 1) ...[
                  _buildFloatingCard(
                    top: 110,
                    right: constraints.maxWidth * 0.05,
                    title: items[1]['title'],
                    imageUrl: items[1]['imageUrl'],
                    info: items[1]['time'],
                  ),
                  _buildMarker(top: 136, left: constraints.maxWidth * 0.70),
                ],

                // Place 3
                if (items.length > 2) ...[
                  _buildFloatingCard(
                    bottom: 16,
                    left: constraints.maxWidth * 0.15,
                    title: items[2]['title'],
                    imageUrl: items[2]['imageUrl'],
                    info: items[2]['time'],
                  ),
                  _buildMarker(top: 226, left: constraints.maxWidth * 0.40),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarker({required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: const Color(0xFF9CCCD0), // Soft Teal
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCard({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String title,
    required String imageUrl,
    required String info,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                height: 50,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 20, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF4AA5A6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9CCCD0)
          .withOpacity(0.9) // Soft Teal
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Marker 1 center
    path.moveTo(size.width * 0.25 + 7, 86 + 7);

    // Curve down to Marker 2
    path.quadraticBezierTo(
      size.width * 0.5,
      95,
      size.width * 0.70 + 7,
      136 + 7,
    );

    // Curve down and left to Marker 3
    path.quadraticBezierTo(
      size.width * 0.6,
      200,
      size.width * 0.40 + 7,
      226 + 7,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
