import 'dart:convert';

AbsensiStatus absensiStatusFromJson(String str) =>
    AbsensiStatus.fromJson(json.decode(str));

String absensiStatusToJson(AbsensiStatus data) => json.encode(data.toJson());

class AbsensiStatus {
  final DateTime? jamMasuk;
  final DateTime? jamPulang;
  final String mode;
  final bool ok;
  final DateTime today;

  AbsensiStatus({
    required this.jamMasuk,
    required this.jamPulang,
    required this.mode,
    required this.ok,
    required this.today,
  });

  factory AbsensiStatus.fromJson(Map<String, dynamic> json) {
    final jamMasukRaw = json["jam_masuk"];
    final jamPulangRaw = json["jam_pulang"];

    return AbsensiStatus(
      jamMasuk: jamMasukRaw is String && jamMasukRaw.isNotEmpty
          ? DateTime.parse(jamMasukRaw)
          : null,
      jamPulang: jamPulangRaw is String && jamPulangRaw.isNotEmpty
          ? DateTime.parse(jamPulangRaw)
          : null,
      mode: json["mode"],
      ok: json["ok"],
      today: DateTime.parse(json["today"]),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "mode": mode,
      "ok": ok,
      "today":
          "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}",
    };
    if (jamMasuk != null) {
      data["jam_masuk"] = jamMasuk!.toIso8601String();
    }
    if (jamPulang != null) {
      data["jam_pulang"] = jamPulang!.toIso8601String();
    }
    return data;
  }
}
