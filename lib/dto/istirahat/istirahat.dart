// lib/dto/istirahat/istirahat.dart

import 'dart:convert';

Istirahat istirahatFromJson(String str) => Istirahat.fromJson(json.decode(str));

String istirahatToJson(Istirahat data) => json.encode(data.toJson());

class Istirahat {
  ActiveBreak? activeBreak;
  List<ActiveBreak>? history;
  bool? ok;
  String? status;
  int? totalDurationSeconds;

  Istirahat({
    this.activeBreak,
    this.history,
    this.ok,
    this.status,
    this.totalDurationSeconds,
  });

  factory Istirahat.fromJson(Map<String, dynamic> json) {
    // FIX: Tambahkan pengecekan null untuk 'active_break'
    final activeBreakData = json["active_break"];
    final historyData = json["history"];

    return Istirahat(
      activeBreak: activeBreakData is Map<String, dynamic>
          ? ActiveBreak.fromJson(activeBreakData)
          : null,
      history: historyData is List
          ? List<ActiveBreak>.from(
              historyData.map((x) => ActiveBreak.fromJson(x)),
            )
          : [], // Fallback ke list kosong jika null
      ok: json["ok"],
      status: json["status"],
      totalDurationSeconds: json["total_duration_seconds"],
    );
  }

  Map<String, dynamic> toJson() => {
    "active_break": activeBreak?.toJson(),
    "history": history == null
        ? null
        : List<dynamic>.from(history!.map((x) => x.toJson())),
    "ok": ok,
    "status": status,
    "total_duration_seconds": totalDurationSeconds,
  };
}

class ActiveBreak {
  dynamic durationSeconds;
  dynamic endIstirahat;
  dynamic endIstirahatLatitude;
  dynamic endIstirahatLongitude;
  String? idIstirahat;
  DateTime? startIstirahat;
  double? startIstirahatLatitude;
  double? startIstirahatLongitude;
  DateTime? tanggalIstirahat;

  ActiveBreak({
    this.durationSeconds,
    this.endIstirahat,
    this.endIstirahatLatitude,
    this.endIstirahatLongitude,
    this.idIstirahat,
    this.startIstirahat,
    this.startIstirahatLatitude,
    this.startIstirahatLongitude,
    this.tanggalIstirahat,
  });

  factory ActiveBreak.fromJson(Map<String, dynamic> json) {
    // FIX: Buat parsing lebih aman dari nilai null atau tipe data yang salah
    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    DateTime? parseDateTime(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return ActiveBreak(
      durationSeconds: json["duration_seconds"],
      endIstirahat: json["end_istirahat"],
      endIstirahatLatitude: json["end_istirahat_latitude"],
      endIstirahatLongitude: json["end_istirahat_longitude"],
      idIstirahat: json["id_istirahat"],
      startIstirahat: parseDateTime(json["start_istirahat"]),
      startIstirahatLatitude: parseDouble(json["start_istirahat_latitude"]),
      startIstirahatLongitude: parseDouble(json["start_istirahat_longitude"]),
      tanggalIstirahat: parseDateTime(json["tanggal_istirahat"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "duration_seconds": durationSeconds,
    "end_istirahat": endIstirahat,
    "end_istirahat_latitude": endIstirahatLatitude,
    "end_istirahat_longitude": endIstirahatLongitude,
    "id_istirahat": idIstirahat,
    "start_istirahat": startIstirahat?.toIso8601String(),
    "start_istirahat_latitude": startIstirahatLatitude,
    "start_istirahat_longitude": startIstirahatLongitude,
    "tanggal_istirahat": tanggalIstirahat == null
        ? null
        : "${tanggalIstirahat!.year.toString().padLeft(4, '0')}-${tanggalIstirahat!.month.toString().padLeft(2, '0')}-${tanggalIstirahat!.day.toString().padLeft(2, '0')}",
  };
}
