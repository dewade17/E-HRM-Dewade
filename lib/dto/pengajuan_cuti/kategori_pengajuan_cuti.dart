import 'dart:convert';

PengajuanCuti pengajuanCutiFromJson(String str) =>
    PengajuanCuti.fromJson(json.decode(str));

String pengajuanCutiToJson(PengajuanCuti data) => json.encode(data.toJson());

class PengajuanCuti {
  List<Data> data;
  Pagination pagination;

  PengajuanCuti({required this.data, required this.pagination});

  factory PengajuanCuti.fromJson(Map<String, dynamic> json) => PengajuanCuti(
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Data {
  String idKategoriCuti;
  String namaKategori;
  bool penguranganKouta;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  Data({
    required this.idKategoriCuti,
    required this.namaKategori,
    required this.penguranganKouta,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idKategoriCuti: json["id_kategori_cuti"],
    namaKategori: json["nama_kategori"],
    penguranganKouta: json["pengurangan_kouta"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_cuti": idKategoriCuti,
    "nama_kategori": namaKategori,
    "pengurangan_kouta": penguranganKouta,
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
