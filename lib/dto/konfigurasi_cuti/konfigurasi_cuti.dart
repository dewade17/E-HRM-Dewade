import 'dart:convert';

KonfigurasiCuti konfigurasiCutiFromJson(String str) =>
    KonfigurasiCuti.fromJson(json.decode(str));

String konfigurasiCutiToJson(KonfigurasiCuti data) =>
    json.encode(data.toJson());

class KonfigurasiCuti {
  bool ok;
  List<Data> data;
  String statusCuti;
  Meta meta;

  KonfigurasiCuti({
    required this.ok,
    required this.data,
    required this.statusCuti,
    required this.meta,
  });

  factory KonfigurasiCuti.fromJson(Map<String, dynamic> json) =>
      KonfigurasiCuti(
        ok: json["ok"],
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
        statusCuti: json["status_cuti"],
        meta: Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status_cuti": statusCuti,
    "meta": meta.toJson(),
  };
}

class Data {
  String idCutiKonfigurasi;
  String bulan;
  int koutaCuti;
  int cutiTabung;
  DateTime updatedAt;

  Data({
    required this.idCutiKonfigurasi,
    required this.bulan,
    required this.koutaCuti,
    required this.cutiTabung,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idCutiKonfigurasi: json["id_cuti_konfigurasi"],
    bulan: json["bulan"],
    koutaCuti: json["kouta_cuti"],
    cutiTabung: json["cuti_tabung"],
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id_cuti_konfigurasi": idCutiKonfigurasi,
    "bulan": bulan,
    "kouta_cuti": koutaCuti,
    "cuti_tabung": cutiTabung,
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Meta {
  int total;

  Meta({required this.total});

  factory Meta.fromJson(Map<String, dynamic> json) =>
      Meta(total: json["total"]);

  Map<String, dynamic> toJson() => {"total": total};
}
