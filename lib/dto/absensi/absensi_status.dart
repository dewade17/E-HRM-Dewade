import 'dart:convert';

AbsensiStatus absensiStatusFromJson(String str) =>
    AbsensiStatus.fromJson(json.decode(str));

String absensiStatusToJson(AbsensiStatus data) => json.encode(data.toJson());

class AbsensiStatus {
  DateTime jamMasuk;
  dynamic jamPulang;
  String mode;
  bool ok;
  DateTime today;

  AbsensiStatus({
    required this.jamMasuk,
    required this.jamPulang,
    required this.mode,
    required this.ok,
    required this.today,
  });

  factory AbsensiStatus.fromJson(Map<String, dynamic> json) => AbsensiStatus(
    jamMasuk: DateTime.parse(json["jam_masuk"]),
    jamPulang: json["jam_pulang"],
    mode: json["mode"],
    ok: json["ok"],
    today: DateTime.parse(json["today"]),
  );

  Map<String, dynamic> toJson() => {
    "jam_masuk": jamMasuk.toIso8601String(),
    "jam_pulang": jamPulang,
    "mode": mode,
    "ok": ok,
    "today":
        "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}",
  };
}
