import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Toggle this when switching between emulator and physical device
const bool _usePhysicalDevice = true;

String get _baseUrl {
  if (kIsWeb) return 'http://localhost:8000/api';
  if (_usePhysicalDevice) return 'http://${dotenv.env['ipaddress']}:8000/api';
  return 'http://10.0.2.2:8000/api'; // Android emulator
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  /// Send a 6-digit OTP to [email] for account registration verification.
  static Future<void> sendVerificationEmail(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register/send-verification/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(body['error'] ?? 'Gagal mengirim kode verifikasi.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Resend OTP to [email] — invalidates the old code and issues a new one.
  static Future<void> resendVerificationEmail(String email) async {
    await sendVerificationEmail(email);
  }

  /// Create a new user account. Email must have been OTP-verified first.
  static Future<void> register({
    required String name,
    required String username,
    required String password,
    required String email,
    required String negara,
    required String provinsi,
    required String kota,
    required String kecamatan,
    required String kelurahan,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'username': username,
              'password': password,
              'email': email,
              'negara': negara,
              'provinsi': provinsi,
              'kota': kota,
              'kecamatan': kecamatan,
              'kelurahan': kelurahan,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final err = body['error'];
        throw ApiException(err is List ? err.join(' ') : err ?? 'Gagal membuat akun.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Verify the 6-digit [code] sent to [email].
  static Future<void> verifyEmailCode(String email, String code) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register/verify-email/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(body['error'] ?? 'Kode tidak valid atau sudah kedaluwarsa.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Find account by username or email and send a password-reset OTP.
  /// Returns the email address the OTP was sent to.
  static Future<String> requestPasswordReset(String identifier) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/password-reset/request/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'identifier': identifier}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['email'] as String;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(body['error'] ?? body['detail'] ?? 'Akun tidak ditemukan.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Resend the password-reset OTP to [email].
  static Future<void> resendPasswordResetCode(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/password-reset/resend/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(body['error'] ?? body['detail'] ?? 'Gagal mengirim ulang kode.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Verify the password-reset OTP. Returns a short-lived reset token.
  static Future<String> verifyPasswordResetCode(String email, String code) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/password-reset/verify-code/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['reset_token'] as String;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(body['error'] ?? body['detail'] ?? 'Kode tidak valid atau sudah kedaluwarsa.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Set a new password using the [resetToken] obtained after OTP verification.
  static Future<void> confirmPasswordReset(String resetToken, String newPassword) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/password-reset/confirm/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'reset_token': resetToken, 'new_password': newPassword}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final err = body['error'] ?? body['detail'];
        throw ApiException(err is List ? err.join(' ') : err ?? 'Gagal mengubah kata sandi.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Update profile name, bio, and/or photo for [userId].
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    String? bio,
    String? photoPath,
    bool deletePhoto = false,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/profile/update/$userId/');
      final request = http.MultipartRequest('PATCH', uri);

      request.fields['name'] = name;
      if (bio != null) request.fields['bio'] = bio;
      if (deletePhoto) request.fields['delete_photo'] = 'true';
      if (photoPath != null && !deletePhoto) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_photo', photoPath),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['user'] as Map<String, dynamic>;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(body['error'] ?? 'Gagal memperbarui profil.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Upload a new unggahan with images
  static Future<Map<String, dynamic>> uploadUnggahan({
    required int userId,
    required String namaTempat,
    required String alamat,
    required String ulasan,
    required int rating,
    required String budget,
    required List<String> imagePaths,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/unggahan/');
      final request = http.MultipartRequest('POST', uri);

      request.fields['user_id'] = userId.toString();
      request.fields['nama_tempat'] = namaTempat;
      request.fields['alamat'] = alamat;
      request.fields['ulasan'] = ulasan;
      request.fields['rating'] = rating.toString();
      request.fields['budget'] = budget;

      for (final path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath('image', path));
      }

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(body['error'] ?? 'Gagal mengunggah.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Fetch all unggahan (newest first)
  static Future<List<Map<String, dynamic>>> fetchUnggahans() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/unggahan/'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list.cast<Map<String, dynamic>>();
      }
      throw ApiException('Gagal memuat unggahan.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Fetch bookmarks for a user (returns list of unggahan maps)
  static Future<List<Map<String, dynamic>>> fetchBookmarks(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/bookmarks/?user_id=$userId'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list.cast<Map<String, dynamic>>();
      }
      throw ApiException('Gagal memuat markah.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Add a bookmark
  static Future<void> addBookmark(int userId, int unggahanId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/bookmarks/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'unggahan_id': unggahanId}),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200 && response.statusCode != 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(body['error'] ?? 'Gagal menyimpan markah.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Remove a bookmark
  static Future<void> removeBookmark(int userId, int unggahanId) async {
    try {
      final request = http.Request(
        'DELETE',
        Uri.parse('$_baseUrl/bookmarks/$unggahanId/?user_id=$userId'),
      );
      request.headers['Content-Type'] = 'application/json';
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      if (streamedResponse.statusCode != 200) {
        throw ApiException('Gagal menghapus markah.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Login user using username/email and password
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'identifier': identifier, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['user'] as Map<String, dynamic>;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(body['error'] ?? 'Gagal masuk. Periksa kembali informasi Anda.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }
}
