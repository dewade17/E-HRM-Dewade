// lib/providers/absensi/absensi_provider.dart
// Provider untuk checkin/checkout: ambil token dari SharedPreferences,
// kirim multipart (user_id, location_id, lat, lng, image)
// + dukungan multiple 'todo', multiple 'recipient',
//   serta todo_status, todo_date, todo_start, todo_end (opsional).

import 'dart:io';
import 'dart:convert';
import 'package:e_hrm/dto/absensi/absensi_checkout.dart';
import 'package:e_hrm/dto/absensi/absensi_status.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_hrm/dto/absensi/absensi_checkin.dart';
import 'package:e_hrm/contraints/endpoints.dart';

class AbsensiCatatanEntry {
  final String description;
  final String? attachmentUrl;

  const AbsensiCatatanEntry({required this.description, this.attachmentUrl});
}

class AbsensiProvider extends ChangeNotifier {
  bool saving = false;
  String? error;
  AbsensiChekin? checkinResult;
  AbsensiChekout? checkoutResult;
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
    checkinResult = null;
    checkoutResult = null;
    notifyListeners();
  }

  Future<AbsensiChekin?> checkin({
    required String userId,
    String? locationId,
    required double lat,
    required double lng,
    required File imageFile,

    // --- tambahan opsional ---
    List<String> agendaKerjaIds = const [],
    List<String> recipients = const [], // id_user penerima laporan
    List<AbsensiCatatanEntry> catatan = const [],
  }) async {
    final value = await _submit(
      path: Endpoints.absensiCheckin,
      userId: userId,
      locationId: locationId,
      lat: lat,
      lng: lng,
      imageFile: imageFile,
      agendaKerjaIds: agendaKerjaIds,
      recipients: recipients,
      catatan: catatan,
      parser: (json) => AbsensiChekin.fromJson(json),
    );

    if (value != null) {
      checkinResult = value;
      notifyListeners();
    }

    return value;
  }

  Future<AbsensiChekout?> checkout({
    required String userId,
    String? locationId,
    required double lat,
    required double lng,
    required File imageFile,

    // --- tambahan opsional ---
    List<String> agendaKerjaIds = const [],
    List<String> recipients = const [],
    List<AbsensiCatatanEntry> catatan = const [],
  }) async {
    final value = await _submit(
      path: Endpoints.absensiCheckout,
      userId: userId,
      locationId: locationId,
      lat: lat,
      lng: lng,
      imageFile: imageFile,
      agendaKerjaIds: agendaKerjaIds,
      recipients: recipients,
      catatan: catatan,
      parser: (json) => AbsensiChekout.fromJson(json),
    );

    if (value != null) {
      checkoutResult = value;
      notifyListeners();
    }

    return value;
  }

  Future<T?> _submit<T>({
    required String path, // ex: "/api/absensi/checkin"
    required String userId,
    String? locationId,
    required double lat,
    required double lng,
    required File imageFile,

    // --- tambahan opsional ---
    List<String> agendaKerjaIds = const [],
    List<String> recipients = const [],
    List<AbsensiCatatanEntry> catatan = const [],
    required T Function(Map<String, dynamic>) parser,
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

      // --- multiple agenda_kerja_id ---
      for (final id in agendaKerjaIds) {
        final value = id.trim();
        if (value.isEmpty) continue;
        req.files.add(http.MultipartFile.fromString('agenda_kerja_id', value));
      }

      // --- multiple 'recipient' (id_user penerima laporan) ---
      for (final rid in recipients) {
        final v = (rid).trim();
        if (v.isEmpty) continue;
        req.files.add(http.MultipartFile.fromString('recipient', v));
      }

      // --- multiple catatan (deskripsi + lampiran opsional) ---
      for (final entry in catatan) {
        final desc = entry.description.trim();
        if (desc.isEmpty) continue;
        req.files.add(http.MultipartFile.fromString('deskripsi_catatan', desc));

        final url = entry.attachmentUrl?.trim();
        if (url != null && url.isNotEmpty) {
          req.files.add(http.MultipartFile.fromString('lampiran_url', url));
        }
      }

      // --- image ---
      final img = await http.MultipartFile.fromPath('image', imageFile.path);
      req.files.add(img);

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final Map<String, dynamic> jsonMap =
            jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        final parsed = parser(jsonMap);
        return parsed;
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
