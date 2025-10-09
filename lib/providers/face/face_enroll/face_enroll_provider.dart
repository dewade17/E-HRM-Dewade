// ignore_for_file: unnecessary_this, unnecessary_cast
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:e_hrm/dto/face/enroll_face/enroll_face.dart';
import 'package:e_hrm/dto/face/device/device.dart';

// --- TAMBAHKAN IMPORT INI ---
// Import ini diperlukan untuk mengakses handler notifikasi
import 'package:e_hrm/services/notification_handlers.dart';

class FaceEnrollProvider extends ChangeNotifier {
  final ApiService _api;
  FaceEnrollProvider(this._api);

  // state
  bool saving = false;
  String? error;
  String? message;

  // hasil terakhir
  EnrollResponse? result;

  void _setSaving(bool v) {
    saving = v;
    notifyListeners();
  }

  void _setResult({String? msg, String? err, EnrollResponse? data}) {
    message = msg;
    error = err;
    result = data;
    notifyListeners();
  }

  /// Enroll wajah dengan 1 foto (field 'images')
  Future<bool> enrollFace({required String userId, required File image}) async {
    _setSaving(true);
    try {
      // --- PERBAIKAN DIMULAI DI SINI ---

      // Langkah 1: Ambil FCM Token terlebih dahulu dan TUNGGU (await).
      // Ini adalah perbaikan paling penting untuk mengatasi race condition.
      print("Memulai pendaftaran: Mengambil FCM Token...");
      final fcmToken = await NotificationHandler().getFcmToken();

      // Langkah 2: Lakukan validasi. Jika token tidak ada, hentikan proses.
      if (fcmToken == null || fcmToken.isEmpty) {
        throw Exception(
          'Gagal mendapatkan token notifikasi. Pastikan koneksi internet stabil dan coba lagi.',
        );
      }
      print("FCM Token berhasil didapat.");

      // Langkah 3: Kumpulkan informasi perangkat seperti biasa.
      print("Mengumpulkan informasi perangkat...");
      final device = await _collectDeviceInfo();

      // Langkah 4: Buat request DTO seperti biasa.
      final reqDto = EnrollRequest(
        userId: userId,
        images: [image],
        device: device,
      );

      // Langkah 5: Siapkan form fields dari DTO, lalu tambahkan fcm_token secara manual.
      final fields = reqDto.toFormFields();
      fields['fcm_token'] =
          fcmToken; // <-- Token yang sudah didapat ditambahkan di sini

      print("Payload yang akan dikirim ke server: $fields");

      // --- AKHIR PERBAIKAN ---

      // Siapkan file untuk diunggah
      final file = await http.MultipartFile.fromPath(
        // 'images' adalah nama field di backend, sesuai spesifikasi Anda
        'images',
        image.path,
        contentType: _inferImageMediaType(image),
      );

      // Panggil ApiService untuk mengirim data
      final endpoint = _trimLeadingSlash(Endpoints.faceEnroll);
      final resp = await _api.postFormDataPrivate(
        endpoint,
        fields,
        files: [file],
      );

      // Parse response dari server
      final data = (resp['data'] is Map<String, dynamic>)
          ? (resp['data'] as Map<String, dynamic>)
          : (resp as Map<String, dynamic>);

      final enrollRes = EnrollResponse.fromJson(data);
      final msg = (resp['message'] ?? data['message'])?.toString();

      _setResult(msg: msg, err: null, data: enrollRes);
      return true;
    } catch (e) {
      _setResult(msg: null, err: e.toString(), data: null);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// Ambil device info otomatis (tanpa input user)
  /// Fungsi ini tidak perlu diubah.
  Future<DeviceInfo> _collectDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final pkg = await PackageInfo.fromPlatform();

    String? platform;
    String? osVersion;
    String? deviceLabel;
    String? deviceIdentifier;

    if (Platform.isAndroid) {
      final a = await deviceInfo.androidInfo;
      platform = 'android';
      osVersion = 'Android ${a.version.release} (SDK ${a.version.sdkInt})';
      deviceLabel = '${a.manufacturer} ${a.model}'.trim();
      deviceIdentifier = a.id; // androidId
    } else if (Platform.isIOS) {
      final i = await deviceInfo.iosInfo;
      platform = 'ios';
      osVersion = '${i.systemName} ${i.systemVersion}';
      deviceLabel = i.utsname.machine; // ex: iPhone15,3
      deviceIdentifier = i.identifierForVendor;
    } else if (Platform.isMacOS) {
      final m = await deviceInfo.macOsInfo;
      platform = 'macos';
      osVersion = m.osRelease;
      deviceLabel = m.model;
    } else if (Platform.isWindows) {
      final w = await deviceInfo.windowsInfo;
      platform = 'windows';
      osVersion = '${w.productName} ${w.displayVersion}'.trim();
      deviceLabel = w.computerName;
    } else if (Platform.isLinux) {
      final l = await deviceInfo.linuxInfo;
      platform = 'linux';
      osVersion = l.version ?? l.prettyName;
      deviceLabel = l.name;
    } else {
      platform = Platform.operatingSystem;
      osVersion = Platform.operatingSystemVersion;
      deviceLabel = 'Unknown Device';
    }

    final appVersion = '${pkg.version}+${pkg.buildNumber}';

    return DeviceInfo(
      deviceLabel: deviceLabel,
      platform: platform,
      osVersion: osVersion,
      appVersion: appVersion,
      deviceIdentifier: deviceIdentifier,
    );
  }
}

/// ===== util =====

MediaType _inferImageMediaType(File file) {
  final name = file.path.toLowerCase();
  if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
    return MediaType('image', 'jpeg');
  } else if (name.endsWith('.png')) {
    return MediaType('image', 'png');
  } else if (name.endsWith('.webp')) {
    return MediaType('image', 'webp');
  }
  return MediaType('application', 'octet-stream');
}

String _trimLeadingSlash(String s) {
  if (s.startsWith('/')) return s.substring(1);
  return s;
}
