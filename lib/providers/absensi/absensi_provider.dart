// lib/providers/absensi/absensi_provider.dart

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
  Absensicheckin? checkinResult;
  Absensicheckout? checkoutResult;
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

  Future<Absensicheckin?> checkin({
    required String userId,
    String? locationId,
    required double lat,
    required double lng,
    required File imageFile,
    List<String> agendaKerjaIds = const [],
    List<String> recipients = const [],
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
      parser: (json) => Absensicheckin.fromJson(json),
    );
    if (value != null) {
      checkinResult = value;
      notifyListeners();
    }
    return value;
  }

  Future<Absensicheckout?> checkout({
    required String userId,
    String? locationId,
    required double lat,
    required double lng,
    required File imageFile,
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
      parser: (json) => Absensicheckout.fromJson(json),
    );
    if (value != null) {
      checkoutResult = value;
      notifyListeners();
    }
    return value;
  }

  Future<T?> _submit<T>({
    required String path,
    required String userId,
    String? locationId,
    required double lat,
    required double lng,
    required File imageFile,
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

      // Logika URI tidak berubah
      final uri = () {
        final trimmed = path.trim();
        final parsed = Uri.tryParse(trimmed);
        if (parsed != null && parsed.hasScheme) return parsed;
        final baseUri = Uri.parse(
          Endpoints.faceBaseURL,
        ); // Menggunakan faceBaseURL
        final origin = '${baseUri.scheme}://${baseUri.authority}';
        if (trimmed.startsWith('/')) return Uri.parse('$origin$trimmed');
        final basePath = baseUri.path.isEmpty
            ? '/'
            : (baseUri.path.endsWith('/') ? baseUri.path : '${baseUri.path}/');
        return Uri.parse('$origin$basePath$trimmed');
      }();
      final req = http.MultipartRequest('POST', uri);

      req.headers['Authorization'] = 'Bearer $token';

      // Fields (tidak ada perubahan)
      req.fields['user_id'] = userId;
      if ((locationId ?? '').isNotEmpty) {
        req.fields['location_id'] = locationId!;
      }
      req.fields['lat'] = lat.toString();
      req.fields['lng'] = lng.toString();

      for (final id in agendaKerjaIds) {
        if (id.trim().isNotEmpty) {
          req.files.add(
            http.MultipartFile.fromString('agenda_kerja_id', id.trim()),
          );
        }
      }
      for (final rid in recipients) {
        if (rid.trim().isNotEmpty) {
          req.files.add(http.MultipartFile.fromString('recipient', rid.trim()));
        }
      }
      for (final entry in catatan) {
        if (entry.description.trim().isNotEmpty) {
          req.files.add(
            http.MultipartFile.fromString(
              'deskripsi_catatan',
              entry.description.trim(),
            ),
          );
          if (entry.attachmentUrl?.trim().isNotEmpty ?? false) {
            req.files.add(
              http.MultipartFile.fromString(
                'lampiran_url',
                entry.attachmentUrl!.trim(),
              ),
            );
          }
        }
      }

      final img = await http.MultipartFile.fromPath('image', imageFile.path);
      req.files.add(img);

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      // --- PERBAIKAN UTAMA DI SINI ---
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final Map<String, dynamic> jsonMap =
            jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        final parsed = parser(
          jsonMap['ok'] == true && jsonMap.containsKey('data')
              ? jsonMap['data']
              : jsonMap,
        );
        return parsed;
      } else if (resp.statusCode == 401) {
        // Blok ini sekarang HANYA akan berjalan jika token benar-benar invalid.
        await prefs.remove('token');
        throw Exception('Unauthorized. Silakan login ulang.');
      } else {
        // Untuk semua kode error lain (400, 409, 500, dll.)
        String errorMessage = 'Terjadi galat (${resp.statusCode})';
        try {
          // Coba parse body untuk mendapatkan pesan error dari backend
          final jsonMap = jsonDecode(utf8.decode(resp.bodyBytes));
          // Backend menggunakan kunci 'error' dalam helper `error()`
          if (jsonMap['error'] is String &&
              (jsonMap['error'] as String).isNotEmpty) {
            errorMessage = jsonMap['error'];
          } else if (jsonMap['message'] is String &&
              (jsonMap['message'] as String).isNotEmpty) {
            errorMessage = jsonMap['message'];
          }
        } catch (_) {
          // Jika body bukan JSON atau tidak ada pesan, gunakan body mentah.
          final bodyString = utf8.decode(resp.bodyBytes);
          if (bodyString.isNotEmpty) {
            errorMessage = bodyString;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      _setErr(e.toString().replaceFirst("Exception: ", ""));
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
        Uri.parse(
          Endpoints.absensiStatus,
        ).replace(queryParameters: {'user_id': userId}).toString(),
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
