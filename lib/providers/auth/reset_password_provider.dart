// lib/providers/auth/reset_password_provider.dart
import 'package:flutter/foundation.dart';
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/services/api_services.dart';

class ResetPasswordProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool requesting = false;
  bool confirming = false;
  String? message;
  String? error;

  void _setRequesting(bool v) {
    requesting = v;
    notifyListeners();
  }

  void _setConfirming(bool v) {
    confirming = v;
    notifyListeners();
  }

  void _setResult({String? msg, String? err}) {
    message = msg;
    error = err;
    notifyListeners();
  }

  /// Minta OTP ke email (server balas pesan generik).
  Future<bool> requestToken(String email) async {
    _setRequesting(true);
    try {
      final res = await _api.post({
        'email': email.trim(),
      }, Endpoints.resetRequestToken);
      _setResult(
        msg: (res['message'] ?? 'Kode reset telah dikirim.') as String?,
      );
      return true;
    } catch (e) {
      _setResult(err: _extractError(e));
      return false;
    } finally {
      _setRequesting(false);
    }
  }

  /// Konfirmasi reset dengan OTP + password baru.
  Future<bool> confirmReset({
    required String otp,
    required String newPassword,
  }) async {
    _setConfirming(true);
    try {
      final res = await _api.post({
        'token': otp.trim(),
        'password': newPassword,
      }, Endpoints.resetConfirm);
      _setResult(
        msg: (res['message'] ?? 'Password berhasil direset.') as String?,
      );
      return true;
    } catch (e) {
      _setResult(err: _extractError(e));
      return false;
    } finally {
      _setConfirming(false);
    }
  }

  void clear() => _setResult(msg: null, err: null);

  String _extractError(Object e) {
    final s = e.toString();
    if (s.contains('"message"')) {
      final start = s.indexOf('"message"');
      if (start != -1) {
        final sub = s.substring(start);
        final close = sub.indexOf('}');
        if (close != -1) {
          return sub
              .substring(0, close + 1)
              .replaceAll('"message":', '')
              .replaceAll(RegExp(r'[\{\}"\:]'), '')
              .trim();
        }
      }
    }
    return s.replaceFirst('Exception: ', '');
  }
}
