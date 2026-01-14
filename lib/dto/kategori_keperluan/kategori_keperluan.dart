import 'dart:convert';

KategoriKeperluan kategorikeperluanFromJson(String str) =>
    KategoriKeperluan.fromJson(json.decode(str));

String kategorikeperluanToJson(KategoriKeperluan data) =>
    json.encode(data.toJson());

class KategoriKeperluan {
  List<Data> data;
  Pagination pagination;

  KategoriKeperluan({required this.data, required this.pagination});

  factory KategoriKeperluan.fromJson(Map<String, dynamic> json) =>
      KategoriKeperluan(
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Data {
  String idKategoriKeperluan;
  String namaKeperluan;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  Data({
    required this.idKategoriKeperluan,
    required this.namaKeperluan,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idKategoriKeperluan: json["id_kategori_keperluan"],
    namaKeperluan: json["nama_keperluan"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_keperluan": idKategoriKeperluan,
    "nama_keperluan": namaKeperluan,
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
