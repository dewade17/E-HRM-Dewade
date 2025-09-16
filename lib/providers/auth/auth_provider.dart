// ignore_for_file: use_build_context_synchronously

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/auth/getdataprivate.dart';
import 'package:e_hrm/dto/auth/login.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:e_hrm/screens/face/face_enroll_screen/face_enroll_screen.dart';
import 'package:e_hrm/providers/face/get_face/get_face_provider.dart';

class AuthProvider extends ChangeNotifier {
  // Tidak pakai injeksi: langsung bikin instance di sini
  final ApiService _api = ApiService();

  AuthProvider();

  bool _loading = false;
  bool get loading => _loading;

  String? _accessToken;
  String? get accessToken => _accessToken;

  Getdataprivate? _currentUser;
  Getdataprivate? get currentUser => _currentUser;

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> _persistMinimalUserFields(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    final id = userJson['id_user'];
    final nama = userJson['nama_pengguna'];
    final email = userJson['email'];

    if (id != null) {
      await prefs.setString('id_user', id.toString());
    } else {
      await prefs.remove('id_user');
    }
    if (nama != null) {
      await prefs.setString('nama', nama.toString());
    } else {
      await prefs.remove('nama');
    }
    if (email != null) {
      await prefs.setString('email', email.toString());
    } else {
      await prefs.remove('email');
    }
  }

  /// LOGIN (tanpa refresh token)
  /// LOGIN (tanpa refresh token)
  Future<void> login(BuildContext context, Login payload) async {
    final messenger = ScaffoldMessenger.of(context);
    _setLoading(true);
    try {
      // 1) Hit endpoint login (public)
      final res = await _api.post(payload.toJson(), Endpoints.login);

      // 2) Ambil access token
      final access = (res['accessToken'] ?? res['token'] ?? '').toString();
      if (access.isEmpty) {
        throw Exception('accessToken tidak ditemukan pada respons.');
      }

      // 3) Simpan token ke SharedPreferences & state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', access);
      _accessToken = access;
      notifyListeners();

      // 4) Ambil profil private
      final me = await _api.fetchDataPrivate(Endpoints.getdataprivate);
      final userJson = (me['user'] ?? me) as Map<String, dynamic>;
      _currentUser = Getdataprivate.fromJson(userJson);
      await _persistMinimalUserFields(userJson);
      notifyListeners();

      // 5) Feedback
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.succesColor,
          content: Text((res['message'] ?? 'Login berhasil').toString()),
        ),
      );

      // 6) Cek enrol wajah via GetFaceProvider (tanpa pakai flag lokal)
      if (context.mounted) {
        final uid = _currentUser?.idUser;
        if (uid != null) {
          final getFaceProvider = GetFaceProvider(_api);
          try {
            final ok = await getFaceProvider.fetch(uid);
            final hasData =
                ok && getFaceProvider.hasAny; // count > 0 dan ada item
            if (!hasData) {
              // Belum ada data → arahkan ke enrol
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => FaceEnrollScreen(userId: uid),
                ),
              );
              _setLoading(false);
              return;
            }
          } catch (_) {
            // Gagal cek → default arahkan ke enrol
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) => FaceEnrollScreen(userId: uid),
              ),
            );
            _setLoading(false);
            return;
          }
        }
      }

      // 7) Navigasi by role
      if (!context.mounted) return;
      final role = (_currentUser?.role ?? '').toUpperCase();
      String targetRoute = '/login';
      if (role == 'KARYAWAN' ||
          role == 'HR' ||
          role == 'OPERASIONAL' ||
          role == 'DIREKTUR') {
        targetRoute = '/home-screen';
      }
      Navigator.of(context).pushNamedAndRemoveUntil(targetRoute, (r) => false);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorColor,
          content: Text('Login gagal: $e'),
        ),
      );
      await _clearSession();
    } finally {
      _setLoading(false);
    }
  }

  /// Pulihkan sesi saat app start
  Future<void> tryRestoreSession(BuildContext context) async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        await _clearSession();
        return;
      }

      bool expired = true;
      try {
        expired = JwtDecoder.isExpired(token);
      } catch (_) {
        expired = true;
      }
      if (expired) {
        await _clearSession();
        return;
      }

      _accessToken = token;

      final me = await _api.fetchDataPrivate(Endpoints.getdataprivate);
      final userJson = (me['user'] ?? me) as Map<String, dynamic>;
      _currentUser = Getdataprivate.fromJson(userJson);
      await _persistMinimalUserFields(userJson);
      notifyListeners();
    } catch (_) {
      await _clearSession();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reloadProfile() async {
    final me = await _api.fetchDataPrivate(Endpoints.getdataprivate);
    final userJson = (me['user'] ?? me) as Map<String, dynamic>;
    _currentUser = Getdataprivate.fromJson(userJson);
    await _persistMinimalUserFields(userJson);
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await _clearSession();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.succesColor,
        content: const Text('Anda telah keluar.'),
      ),
    );
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('id_user');
    await prefs.remove('nama');
    await prefs.remove('email');

    _accessToken = null;
    _currentUser = null;
    notifyListeners();
  }
}
