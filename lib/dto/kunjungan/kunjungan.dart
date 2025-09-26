import 'dart:convert';

KunjunganKlien kunjunganKlienFromJson(String str) =>
    KunjunganKlien.fromJson(json.decode(str));

String kunjunganKlienToJson(KunjunganKlien data) => json.encode(data.toJson());

class KunjunganKlien {
  List<Data> data;
  Pagination pagination;

  KunjunganKlien({required this.data, required this.pagination});

  factory KunjunganKlien.fromJson(Map<String, dynamic> json) => KunjunganKlien(
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Data {
  String idKunjungan;
  String idUser;
  String idMasterDataKunjungan;
  DateTime tanggal;
  DateTime jamMulai;
  dynamic jamSelesai;
  String deskripsi;
  String startLatitude;
  String startLongitude;
  dynamic endLatitude;
  dynamic endLongitude;
  dynamic lampiranKunjunganUrl;
  dynamic duration;
  String handOver;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  Kategori kategori;
  List<dynamic> reports;

  Data({
    required this.idKunjungan,
    required this.idUser,
    required this.idMasterDataKunjungan,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.deskripsi,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.lampiranKunjunganUrl,
    required this.duration,
    required this.handOver,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.kategori,
    required this.reports,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idKunjungan: json["id_kunjungan"],
    idUser: json["id_user"],
    idMasterDataKunjungan: json["id_master_data_kunjungan"],
    tanggal: DateTime.parse(json["tanggal"]),
    jamMulai: DateTime.parse(json["jam_mulai"]),
    jamSelesai: json["jam_selesai"],
    deskripsi: json["deskripsi"],
    startLatitude: json["start_latitude"],
    startLongitude: json["start_longitude"],
    endLatitude: json["end_latitude"],
    endLongitude: json["end_longitude"],
    lampiranKunjunganUrl: json["lampiran_kunjungan_url"],
    duration: json["duration"],
    handOver: json["hand_over"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    kategori: Kategori.fromJson(json["kategori"]),
    reports: List<dynamic>.from(json["reports"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id_kunjungan": idKunjungan,
    "id_user": idUser,
    "id_master_data_kunjungan": idMasterDataKunjungan,
    "tanggal": tanggal.toIso8601String(),
    "jam_mulai": jamMulai.toIso8601String(),
    "jam_selesai": jamSelesai,
    "deskripsi": deskripsi,
    "start_latitude": startLatitude,
    "start_longitude": startLongitude,
    "end_latitude": endLatitude,
    "end_longitude": endLongitude,
    "lampiran_kunjungan_url": lampiranKunjunganUrl,
    "duration": duration,
    "hand_over": handOver,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "kategori": kategori.toJson(),
    "reports": List<dynamic>.from(reports.map((x) => x)),
  };
}

class Kategori {
  String idMasterDataKunjungan;
  String kategoriKunjungan;

  Kategori({
    required this.idMasterDataKunjungan,
    required this.kategoriKunjungan,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    idMasterDataKunjungan: json["id_master_data_kunjungan"],
    kategoriKunjungan: json["kategori_kunjungan"],
  );

  Map<String, dynamic> toJson() => {
    "id_master_data_kunjungan": idMasterDataKunjungan,
    "kategori_kunjungan": kategoriKunjungan,
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
