// lib/providers/absensi/absensi_provider.dart
// Provider untuk checkin/checkout: ambil token dari SharedPreferences,
// kirim multipart (user_id, location_id, lat, lng, image)
// + dukungan multiple 'todo', multiple 'recipient',
//   serta todo_status, todo_date, todo_start, todo_end (opsional).

import 'dart:io';
import 'dart:convert';
import 'package:e_hrm/dto/absensi/absensi_status.dart';
import 'package:e_hrm/dto/agenda_kerja/agenda_kerja.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_hrm/dto/absensi/absensi.dart';
import 'package:e_hrm/contraints/endpoints.dart';

class AbsensiProvider extends ChangeNotifier {
  bool saving = false;
  String? error;
  AbsensiChekin? result;
  final ApiService _api = ApiService();
  AbsensiStatus? todayStatus;
  bool loadingStatus = false;

  void _setSaving(bool v) {
    saving = v;
    notifyListeners();
  }

  void _setErr(String? msg) {
    error = msg;
    notifyListeners();
  }

  void reset() {
    saving = false;
    error = null;
    result = null;
    notifyListeners();
  }

  /// Helper format 'YYYY-MM-DD'
  String _fmtDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<Absensi?> checkin({
    required String userId,
    String? locationId,
    required double lat,
    required double lng,
    required File imageFile,

    // --- tambahan opsional ---
    List<String> todos = const [],
    List<String> recipients = const [], // id_user penerima laporan
    String? todoStatus, // 'diproses' | 'selesai' | 'ditunda'
    DateTime? todoDate, // tanggal todo
    DateTime? todoStart, // jam mulai (akan dikirim ISO)
    DateTime? todoEnd, // jam selesai (akan dikirim ISO)
  }) {
    return _submit(
      path: Endpoints.absensiCheckin,
      userId: userId,
      locationId: locationId,
      lat: lat,
      lng: lng,
      imageFile: imageFile,
      todos: todos,
      recipients: recipients,
      todoStatus: todoStatus,
      todoDate: todoDate,
      todoStart: todoStart,
      todoEnd: todoEnd,
    );
  }

  Future<Absensi?> checkout({
    required String userId,
    String? locationId,
    required double lat,
    required double lng,
    required File imageFile,

    // --- tambahan opsional ---
    List<String> todos = const [],
    List<String> recipients = const [],
    String? todoStatus, // 'diproses' | 'selesai' | 'ditunda'
    DateTime? todoDate,
    DateTime? todoStart,
    DateTime? todoEnd,
  }) {
    return _submit(
      path: Endpoints.absensiCheckout,
      userId: userId,
      locationId: locationId,
      lat: lat,
      lng: lng,
      imageFile: imageFile,
      todos: todos,
      recipients: recipients,
      todoStatus: todoStatus,
      todoDate: todoDate,
      todoStart: todoStart,
      todoEnd: todoEnd,
    );
  }

  Future<Absensi?> _submit({
    required String path, // ex: "/api/absensi/checkin"
    required String userId,
    String? locationId,
    required double lat,
    required double lng,
    required File imageFile,

    // --- tambahan opsional ---
    List<String> todos = const [],
    List<String> recipients = const [],
    String? todoStatus,
    DateTime? todoDate,
    DateTime? todoStart,
    DateTime? todoEnd,
  }) async {
    _setSaving(true);
    _setErr(null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Unauthorized. Silakan login ulang.');
      }

      final uri = Uri.parse('${Endpoints.baseURL}$path');
      final req = http.MultipartRequest('POST', uri);

      // Auth header
      req.headers['Authorization'] = 'Bearer $token';

      // --- field tunggal ---
      req.fields['user_id'] = userId;
      if ((locationId ?? '').isNotEmpty) {
        req.fields['location_id'] = locationId!;
      }
      req.fields['lat'] = lat.toString();
      req.fields['lng'] = lng.toString();

      // --- opsi Todo extras (opsional) ---
      if (todoStatus != null && todoStatus.isNotEmpty) {
        // harap isi salah satu: diproses | selesai | ditunda
        req.fields['todo_status'] = todoStatus;
      }
      if (todoDate != null) {
        req.fields['todo_date'] = _fmtDate(todoDate);
      }
      if (todoStart != null) {
        req.fields['todo_start'] = todoStart.toIso8601String();
      }
      if (todoEnd != null) {
        req.fields['todo_end'] = todoEnd.toIso8601String();
      }

      // --- multiple 'todo' (gunakan MultipartFile.fromString agar bisa duplikat key) ---
      for (final t in todos) {
        final val = (t).trim();
        if (val.isEmpty) continue;
        req.files.add(http.MultipartFile.fromString('todo', val));
      }

      // --- multiple 'recipient' (id_user penerima laporan) ---
      for (final rid in recipients) {
        final v = (rid).trim();
        if (v.isEmpty) continue;
        req.files.add(http.MultipartFile.fromString('recipient', v));
      }

      // --- image ---
      final img = await http.MultipartFile.fromPath('image', imageFile.path);
      req.files.add(img);

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final Map<String, dynamic> jsonMap =
            jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        result = Absensi.fromJson(jsonMap) as AbsensiChekin?;
        notifyListeners();
        // return result;
      } else if (resp.statusCode == 401) {
        await prefs.remove('token');
        throw Exception('Unauthorized. Silakan login ulang.');
      } else {
        try {
          final j = jsonDecode(utf8.decode(resp.bodyBytes));
          throw Exception(j['message'] ?? 'Gagal (${resp.statusCode})');
        } catch (_) {
          throw Exception('Gagal (${resp.statusCode})');
        }
      }
    } catch (e) {
      _setErr(e.toString());
      return null;
    } finally {
      _setSaving(false);
    }
  }

  Future<AbsensiStatus?> fetchTodayStatus(String userId) async {
    loadingStatus = true;
    notifyListeners();
    try {
      final res = await _api.fetchDataPrivate(
        '${Endpoints.absensiStatus}?user_id=$userId',
      );
      final dto = AbsensiStatus.fromJson(Map<String, dynamic>.from(res));
      todayStatus = dto;
      return dto;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      loadingStatus = false;
      notifyListeners();
    }
  }
}
