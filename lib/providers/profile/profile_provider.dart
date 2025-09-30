import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/profile/profile.dart' as dto;
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProfileProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _loading = false;
  bool get loading => _loading;

  bool _saving = false;
  bool get saving => _saving;

  String? _error;
  String? get error => _error;

  String? _lastMessage;
  String? get lastMessage => _lastMessage;

  dto.Data? _profile;
  dto.Data? get profile => _profile;

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

  Map<String, dynamic> _normalizeBody(Map<String, dynamic> raw) {
    final normalized = <String, dynamic>{};
    raw.forEach((key, value) {
      if (value is DateTime) {
        normalized[key] = value.toIso8601String();
      } else if (value is bool) {
        normalized[key] = value;
      } else if (value != null) {
        normalized[key] = value.toString();
      } else {
        normalized[key] = null;
      }
    });
    return normalized;
  }

  Future<bool> fetchProfile(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) return false;

    _setLoading(true);
    _error = null;
    _lastMessage = null;
    notifyListeners();

    try {
      final endpoint = '${Endpoints.users}/$id';
      final res = await _api.fetchDataPrivate(endpoint);
      final dataMap = (res['data'] is Map)
          ? Map<String, dynamic>.from(res['data'] as Map)
          : <String, dynamic>{};
      if (dataMap.isEmpty) {
        _profile = null;
        _error = 'Data profil kosong.';
        notifyListeners();
        return false;
      }
      _profile = dto.Data.fromJson(dataMap);
      _error = null;
      _lastMessage = res['message'] as String?;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(
    String userId,
    Map<String, dynamic> body, {
    http.MultipartFile? foto,
    bool removePhoto = false,
  }) async {
    final id = userId.trim();
    if (id.isEmpty) return false;

    _setSaving(true);
    _error = null;
    _lastMessage = null;
    notifyListeners();

    try {
      final payload = Map<String, dynamic>.from(body);
      if (removePhoto) {
        payload['remove_foto'] = true;
      }

      final hasFile = foto != null;
      final endpoint = '${Endpoints.users}/$id';

      Map<String, dynamic> response;
      if (hasFile) {
        final normalized = _normalizeBody(payload);
        response = await _api.putFormDataPrivate(
          endpoint,
          normalized,
          files: [foto],
        );
      } else {
        final normalized = _normalizeBody(payload);
        response = await _api.updateDataPrivate(endpoint, normalized);
      }

      final dataMap = (response['data'] is Map)
          ? Map<String, dynamic>.from(response['data'] as Map)
          : <String, dynamic>{};
      if (dataMap.isNotEmpty) {
        _profile = dto.Data.fromJson(dataMap);
      }
      _lastMessage = response['message'] as String?;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void clear() {
    _profile = null;
    _error = null;
    _lastMessage = null;
    _loading = false;
    _saving = false;
    notifyListeners();
  }
}
