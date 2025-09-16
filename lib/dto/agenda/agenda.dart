import 'dart:convert';

Agenda agendaFromJson(String str) => Agenda.fromJson(json.decode(str));

String agendaToJson(Agenda data) => json.encode(data.toJson());

class Agenda {
  bool ok;
  List<Data> data;
  Meta meta;

  Agenda({required this.ok, required this.data, required this.meta});

  factory Agenda.fromJson(Map<String, dynamic> json) => Agenda(
    ok: json["ok"],
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta.toJson(),
  };
}

class Data {
  String idAgenda;
  String namaAgenda;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  Count count;

  Data({
    required this.idAgenda,
    required this.namaAgenda,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.count,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idAgenda: json["id_agenda"],
    namaAgenda: json["nama_agenda"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    count: Count.fromJson(json["_count"]),
  );

  Map<String, dynamic> toJson() => {
    "id_agenda": idAgenda,
    "nama_agenda": namaAgenda,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "_count": count.toJson(),
  };
}

class Count {
  int items;

  Count({required this.items});

  factory Count.fromJson(Map<String, dynamic> json) =>
      Count(items: json["items"]);

  Map<String, dynamic> toJson() => {"items": items};
}

class Meta {
  int page;
  int perPage;
  int total;
  int totalPages;

  Meta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    page: json["page"],
    perPage: json["perPage"],
    total: json["total"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "perPage": perPage,
    "total": total,
    "totalPages": totalPages,
  };
}
