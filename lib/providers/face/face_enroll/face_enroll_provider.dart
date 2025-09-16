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
      // 1) kumpulkan device info (otomatis)
      final device = await _collectDeviceInfo();
      final reqDto = EnrollRequest(
        userId: userId,
        images: [image],
        device: device,
      );

      // 2) siapkan form fields & file
      final fields = reqDto.toFormFields();

      final file = await http.MultipartFile.fromPath(
        'images',
        image.path,
        contentType: _inferImageMediaType(image),
      );

      // 3) panggil ApiService (biar header/token ditangani di sana)
      final endpoint = _trimLeadingSlash(Endpoints.faceEnroll);
      final resp = await _api.postFormDataPrivate(
        endpoint,
        fields,
        files: [file],
      );

      // 4) parse response -> dukung envelope { message, data }
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
