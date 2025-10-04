// lib/dto/absensi/absensi_status.dart
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
  final List<String> linkedAgendaIds; // <-- TAMBAHKAN INI

  AbsensiStatus({
    required this.jamMasuk,
    required this.jamPulang,
    required this.mode,
    required this.ok,
    required this.today,
    required this.linkedAgendaIds, // <-- TAMBAHKAN INI
  });

  factory AbsensiStatus.fromJson(Map<String, dynamic> json) {
    final jamMasukRaw = json["jam_masuk"];
    final jamPulangRaw = json["jam_pulang"];

    // Ambil daftar ID dari JSON
    final List<String> agendaIds =
        (json['linked_agenda_ids'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    return AbsensiStatus(
      jamMasuk: jamMasukRaw is String && jamMasukRaw.isNotEmpty
          ? DateTime.tryParse(jamMasukRaw)
          : null,
      jamPulang: jamPulangRaw is String && jamPulangRaw.isNotEmpty
          ? DateTime.tryParse(jamPulangRaw)
          : null,
      mode: json["mode"] ?? 'checkin',
      ok: json["ok"] ?? false,
      today: DateTime.parse(json["today"]),
      linkedAgendaIds: agendaIds, // <-- SET NILAINYA
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "mode": mode,
      "ok": ok,
      "today":
          "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}",
      "linked_agenda_ids": linkedAgendaIds, // <-- TAMBAHKAN DI SINI
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
