
import 'dart:io';
import 'package:e_hrm/dto/face/device/device.dart';

class EnrollRequest {
  String userId;
  List<File> images;
  DeviceInfo? device;

  EnrollRequest({required this.userId, required this.images, this.device});

  /// Hanya field non-file (untuk JSON/debug); upload tetap pakai multipart.
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    if (device != null) ...device!.toJson(),
  };

  /// Form fields (tanpa file) untuk multipart
  Map<String, String> toFormFields() => {
    'user_id': userId,
    if (device != null) ...device!.toFormFields(),
  };
}

class EnrollResponse {
  String? deviceId;
  String? embeddingPath;
  String? embeddingSignedUrl;
  String? message; // kalau backend mengirim pesan
  bool? success; // kalau backend mengirim status

  EnrollResponse({
    this.deviceId,
    this.embeddingPath,
    this.embeddingSignedUrl,
    this.message,
    this.success,
  });

  factory EnrollResponse.fromJson(Map<String, dynamic> json) => EnrollResponse(
    deviceId: json['device_id'],
    embeddingPath: json['embedding_path'],
    embeddingSignedUrl: json['embedding_signed_url'],
    message: json['message'],
    success: json['success'] is bool ? json['success'] : null,
  );

  Map<String, dynamic> toJson() => {
    if (deviceId != null) 'device_id': deviceId,
    if (embeddingPath != null) 'embedding_path': embeddingPath,
    if (embeddingSignedUrl != null) 'embedding_signed_url': embeddingSignedUrl,
    if (message != null) 'message': message,
    if (success != null) 'success': success,
  };
}
