import 'package:flutter/material.dart';

class PrivacyNoticePage extends StatelessWidget {
  const PrivacyNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4AA5A6),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
        title: const Text(
          'Pemberitahuan Privasi',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              number: '1',
              title: 'Pendahuluan',
              body:
                  'Aplikasi FindKal menghargai dan melindungi privasi setiap pengguna. Pemberitahuan privasi ini menjelaskan bagaimana data pengguna dikumpulkan, digunakan, disimpan, dan dilindungi selama penggunaan aplikasi. Dengan menggunakan aplikasi FindKal, pengguna dianggap telah membaca dan menyetujui kebijakan privasi ini.',
            ),
            SizedBox(height: 28),
            _Section(
              number: '2',
              title: 'Data yang Dikumpulkan',
              body:
                  'Kami mengumpulkan data yang diberikan langsung oleh pengguna seperti nama, username, email, dan lokasi. Data ini digunakan semata-mata untuk keperluan layanan aplikasi FindKal.',
            ),
            SizedBox(height: 28),
            _Section(
              number: '3',
              title: 'Penggunaan Data',
              body:
                  'Data pengguna digunakan untuk menyediakan layanan rekomendasi tempat, personalisasi pengalaman pengguna, serta peningkatan kualitas aplikasi. Kami tidak menjual atau membagikan data pengguna kepada pihak ketiga tanpa izin.',
            ),
            SizedBox(height: 28),
            _Section(
              number: '4',
              title: 'Penyimpanan dan Keamanan',
              body:
                  'Data pengguna disimpan pada server yang aman dan dilindungi dengan enkripsi. Kami menerapkan langkah-langkah keamanan yang wajar untuk mencegah akses tidak sah, perubahan, atau penghapusan data.',
            ),
            SizedBox(height: 28),
            _Section(
              number: '5',
              title: 'Hak Pengguna',
              body:
                  'Pengguna berhak untuk mengakses, memperbarui, atau menghapus data pribadi mereka kapan saja melalui pengaturan akun. Jika ada pertanyaan mengenai data pribadi, pengguna dapat menghubungi tim kami.',
            ),
            SizedBox(height: 28),
            _Section(
              number: '6',
              title: 'Perubahan Kebijakan',
              body:
                  'Kami berhak mengubah kebijakan privasi ini sewaktu-waktu. Perubahan akan diberitahukan melalui aplikasi. Dengan terus menggunakan aplikasi setelah perubahan berlaku, pengguna dianggap menyetujui kebijakan yang diperbarui.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _Section({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. $title',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
