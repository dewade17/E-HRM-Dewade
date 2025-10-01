import 'dart:convert';

Kunjunganklien kunjunganklienFromJson(String str) =>
    Kunjunganklien.fromJson(json.decode(str));

String kunjunganklienToJson(Kunjunganklien data) => json.encode(data.toJson());

class Kunjunganklien {
  List<Data> data;
  Pagination pagination;

  Kunjunganklien({required this.data, required this.pagination});

  factory Kunjunganklien.fromJson(Map<String, dynamic> json) => Kunjunganklien(
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
  String idKategoriKunjungan;
  DateTime tanggal;
  DateTime jamMulai;
  DateTime jamSelesai;
  String deskripsi;
  dynamic jamCheckin;
  dynamic jamCheckout;
  dynamic startLatitude;
  dynamic startLongitude;
  dynamic endLatitude;
  dynamic endLongitude;
  dynamic lampiranKunjunganUrl;
  String statusKunjungan;
  dynamic duration;
  dynamic handOver;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  Kategori kategori;
  List<dynamic> reports;

  Data({
    required this.idKunjungan,
    required this.idUser,
    required this.idKategoriKunjungan,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.deskripsi,
    this.jamCheckin,
    this.jamCheckout,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.lampiranKunjunganUrl,
    required this.statusKunjungan,
    this.duration,
    this.handOver,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.kategori,
    required this.reports,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idKunjungan: json["id_kunjungan"],
    idUser: json["id_user"],
    idKategoriKunjungan: json["id_kategori_kunjungan"],
    tanggal: DateTime.parse(json["tanggal"]),
    jamMulai: DateTime.parse(json["jam_mulai"]),
    jamSelesai: DateTime.parse(json["jam_selesai"]),
    deskripsi: json["deskripsi"],
    jamCheckin: json["jam_checkin"],
    jamCheckout: json["jam_checkout"],
    startLatitude: json["start_latitude"],
    startLongitude: json["start_longitude"],
    endLatitude: json["end_latitude"],
    endLongitude: json["end_longitude"],
    lampiranKunjunganUrl: json["lampiran_kunjungan_url"],
    statusKunjungan: json["status_kunjungan"],
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
    "id_kategori_kunjungan": idKategoriKunjungan,
    "tanggal": tanggal.toIso8601String(),
    "jam_mulai": jamMulai.toIso8601String(),
    "jam_selesai": jamSelesai.toIso8601String(),
    "deskripsi": deskripsi,
    "jam_checkin": jamCheckin,
    "jam_checkout": jamCheckout,
    "start_latitude": startLatitude,
    "start_longitude": startLongitude,
    "end_latitude": endLatitude,
    "end_longitude": endLongitude,
    "lampiran_kunjungan_url": lampiranKunjunganUrl,
    "status_kunjungan": statusKunjungan,
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
  String idKategoriKunjungan;
  String kategoriKunjungan;

  Kategori({
    required this.idKategoriKunjungan,
    required this.kategoriKunjungan,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    idKategoriKunjungan: json["id_kategori_kunjungan"],
    kategoriKunjungan: json["kategori_kunjungan"],
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_kunjungan": idKategoriKunjungan,
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
