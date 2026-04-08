import 'package:flutter/material.dart';
import 'dart:math';
import 'models/unggahan.dart';

class NotificationDetailPage extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Unggahan>? places;

  const NotificationDetailPage({
    super.key,
    this.title,
    this.subtitle,
    this.places,
  });

  @override
  Widget build(BuildContext context) {
    final randomSeed = Random().nextInt(100000);

    final resolvedPlaces = places;
    final heroImage = (resolvedPlaces != null &&
            resolvedPlaces.isNotEmpty &&
            resolvedPlaces.first.imagePaths.isNotEmpty)
        ? resolvedPlaces.first.imagePaths.first
        : 'https://picsum.photos/seed/$randomSeed/800/550';

    final resolvedTitle = title ?? "Tempat Ini Favoritnya Warlok!";
    final resolvedSubtitle = subtitle ??
        "Kalau kamu lagi cari tempat seru buat hangout bareng teman mulai dari tempat nongkrong santai sampai area outdoor, ini dia rekomendasinya lengkap dengan infonya:";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.network(
                      heroImage,
                      width: double.infinity,
                      height: 320,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 320,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xFF4AA5A6)),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 320,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolvedTitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      resolvedSubtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (resolvedPlaces != null && resolvedPlaces.isNotEmpty)
                      ...resolvedPlaces.asMap().entries.map((entry) {
                        final index = entry.key;
                        final place = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildLocationItem(
                            number: '${index + 1}',
                            title: place.placeName,
                            address: place.address,
                            review: place.review.length > 100
                                ? '${place.review.substring(0, 100)}...'
                                : place.review,
                            budget: place.budget,
                          ),
                        );
                      })
                    else ...[
                      _buildDummyLocationItem(
                        number: "1",
                        title: "The Breeze, BSD",
                        address:
                            "BSD, Jl. BSD Green Office Park Jl. BSD Grand Boulevard, Sampora, Kec. Cisauk, Kabupaten Tangerang, Banten 15345",
                        ticket: "Gratis (bayar parkir saja)",
                        bestTimeSpan: const TextSpan(text: "Sore hari biar nggak terlalu panas"),
                      ),
                      const SizedBox(height: 20),
                      _buildDummyLocationItem(
                        number: "2",
                        title: "Scientia Square Park, Gading Serpong",
                        address:
                            "Jl. Scientia Boulevard, Curug Sangereng, Kecamatan Kelapa Dua, Kabupaten Tangerang, Banten 15810",
                        ticket: "Berbayar (harga tergantung hari kunjungan)",
                        bestTimeSpan: const TextSpan(
                          children: [
                            TextSpan(
                                text:
                                    "Pagi hari biar nggak terlalu ramai, sore hari untuk menikmati suasana "),
                            TextSpan(
                              text: "sunset",
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDummyLocationItem(
                        number: "3",
                        title: "The Barn, BSD",
                        address:
                            "PJ7F+X85, Jl. BSD Boulevard Utara, Lengkong Kulon, Kec. Pagedangan, Kabupaten Tangerang, Banten 15331",
                        ticket: "Gratis (bayar parkir saja)",
                        bestTimeSpan: const TextSpan(
                            text:
                                "Sore hari sampai malam hari, banyak tenant yang buka sampai malam"),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Used for dynamic data from API
  Widget _buildLocationItem({
    required String number,
    required String title,
    required String address,
    required String review,
    required String budget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$number. $title",
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4AA5A6),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black, height: 1.4),
            children: [
              const TextSpan(text: "Alamat: ", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: address),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black, height: 1.4),
            children: [
              const TextSpan(text: "Ulasan: ", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: review),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black, height: 1.4),
            children: [
              const TextSpan(text: "Budget: ", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: budget),
            ],
          ),
        ),
      ],
    );
  }

  // Used for the original dummy data (preserves ticket & bestTimeSpan)
  Widget _buildDummyLocationItem({
    required String number,
    required String title,
    required String address,
    required String ticket,
    required InlineSpan bestTimeSpan,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$number. $title",
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4AA5A6),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black, height: 1.4),
            children: [
              const TextSpan(text: "Alamat: ", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: address),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black, height: 1.4),
            children: [
              const TextSpan(text: "Tiket masuk: ", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ticket),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black, height: 1.4),
            children: [
              const TextSpan(text: "Best time to visit: ", style: TextStyle(fontWeight: FontWeight.bold)),
              bestTimeSpan,
            ],
          ),
        ),
      ],
    );
  }
}
