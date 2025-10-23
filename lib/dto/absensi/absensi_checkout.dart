// lib/dto/absensi/absensi_checkout.dart

import 'dart:convert';

// Helper function to parse DateTime safely
DateTime? _parseDateTime(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

Absensicheckout absensicheckoutFromJson(String str) =>
    Absensicheckout.fromJson(json.decode(str));

String absensicheckoutToJson(Absensicheckout data) =>
    json.encode(data.toJson());

class Absensicheckout {
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
  final DateTime? jamPulang; // <-- FIELD BARU DITAMBAHKAN

  Absensicheckout({
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
    this.jamPulang, // <-- FIELD BARU DITAMBAHKAN
  });

  factory Absensicheckout.fromJson(Map<String, dynamic> json) =>
      Absensicheckout(
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
        jamPulang: _parseDateTime(json["jam_pulang"]), // <-- PARSING DARI JSON
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
    if (jamPulang != null)
      "jam_pulang": jamPulang!.toIso8601String(), // <-- SERIALISASI
  };
}
