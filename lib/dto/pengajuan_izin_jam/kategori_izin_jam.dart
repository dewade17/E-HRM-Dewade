// lib/dto/pengajuan_izin_jam/kategori_izin_jam.dart

import 'dart:convert';

KategoriIzinJam kategoriIzinJamFromJson(String str) =>
    KategoriIzinJam.fromJson(json.decode(str));

String kategoriIzinJamToJson(KategoriIzinJam data) =>
    json.encode(data.toJson());

class KategoriIzinJam {
  List<Data> data;
  Pagination pagination;

  KategoriIzinJam({required this.data, required this.pagination});

  factory KategoriIzinJam.fromJson(Map<String, dynamic> json) =>
      KategoriIzinJam(
        // Handle jika json["data"] null
        data: json["data"] == null
            ? []
            : List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
        // Handle jika json["pagination"] null
        pagination: Pagination.fromJson(json["pagination"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Data {
  String idKategoriIzinJam;
  String namaKategori;
  DateTime? createdAt; // Ubah jadi nullable
  DateTime? updatedAt; // Ubah jadi nullable
  dynamic deletedAt;

  Data({
    required this.idKategoriIzinJam,
    required this.namaKategori,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    // Gunakan ?? '' untuk fallback ke string kosong jika null
    idKategoriIzinJam: (json["id_kategori_izin_jam"] ?? '').toString(),
    namaKategori: (json["nama_kategori"] ?? '').toString(),
    // Gunakan tryParse agar tidak error jika format salah atau null
    createdAt: DateTime.tryParse(json["created_at"] ?? ''),
    updatedAt: DateTime.tryParse(json["updated_at"] ?? ''),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_izin_jam": idKategoriIzinJam,
    "nama_kategori": namaKategori,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
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
    // Parsing aman untuk angka
    page: (json["page"] as num?)?.toInt() ?? 1,
    pageSize: (json["pageSize"] as num?)?.toInt() ?? 10,
    total: (json["total"] as num?)?.toInt() ?? 0,
    totalPages: (json["totalPages"] as num?)?.toInt() ?? 1,
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "pageSize": pageSize,
    "total": total,
    "totalPages": totalPages,
  };
}
