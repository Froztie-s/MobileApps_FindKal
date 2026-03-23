import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

// Auto-selects the correct base URL depending on the platform:
// - Web (browser): localhost resolves to the host machine
// - Android emulator: 10.0.2.2 is the host machine alias
// - Physical device: change to your machine's LAN IP (e.g. 192.168.1.x)
String get _baseUrl =>
    kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';

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
}
