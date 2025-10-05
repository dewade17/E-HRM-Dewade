// lib/providers/istirahat/istirahat_provider.dart

import 'dart:convert'; // <-- Impor pustaka dart:convert
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/istirahat/istirahat.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';

class IstirahatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _loading = false;
  bool get loading => _loading;

  bool _saving = false;
  bool get saving => _saving;

  String? _error;
  String? get error => _error;

  String? _message;
  String? get message => _message;

  Istirahat? _status;
  Istirahat? get status => _status;

  bool get isIstirahatActive => _status?.activeBreak != null;

  void _setLoading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    if (_saving == value) return;
    _saving = value;
    notifyListeners();
  }

  void _clearMessages() {
    _error = null;
    _message = null;
  }

  // --- FUNGSI YANG DIPERBAIKI ---
  String _extractError(Object e) {
    final s = e.toString();
    // Mencari format JSON error dari backend di dalam string Exception
    try {
      final jsonStartIndex = s.indexOf('{');
      if (jsonStartIndex != -1) {
        final jsonEndIndex = s.lastIndexOf('}');
        if (jsonEndIndex > jsonStartIndex) {
          final jsonString = s.substring(jsonStartIndex, jsonEndIndex + 1);
          final decoded = json.decode(jsonString);
          if (decoded is Map) {
            // Backend Anda menggunakan kunci 'error'
            final errorMsg = decoded['error'];
            if (errorMsg is String && errorMsg.isNotEmpty) {
              return errorMsg;
            }
            // Fallback jika backend menggunakan 'message'
            final messageMsg = decoded['message'];
            if (messageMsg is String && messageMsg.isNotEmpty) {
              return messageMsg;
            }
          }
        }
      }
    } catch (_) {
      // Abaikan jika parsing gagal, gunakan fallback di bawah
    }

    // Fallback jika tidak ditemukan format JSON
    return s.replaceFirst('Exception: ', '');
  }

  /// Mengambil status istirahat terakhir untuk seorang pengguna.
  Future<bool> fetchStatus(String userId) async {
    if (userId.trim().isEmpty) {
      _error = "User ID tidak boleh kosong.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      final uri = Uri.parse(
        Endpoints.istirahatStatus,
      ).replace(queryParameters: {'user_id': userId});
      final res = await _api.fetchDataPrivate(uri.toString());

      _status = Istirahat.fromJson(res);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractError(e); // <-- Menggunakan helper yang sudah diperbaiki
      _status = null;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Memulai sesi istirahat baru.
  Future<bool> startIstirahat({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    _setSaving(true);
    _clearMessages();

    try {
      final data = {
        'user_id': userId,
        'start_istirahat_latitude': latitude.toString(),
        'start_istirahat_longitude': longitude.toString(),
      };
      final res = await _api.postFormDataPrivate(
        Endpoints.istirahatStart,
        data,
      );

      _message = res['message'] as String?;
      await fetchStatus(userId);
      return true;
    } catch (e) {
      _error = _extractError(e); // <-- Menggunakan helper yang sudah diperbaiki
      notifyListeners();
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// Mengakhiri sesi istirahat yang sedang berjalan.
  Future<bool> endIstirahat({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    _setSaving(true);
    _clearMessages();

    try {
      final data = {
        'user_id': userId,
        'end_istirahat_latitude': latitude.toString(),
        'end_istirahat_longitude': longitude.toString(),
      };
      final res = await _api.postFormDataPrivate(Endpoints.istirahatEnd, data);

      _message = res['message'] as String?;
      await fetchStatus(userId);
      return true;
    } catch (e) {
      _error = _extractError(e); // <-- Menggunakan helper yang sudah diperbaiki
      notifyListeners();
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void clear() {
    _loading = false;
    _saving = false;
    _error = null;
    _message = null;
    _status = null;
    notifyListeners();
  }
}
