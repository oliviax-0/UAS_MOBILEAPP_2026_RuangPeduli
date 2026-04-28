import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

// ─── GOOGLE SIGN-IN SERVICE ──────────────────────────────────────────────────
class GoogleSignInService {
  static final _googleSignIn = GoogleSignIn(
    clientId: '773421848878-1dagn4rc098tqg20e1r84vc3100uim9g.apps.googleusercontent.com', // iOS
    serverClientId: '110989165138-dkq12aq8luceufu4lh2bn3kkrnpo8k4c.apps.googleusercontent.com', // Android
    scopes: ['email', 'profile'],
  );

  /// Opens the Google account picker and returns the id_token string.
  /// Returns null if the user cancelled. Throws on error.
  static Future<String?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // user cancelled
      final auth = await account.authentication;
      final token = auth.idToken;
      if (token == null) throw Exception('Gagal mendapatkan token dari Google');
      return token;
    } catch (e) {
      throw Exception('Google Sign-In gagal: $e');
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

class RegisterData {
  final String username;
  final String email;
  final String password;
  final String role;
  final String? namaPengguna;
  final String? alamat;
  final String? nomorTelepon;
  final String? namaPanti;
  final String? alamatPanti;
  final String? nomorPanti;
  final String? provinsiPanti;
  final String? kabupatenKotaPanti;
  final String? kecamatanPanti;
  final String? kelurahanPanti;
  final String? kodePosPanti;
  final double? latPanti;
  final double? lngPanti;

  RegisterData({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.namaPengguna,
    this.alamat,
    this.nomorTelepon,
    this.namaPanti,
    this.alamatPanti,
    this.nomorPanti,
    this.provinsiPanti,
    this.kabupatenKotaPanti,
    this.kecamatanPanti,
    this.kelurahanPanti,
    this.kodePosPanti,
    this.latPanti,
    this.lngPanti,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'nama_pengguna': namaPengguna,
      'alamat': alamat,
      'nomor_telepon': nomorTelepon,
      'nama_panti': namaPanti,
      'alamat_panti': alamatPanti,
      'nomor_panti': nomorPanti,
      'provinsi_panti': provinsiPanti,
      'kabupaten_kota_panti': kabupatenKotaPanti,
      'kecamatan_panti': kecamatanPanti,
      'kelurahan_panti': kelurahanPanti,
      'kode_pos_panti': kodePosPanti,
      'lat_panti': latPanti,
      'lng_panti': lngPanti,
    }..removeWhere((k, v) => v == null);
  }
}

class AppConfig {
  // ─── PRODUCTION URL ───────────────────────────────────────────────
  // Set this to your deployed backend URL (e.g. Railway/Render).
  // Leave empty to fall back to local dev mode.
  static const String productionUrl = 'https://ruangpeduli.onrender.com/api';

  // ─── DEV CONFIG ───────────────────────────────────────────────────
  // IP laptop kamu — dipakai untuk physical device + simulator sekaligus
  static const String devIp = '10.10.179.35';  // ✏️ ganti ke IP laptop kamu
  static const bool useLanIp = true;

  static String get baseUrl {
    // Use production URL if set (release builds / deployed backend)
    if (productionUrl.isNotEmpty) return productionUrl;

    // Dev fallback
    if (useLanIp && devIp.isNotEmpty) {
      return 'http://$devIp:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }
}

class AuthApi {
  final String baseUrl = AppConfig.baseUrl;

  // ─── REGISTER START ───────────────────────────────────────────────
  Future<String> startRegister(RegisterData data) async {
    final url = Uri.parse('$baseUrl/pending/');
    print('📤 POST $url');
    print('📦 Body: ${jsonEncode(data.toJson())}');

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data.toJson()),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout, cek jaringan'),
          );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        // ✅ Ambil pesan error spesifik dari backend
        final error = jsonDecode(res.body);
        throw Exception(error['error'] ?? 'Registrasi gagal');
      }

      final json = jsonDecode(res.body);
      return json['pending_id'].toString();
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── VERIFY OTP ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp(String pendingId, String otp) async {
    final url = Uri.parse('$baseUrl/verify/');
    print('📤 POST $url');
    print('📦 Body: pending_id=$pendingId, otp=$otp');

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'pending_id': pendingId, 'otp': otp}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout'),
          );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        final body = jsonDecode(res.body);
        throw Exception(body['error'] ?? 'Verifikasi gagal');
      }

      return jsonDecode(res.body) as Map<String, dynamic>;
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── LOGIN ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/login/');
    print('📤 POST $url');

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password, 'role': role}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout'),
          );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode != 200) {
        final body = jsonDecode(res.body);
        throw Exception(body['error'] ?? 'Login gagal');
      }

      return jsonDecode(res.body) as Map<String, dynamic>;
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── FORGOT PASSWORD ──────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password/');
    print('📤 POST $url');

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout'),
          );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode != 200) {
        final body = jsonDecode(res.body);
        throw Exception(body['error'] ?? 'Gagal mengirim OTP');
      }
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── RESET PASSWORD ───────────────────────────────────────────────
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset-password/');
    print('📤 POST $url');

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp': otp, 'new_password': newPassword}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout'),
          );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode != 200) {
        final body = jsonDecode(res.body);
        throw Exception(body['error'] ?? 'Gagal reset sandi');
      }
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── GOOGLE AUTH ──────────────────────────────────────────────────
  /// Verify Google id_token with backend.
  /// Returns the full response map:
  ///   exists=true  → {exists, user_id, username, email, role}
  ///   exists=false → {exists, email, name}
  Future<Map<String, dynamic>> googleAuth(String idToken, String role) async {
    final url = Uri.parse('$baseUrl/google-auth/');
    print('📤 POST $url');

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken, 'role': role}),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw Exception('Koneksi timeout'),
          );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode != 200) {
        final body = jsonDecode(res.body);
        throw Exception(body['error'] ?? 'Google auth gagal');
      }

      return jsonDecode(res.body) as Map<String, dynamic>;
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── GOOGLE REGISTER ──────────────────────────────────────────────
  Future<Map<String, dynamic>> googleRegister({
    required String idToken,
    required String role,
    required String username,
    String? namaPengguna,
    String? alamat,
    String? nomorTelepon,
    String? namaPanti,
    String? alamatPanti,
    String? nomorPanti,
    String? provinsiPanti,
    String? kabupatenKotaPanti,
    String? kecamatanPanti,
    String? kelurahanPanti,
    String? kodePosPanti,
    double? latPanti,
    double? lngPanti,
  }) async {
    final url = Uri.parse('$baseUrl/google-register/');
    print('📤 POST $url');

    final body = <String, dynamic>{
      'id_token': idToken,
      'role': role,
      'username': username,
      if (namaPengguna != null) 'nama_pengguna': namaPengguna,
      if (alamat != null) 'alamat': alamat,
      if (nomorTelepon != null) 'nomor_telepon': nomorTelepon,
      if (namaPanti != null) 'nama_panti': namaPanti,
      if (alamatPanti != null) 'alamat_panti': alamatPanti,
      if (nomorPanti != null) 'nomor_panti': nomorPanti,
      if (provinsiPanti != null) 'provinsi_panti': provinsiPanti,
      if (kabupatenKotaPanti != null) 'kabupaten_kota_panti': kabupatenKotaPanti,
      if (kecamatanPanti != null) 'kecamatan_panti': kecamatanPanti,
      if (kelurahanPanti != null) 'kelurahan_panti': kelurahanPanti,
      if (kodePosPanti != null) 'kode_pos_panti': kodePosPanti,
      if (latPanti != null) 'lat_panti': latPanti,
      if (lngPanti != null) 'lng_panti': lngPanti,
    };

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw Exception('Koneksi timeout'),
          );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        final decoded = jsonDecode(res.body);
        throw Exception(decoded['error'] ?? 'Registrasi Google gagal');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── RESEND OTP ───────────────────────────────────────────────────
  Future<void> resendOtp(String email) async {
    final url = Uri.parse('$baseUrl/resend-otp/');
    print('📤 POST $url');

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout'),
          );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode != 200) {
        final body = jsonDecode(res.body);
        throw Exception(body['error'] ?? 'Gagal kirim ulang OTP');
      }
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── CHANGE PASSWORD ──────────────────────────────────────────────
  Future<void> changePassword(int userId, String currentPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/change-password/');
    try {
      final res = await http
          .post(url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'user_id': userId, 'current_password': currentPassword, 'new_password': newPassword}))
          .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Koneksi timeout'));
      final body = jsonDecode(res.body);
      if (res.statusCode != 200) throw Exception(body['error'] ?? 'Gagal mengubah kata sandi');
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── REQUEST EMAIL CHANGE (step 1) ───────────────────────────────
  /// Sends OTP to user's CURRENT email. Returns the email OTP was sent to.
  Future<String> requestEmailChange(int userId) async {
    final url = Uri.parse('$baseUrl/request-email-change/');
    try {
      final res = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'user_id': userId}))
          .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Koneksi timeout'));
      final body = jsonDecode(res.body);
      if (res.statusCode != 200) throw Exception(body['error'] ?? 'Gagal mengirim OTP');
      return body['sent_to'] as String;
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── REQUEST NEW EMAIL VERIFY (step 3) ───────────────────────────
  /// Verifies current email OTP, then sends OTP to NEW email.
  /// Returns the new email OTP was sent to.
  Future<String> requestNewEmailVerify(int userId, String otpCurrent, String newEmail) async {
    final url = Uri.parse('$baseUrl/request-new-email-verify/');
    try {
      final res = await http
          .post(url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'user_id': userId, 'otp_current': otpCurrent, 'new_email': newEmail}))
          .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Koneksi timeout'));
      final body = jsonDecode(res.body);
      if (res.statusCode != 200) throw Exception(body['error'] ?? 'Gagal mengirim OTP ke email baru');
      return body['sent_to'] as String;
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  // ─── CONFIRM EMAIL CHANGE (step 4) ───────────────────────────────
  /// Verifies new email OTP and saves the new email. Returns the new email.
  Future<String> confirmEmailChange(int userId, String otpNew, String newEmail) async {
    final url = Uri.parse('$baseUrl/confirm-email-change/');
    try {
      final res = await http
          .post(url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'user_id': userId, 'otp_new': otpNew, 'new_email': newEmail}))
          .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Koneksi timeout'));
      final body = jsonDecode(res.body);
      if (res.statusCode != 200) throw Exception(body['error'] ?? 'Gagal mengubah email');
      return body['new_email'] as String;
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }
}