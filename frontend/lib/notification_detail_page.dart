import 'package:flutter/material.dart';
import 'dart:math';

class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate a random seed to assure a random image is loaded each time
    final randomSeed = Random().nextInt(100000);
    final imageUrl = 'https://picsum.photos/seed/$randomSeed/800/550';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                    imageUrl,
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
                          child: CircularProgressIndicator(
                            color: Color(0xFF4AA5A6),
                          ),
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
                              color: Colors.black.withOpacity(0.1),
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
                  const Text(
                    "Tempat Ini Favoritnya Warlok!",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Kalau kamu lagi cari tempat seru buat hangout bareng teman mulai dari tempat nongkrong santai sampai area outdoor, ini dia rekomendasinya lengkap dengan infonya:",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLocationItem(
                    number: "1",
                    title: "The Breeze, BSD",
                    address: "BSD, Jl. BSD Green Office Park Jl. BSD Grand Boulevard, Sampora, Kec. Cisauk, Kabupaten Tangerang, Banten 15345",
                    ticket: "Gratis (bayar parkir saja)",
                    bestTimeSpan: const TextSpan(
                      text: "Sore hari biar nggak terlalu panas",
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLocationItem(
                    number: "2",
                    title: "Scientia Square Park, Gading Serpong",
                    address: "Jl. Scientia Boulevard, Curug Sangereng, Kecamatan Kelapa Dua, Kabupaten Tangerang, Banten 15810",
                    ticket: "Berbayar (harga tergantung hari kunjungan)",
                    bestTimeSpan: const TextSpan(
                      children: [
                        TextSpan(text: "Pagi hari biar nggak terlalu ramai, sore hari untuk menikmati suasana "),
                        TextSpan(
                          text: "sunset",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLocationItem(
                    number: "3",
                    title: "The Barn, BSD",
                    address: "PJ7F+X85, Jl. BSD Boulevard Utara, Lengkong Kulon, Kec. Pagedangan, Kabupaten Tangerang, Banten 15331",
                    ticket: "Gratis (bayar parkir saja)",
                    bestTimeSpan: const TextSpan(
                      text: "Sore hari sampai malam hari, banyak tenant yang buka sampai malam",
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem({
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
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: "Alamat: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: address),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: "Tiket masuk: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ticket),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: "Best time to visit: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              bestTimeSpan,
            ],
          ),
        ),
      ],
    );
  }
}
