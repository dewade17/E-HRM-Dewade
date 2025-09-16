// lib/providers/face/get_face_provider.dart
import 'package:e_hrm/dto/face/get_face/get_face.dart';
import 'package:flutter/foundation.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:e_hrm/contraints/endpoints.dart';

class GetFaceProvider extends ChangeNotifier {
  final ApiService _api;
  GetFaceProvider(this._api);

  bool loading = false;
  String? error;
  GetFace? result;

  bool get hasAny => (result?.count ?? 0) > 0;

  /// True jika ada file "embedding.npy" → user sudah enroll
  bool get hasEmbedding =>
      (result?.items.any((it) => it.name.toLowerCase() == 'embedding.npy')) ??
      false;

  Item? get embeddingItem {
    final items = result?.items ?? const <Item>[];
    for (final it in items) {
      if (it.name.toLowerCase() == 'embedding.npy') return it;
    }
    return null;
  }

  Item? get firstBaseline {
    final items = result?.items ?? const <Item>[];
    for (final it in items) {
      final n = it.name.toLowerCase();
      if (n.startsWith('baseline_') && n.endsWith('.jpg')) return it;
    }
    return null;
  }

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    error = msg;
    notifyListeners();
  }

  void _setResult(GetFace? data) {
    result = data;
    notifyListeners();
  }

  /// GET Face objects dari Face API (via fetchDataPrivate yang sudah mendukung absolute URL)
  Future<bool> fetch(String userId) async {
    if (userId.trim().isEmpty) {
      _setError('userId kosong');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final endpoint = '${Endpoints.getFace}/$userId'; // absolute URL → aman
      final json = await _api.fetchDataPrivate(endpoint);

      if (json['ok'] == true) {
        _setResult(GetFace.fromJson(json));
        _setLoading(false);
        return true;
      } else {
        final msg = (json['error'] ?? json['message'] ?? 'Gagal memuat data')
            .toString();
        _setError(msg);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> refresh(String userId) => fetch(userId);

  void clear() {
    result = null;
    error = null;
    loading = false;
    notifyListeners();
  }
}
