import 'dart:convert';

SopPerusahaan sopPerusahaanFromJson(String str) =>
    SopPerusahaan.fromJson(json.decode(str));

String sopPerusahaanToJson(SopPerusahaan data) => json.encode(data.toJson());

class SopPerusahaan {
  int page;
  int pageSize;
  int total;
  int totalPages;
  List<Item> items;

  SopPerusahaan({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  factory SopPerusahaan.fromJson(Map<String, dynamic> json) => SopPerusahaan(
    page: json["page"],
    pageSize: json["pageSize"],
    total: json["total"],
    totalPages: json["totalPages"],
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "pageSize": pageSize,
    "total": total,
    "totalPages": totalPages,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  String idSopKaryawan;
  String namaDokumen;
  String lampiranSopUrl;
  String deskripsi;
  String idKategoriSop;
  String createdBySnapshotNamaPengguna;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  KategoriSop kategoriSop;

  Item({
    required this.idSopKaryawan,
    required this.namaDokumen,
    required this.lampiranSopUrl,
    required this.deskripsi,
    required this.idKategoriSop,
    required this.createdBySnapshotNamaPengguna,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.kategoriSop,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    idSopKaryawan: json["id_sop_karyawan"],
    namaDokumen: json["nama_dokumen"],
    lampiranSopUrl: json["lampiran_sop_url"],
    deskripsi: json["deskripsi"],
    idKategoriSop: json["id_kategori_sop"],
    createdBySnapshotNamaPengguna: json["created_by_snapshot_nama_pengguna"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    kategoriSop: KategoriSop.fromJson(json["kategori_sop"]),
  );

  Map<String, dynamic> toJson() => {
    "id_sop_karyawan": idSopKaryawan,
    "nama_dokumen": namaDokumen,
    "lampiran_sop_url": lampiranSopUrl,
    "deskripsi": deskripsi,
    "id_kategori_sop": idKategoriSop,
    "created_by_snapshot_nama_pengguna": createdBySnapshotNamaPengguna,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "kategori_sop": kategoriSop.toJson(),
  };
}

class KategoriSop {
  String idKategoriSop;
  String namaKategori;

  KategoriSop({required this.idKategoriSop, required this.namaKategori});

  factory KategoriSop.fromJson(Map<String, dynamic> json) => KategoriSop(
    idKategoriSop: json["id_kategori_sop"],
    namaKategori: json["nama_kategori"],
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_sop": idKategoriSop,
    "nama_kategori": namaKategori,
  };
}
