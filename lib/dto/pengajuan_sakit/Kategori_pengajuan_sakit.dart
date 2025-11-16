import 'dart:convert';

Kategoripengajuansakit kategoripengajuansakitFromJson(String str) =>
    Kategoripengajuansakit.fromJson(json.decode(str));

String kategoripengajuansakitToJson(Kategoripengajuansakit data) =>
    json.encode(data.toJson());

class Kategoripengajuansakit {
  List<Data> data;
  Pagination pagination;

  Kategoripengajuansakit({required this.data, required this.pagination});

  factory Kategoripengajuansakit.fromJson(Map<String, dynamic> json) =>
      Kategoripengajuansakit(
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Data {
  String idKategoriSakit;
  String namaKategori;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  Data({
    required this.idKategoriSakit,
    required this.namaKategori,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idKategoriSakit: json["id_kategori_sakit"],
    namaKategori: json["nama_kategori"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_sakit": idKategoriSakit,
    "nama_kategori": namaKategori,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class Pagination {
  int page;
  int pageSize;
  int total;
  int totalPages;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    pageSize: json["pageSize"],
    total: json["total"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "pageSize": pageSize,
    "total": total,
    "totalPages": totalPages,
  };
}
