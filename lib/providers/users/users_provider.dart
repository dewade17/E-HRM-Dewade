// lib/providers/users/user_detail_provider.dart
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/users/users.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UserDetailProvider extends ChangeNotifier {
  // Tanpa injeksi: bikin instance sendiri
  final ApiService _api = ApiService();

  // State
  bool loading = false;
  bool saving = false;
  String? error;
  String? message;

  // Data user
  Users? user;

  String _url(String id) => '${Endpoints.users}/$id';

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setSaving(bool v) {
    saving = v;
    notifyListeners();
  }

  void _setResult({String? msg, String? err}) {
    message = msg;
    error = err;
    notifyListeners();
  }

  /// GET /users/{id}
  Future<bool> fetchById(String id) async {
    _setLoading(true);
    try {
      final res = await _api.fetchDataPrivate(_url(id));
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        user = Users.fromJson(data);
      }
      _setResult(msg: null, err: null);
      return true;
    } catch (e) {
      _setResult(err: e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// PUT /users/{id} JSON (tanpa foto)
  Future<bool> updateByIdJson(
    String id, {
    String? namaPengguna,
    String? email,
    String? kontak,
    String? agama,
    DateTime? tanggalLahir,
    String? idDepartement,
    String? idLocation,
    String? role,
    bool? removeFoto,
  }) async {
    _setSaving(true);
    try {
      final body = <String, dynamic>{
        if (namaPengguna != null) 'nama_pengguna': namaPengguna.trim(),
        if (email != null) 'email': email.trim().toLowerCase(),
        if (kontak != null) 'kontak': kontak.trim(),
        if (agama != null) 'agama': agama.trim(),
        if (tanggalLahir != null)
          'tanggal_lahir': tanggalLahir.toIso8601String(),
        if (idDepartement != null) 'id_departement': idDepartement,
        if (idLocation != null) 'id_location': idLocation,
        if (role != null) 'role': role,
        if (removeFoto != null) 'remove_foto': removeFoto,
      };

      final res = await _api.updateDataPrivate(_url(id), body);
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        user = _mergeDetail(Users.fromJson(data));
      }
      _setResult(msg: res['message'] ?? 'Profil berhasil diperbarui.');
      return true;
    } catch (e) {
      _setResult(err: e.toString());
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// PUT /users/{id} multipart (ganti foto + optional field lain)
  Future<bool> updateByIdWithPhoto(
    String id, {
    required XFile foto,
    String? namaPengguna,
    String? email,
    String? kontak,
    String? agama,
    DateTime? tanggalLahir,
    String? idDepartement,
    String? idLocation,
    String? role,
    bool? removeFoto,
  }) async {
    _setSaving(true);
    try {
      // Fields form-data
      final fields = <String, dynamic>{
        if (namaPengguna != null) 'nama_pengguna': namaPengguna.trim(),
        if (email != null) 'email': email.trim().toLowerCase(),
        if (kontak != null) 'kontak': kontak.trim(),
        if (agama != null) 'agama': agama.trim(),
        if (tanggalLahir != null)
          'tanggal_lahir': tanggalLahir.toIso8601String(),
        if (idDepartement != null) 'id_departement': idDepartement,
        if (idLocation != null) 'id_location': idLocation,
        if (role != null) 'role': role,
        if (removeFoto != null) 'remove_foto': removeFoto.toString(),
      };

      // File multipart; field name 'file' (sesuai API)
      final file = await http.MultipartFile.fromPath('file', foto.path);

      final res = await _api.putFormDataPrivate(
        _url(id),
        fields,
        files: [file],
      );

      final data = res['data'];
      if (data is Map<String, dynamic>) {
        user = _mergeDetail(Users.fromJson(data));
      }
      _setResult(msg: res['message'] ?? 'Profil berhasil diperbarui.');
      return true;
    } catch (e) {
      _setResult(err: e.toString());
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// Hapus foto profil tanpa upload baru
  Future<bool> removePhoto(String id) => updateByIdJson(id, removeFoto: true);

  Users? _mergeDetail(Users updated) {
    final current = user;
    if (current == null) return updated;
    return Users(
      idUser: updated.idUser,
      namaPengguna: updated.namaPengguna,
      email: updated.email,
      kontak: updated.kontak,
      agama: updated.agama,
      fotoProfilUser: updated.fotoProfilUser,
      tanggalLahir: updated.tanggalLahir,
      role: updated.role,
      idDepartement: updated.idDepartement,
      idLocation: updated.idLocation,
      createdAt: current.createdAt,
      updatedAt: updated.updatedAt,
      departement: updated.departement ?? current.departement,
      kantor: updated.kantor ?? current.kantor,
    );
  }
}
