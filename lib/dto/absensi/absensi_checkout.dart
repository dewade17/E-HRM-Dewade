import 'dart:convert';

AbsensiChekout absensiChekoutFromJson(String str) =>
    AbsensiChekout.fromJson(json.decode(str));

String absensiChekoutToJson(AbsensiChekout data) => json.encode(data.toJson());

class AbsensiChekout {
  final List<Map<String, dynamic>> agendas;
  final int? agendasLinked;
  final int? agendasSkipped;
  final List<Catatan> catatan;
  final double? distanceMeters;
  final DateTime? jamPulang;
  final bool match;
  final String metric;
  final String mode;
  final bool ok;
  final int recipientsAdded;
  final double score;
  final double threshold;
  final String userId;

  AbsensiChekout({
    required this.agendas,
    this.agendasLinked,
    this.agendasSkipped,
    required this.catatan,
    this.distanceMeters,
    this.jamPulang,
    required this.match,
    required this.metric,
    required this.mode,
    required this.ok,
    required this.recipientsAdded,
    required this.score,
    required this.threshold,
    required this.userId,
  });

  factory AbsensiChekout.fromJson(Map<String, dynamic> json) {
    final agendasList =
        (json["agendas"] as List?)
            ?.map<Map<String, dynamic>>(
              (dynamic item) => Map<String, dynamic>.from(item as Map),
            )
            .toList() ??
        const <Map<String, dynamic>>[];
    final catatanList =
        (json["catatan"] as List?)
            ?.map<Catatan>(
              (dynamic item) =>
                  Catatan.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList() ??
        const <Catatan>[];
    final distanceRaw = json["distanceMeters"];
    final jamPulangRaw = json["jam_pulang"];

    return AbsensiChekout(
      agendas: agendasList,
      agendasLinked: json["agendasLinked"],
      agendasSkipped: json["agendasSkipped"],
      catatan: catatanList,
      distanceMeters: distanceRaw is num ? distanceRaw.toDouble() : null,
      jamPulang: jamPulangRaw is String && jamPulangRaw.isNotEmpty
          ? DateTime.parse(jamPulangRaw)
          : null,
      match: json["match"] as bool? ?? false,
      metric: json["metric"]?.toString() ?? '',
      mode: json["mode"]?.toString() ?? '',
      ok: json["ok"] as bool? ?? false,
      recipientsAdded: (json["recipientsAdded"] as int?) ?? 0,
      score: (json["score"] as num).toDouble(),
      threshold: (json["threshold"] as num).toDouble(),
      userId: json["user_id"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "agendas": agendas.map((x) => Map<String, dynamic>.from(x)).toList(),
      "catatan": List<dynamic>.from(catatan.map((x) => x.toJson())),
      "match": match,
      "metric": metric,
      "mode": mode,
      "ok": ok,
      "recipientsAdded": recipientsAdded,
      "score": score,
      "threshold": threshold,
      "user_id": userId,
    };

    if (agendasLinked != null) {
      data["agendasLinked"] = agendasLinked;
    }
    if (agendasSkipped != null) {
      data["agendasSkipped"] = agendasSkipped;
    }
    if (distanceMeters != null) {
      data["distanceMeters"] = distanceMeters;
    }
    if (jamPulang != null) {
      data["jam_pulang"] = jamPulang!.toIso8601String();
    }

    return data;
  }
}

class Catatan {
  String? deskripsiCatatan;
  String? idCatatan;
  dynamic lampiranUrl;

  Catatan({this.deskripsiCatatan, this.idCatatan, this.lampiranUrl});

  factory Catatan.fromJson(Map<String, dynamic> json) => Catatan(
    deskripsiCatatan: json["deskripsi_catatan"],
    idCatatan: json["id_catatan"],
    lampiranUrl: json["lampiran_url"],
  );

  Map<String, dynamic> toJson() => {
    "deskripsi_catatan": deskripsiCatatan,
    "id_catatan": idCatatan,
    "lampiran_url": lampiranUrl,
  };
}
