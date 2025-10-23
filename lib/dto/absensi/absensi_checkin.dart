// lib/dto/absensi/absensi_checkin.dart

import 'dart:convert';

// Helper function to parse DateTime safely
DateTime? _parseDateTime(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

Absensicheckin absensicheckinFromJson(String str) =>
    Absensicheckin.fromJson(json.decode(str));

String absensicheckinToJson(Absensicheckin data) => json.encode(data.toJson());

class Absensicheckin {
  bool? accepted;
  int? distanceMeters;
  bool? match;
  String? message;
  String? metric;
  bool? ok;
  double? score;
  String? taskId;
  double? threshold;
  String? userId;
  final DateTime? jamMasuk; // <-- FIELD BARU DITAMBAHKAN

  Absensicheckin({
    this.accepted,
    this.distanceMeters,
    this.match,
    this.message,
    this.metric,
    this.ok,
    this.score,
    this.taskId,
    this.threshold,
    this.userId,
    this.jamMasuk, // <-- FIELD BARU DITAMBAHKAN
  });

  factory Absensicheckin.fromJson(Map<String, dynamic> json) => Absensicheckin(
    accepted: json["accepted"],
    distanceMeters: json["distanceMeters"],
    match: json["match"],
    message: json["message"],
    metric: json["metric"],
    ok: json["ok"],
    score: json["score"]?.toDouble(),
    taskId: json["task_id"],
    threshold: json["threshold"]?.toDouble(),
    userId: json["user_id"],
    jamMasuk: _parseDateTime(json["jam_masuk"]), // <-- PARSING DARI JSON
  );

  Map<String, dynamic> toJson() => {
    "accepted": accepted,
    "distanceMeters": distanceMeters,
    "match": match,
    "message": message,
    "metric": metric,
    "ok": ok,
    "score": score,
    "task_id": taskId,
    "threshold": threshold,
    "user_id": userId,
    if (jamMasuk != null)
      "jam_masuk": jamMasuk!.toIso8601String(), // <-- SERIALISASI
  };
}
