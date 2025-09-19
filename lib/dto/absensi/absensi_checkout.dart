import 'dart:convert';

AbsensiChekout absensiChekoutFromJson(String str) =>
    AbsensiChekout.fromJson(json.decode(str));

String absensiChekoutToJson(AbsensiChekout data) => json.encode(data.toJson());

class AbsensiChekout {
  List<dynamic> agendas;
  int agendasLinked;
  int agendasSkipped;
  List<Catatan> catatan;
  double distanceMeters;
  DateTime jamPulang;
  bool match;
  String metric;
  String mode;
  bool ok;
  int recipientsAdded;
  double score;
  double threshold;
  String userId;

  AbsensiChekout({
    required this.agendas,
    required this.agendasLinked,
    required this.agendasSkipped,
    required this.catatan,
    required this.distanceMeters,
    required this.jamPulang,
    required this.match,
    required this.metric,
    required this.mode,
    required this.ok,
    required this.recipientsAdded,
    required this.score,
    required this.threshold,
    required this.userId,
  });

  factory AbsensiChekout.fromJson(Map<String, dynamic> json) => AbsensiChekout(
    agendas: List<dynamic>.from(json["agendas"].map((x) => x)),
    agendasLinked: json["agendasLinked"],
    agendasSkipped: json["agendasSkipped"],
    catatan: List<Catatan>.from(
      json["catatan"].map((x) => Catatan.fromJson(x)),
    ),
    distanceMeters: json["distanceMeters"].toDouble(),
    jamPulang: DateTime.parse(json["jam_pulang"]),
    match: json["match"],
    metric: json["metric"],
    mode: json["mode"],
    ok: json["ok"],
    recipientsAdded: json["recipientsAdded"],
    score: json["score"].toDouble(),
    threshold: json["threshold"].toDouble(),
    userId: json["user_id"],
  );

  Map<String, dynamic> toJson() => {
    "agendas": List<dynamic>.from(agendas.map((x) => x)),
    "agendasLinked": agendasLinked,
    "agendasSkipped": agendasSkipped,
    "catatan": List<dynamic>.from(catatan.map((x) => x.toJson())),
    "distanceMeters": distanceMeters,
    "jam_pulang": jamPulang.toIso8601String(),
    "match": match,
    "metric": metric,
    "mode": mode,
    "ok": ok,
    "recipientsAdded": recipientsAdded,
    "score": score,
    "threshold": threshold,
    "user_id": userId,
  };
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
