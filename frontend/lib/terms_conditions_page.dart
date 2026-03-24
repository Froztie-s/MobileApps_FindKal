import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
          'Syarat & Ketentuan',
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
              title: 'Ketentuan Umum',
              points: [
                'Aplikasi FindKal merupakan platform digital yang digunakan untuk membantu pengguna dalam mendapatkan rekomendasi tempat serta merencanakan perjalanan.',
                'Dengan menggunakan aplikasi ini, pengguna dianggap telah membaca, memahami, dan menyetujui seluruh syarat dan ketentuan yang berlaku.',
                'Pengembang berhak untuk mengubah syarat dan ketentuan sewaktu-waktu tanpa pemberitahuan sebelumnya.',
              ],
            ),
            SizedBox(height: 28),
            _Section(
              number: '2',
              title: 'Ketentuan Pengguna',
              points: [
                'Pengguna wajib melakukan registrasi akun untuk mengakses fitur utama aplikasi.',
                'Pengguna bertanggung jawab atas keamanan akun masing-masing.',
                'Pengguna wajib memberikan data yang benar, akurat, dan tidak menyesatkan.',
                'Pengguna dilarang menggunakan aplikasi untuk tujuan yang melanggar hukum atau merugikan pihak lain.',
              ],
            ),
            SizedBox(height: 28),
            _Section(
              number: '3',
              title: 'Penggunaan Fitur Aplikasi',
              points: [
                'Pengguna dapat mencari, memilih, dan menyusun destinasi ke dalam itinerary.',
                'Pengguna dapat mengedit, menyimpan, dan menghapus itinerary sesuai kebutuhan.',
                'Semua data itinerary yang dibuat bersifat pribadi dan hanya dapat diakses oleh pemilik akun.',
              ],
            ),
            SizedBox(height: 28),
            _Section(
              number: '4',
              title: 'Estimasi dan Informasi',
              points: [
                'Informasi terkait destinasi, biaya, dan waktu perjalanan bersifat estimasi.',
                'Pengembang tidak menjamin keakuratan data secara mutlak karena bergantung pada sumber pihak ketiga.',
                'Pengguna disarankan untuk melakukan verifikasi tambahan sebelum melakukan perjalanan.',
              ],
            ),
            SizedBox(height: 28),
            _Section(
              number: '5',
              title: 'Batasan Tanggung Jawab',
              points: [
                'Pengembang tidak bertanggung jawab atas kerugian yang timbul akibat penggunaan informasi dalam aplikasi.',
                'Pengembang bertanggung jawab atas gangguan layanan yang disebabkan oleh faktor eksternal seperti jaringan internet atau layanan pihak ketiga.',
              ],
            ),
            SizedBox(height: 28),
            _Section(
              number: '6',
              title: 'Keamanan dan Privasi',
              points: [
                'Data pengguna akan disimpan dan dilindungi sesuai dengan kebijakan privasi yang berlaku.',
                'Pengguna dilarang mengakses atau mencoba mengakses data pengguna lain tanpa izin.',
              ],
            ),
            SizedBox(height: 28),
            _Section(
              number: '7',
              title: 'Penutup',
              points: [
                'Dengan menggunakan aplikasi FindKal, pengguna dianggap telah menyetujui seluruh syarat dan ketentuan ini.',
                'Jika pengguna tidak menyetujui ketentuan yang berlaku, maka disarankan untuk tidak menggunakan aplikasi.',
              ],
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
  final List<String> points;

  const _Section({
    required this.number,
    required this.title,
    required this.points,
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
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
