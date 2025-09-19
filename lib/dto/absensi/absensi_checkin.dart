import 'dart:convert';

AbsensiChekin absensiChekinFromJson(String str) =>
    AbsensiChekin.fromJson(json.decode(str));

String absensiChekinToJson(AbsensiChekin data) => json.encode(data.toJson());

class AbsensiChekin {
  final int? agendasLinked;
  final int? agendasSkipped;
  final List<Catatan> catatan;
  final double? distanceMeters;
  final bool match;
  final String metric;
  final String mode;
  final bool ok;
  final int recipientsAdded;
  final double score;
  final double threshold;
  final String userId;

  AbsensiChekin({
    this.agendasLinked,
    this.agendasSkipped,
    required this.catatan,
    required this.distanceMeters,
    required this.match,
    required this.metric,
    required this.mode,
    required this.ok,
    required this.recipientsAdded,
    required this.score,
    required this.threshold,
    required this.userId,
  });

  factory AbsensiChekin.fromJson(Map<String, dynamic> json) {
    final catatanList = json["catatan"] as List<dynamic>?;
    final distanceRaw = json["distanceMeters"];

    return AbsensiChekin(
      agendasLinked: json["agendasLinked"],
      agendasSkipped: json["agendasSkipped"],
      catatan: catatanList == null
          ? const <Catatan>[]
          : catatanList
                .map((x) => Catatan.fromJson(Map<String, dynamic>.from(x)))
                .toList(),
      distanceMeters: distanceRaw is num ? distanceRaw.toDouble() : null,
      match: json["match"],
      metric: json["metric"],
      mode: json["mode"],
      ok: json["ok"],
      recipientsAdded: json["recipientsAdded"] ?? 0,
      score: (json["score"] as num).toDouble(),
      threshold: (json["threshold"] as num).toDouble(),
      userId: json["user_id"],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "agendasLinked": agendasLinked,
      "agendasSkipped": agendasSkipped,
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
    if (distanceMeters != null) {
      data["distanceMeters"] = distanceMeters;
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
