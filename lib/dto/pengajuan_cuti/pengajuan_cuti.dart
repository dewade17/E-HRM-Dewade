import 'package:meta/meta.dart';
import 'dart:convert';

Kategoricuti kategoricutiFromJson(String str) =>
    Kategoricuti.fromJson(json.decode(str));

String kategoricutiToJson(Kategoricuti data) => json.encode(data.toJson());

class Kategoricuti {
  bool ok;
  List<Data> data;
  Meta meta;

  Kategoricuti({required this.ok, required this.data, required this.meta});

  factory Kategoricuti.fromJson(Map<String, dynamic> json) => Kategoricuti(
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
  String idPengajuanCuti;
  String idUser;
  String idKategoriCuti;
  String keperluan;
  DateTime tanggalMulai;
  DateTime tanggalMasukKerja;
  String handover;
  String status;
  dynamic currentLevel;
  String jenisPengajuan;
  String lampiranCutiUrl;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  User user;
  KategoriCuti kategoriCuti;
  List<HandoverUser> handoverUsers;
  List<dynamic> approvals;

  Data({
    required this.idPengajuanCuti,
    required this.idUser,
    required this.idKategoriCuti,
    required this.keperluan,
    required this.tanggalMulai,
    required this.tanggalMasukKerja,
    required this.handover,
    required this.status,
    required this.currentLevel,
    required this.jenisPengajuan,
    required this.lampiranCutiUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.user,
    required this.kategoriCuti,
    required this.handoverUsers,
    required this.approvals,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idPengajuanCuti: json["id_pengajuan_cuti"],
    idUser: json["id_user"],
    idKategoriCuti: json["id_kategori_cuti"],
    keperluan: json["keperluan"],
    tanggalMulai: DateTime.parse(json["tanggal_mulai"]),
    tanggalMasukKerja: DateTime.parse(json["tanggal_masuk_kerja"]),
    handover: json["handover"],
    status: json["status"],
    currentLevel: json["current_level"],
    jenisPengajuan: json["jenis_pengajuan"],
    lampiranCutiUrl: json["lampiran_cuti_url"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    user: User.fromJson(json["user"]),
    kategoriCuti: KategoriCuti.fromJson(json["kategori_cuti"]),
    handoverUsers: List<HandoverUser>.from(
      json["handover_users"].map((x) => HandoverUser.fromJson(x)),
    ),
    approvals: List<dynamic>.from(json["approvals"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id_pengajuan_cuti": idPengajuanCuti,
    "id_user": idUser,
    "id_kategori_cuti": idKategoriCuti,
    "keperluan": keperluan,
    "tanggal_mulai": tanggalMulai.toIso8601String(),
    "tanggal_masuk_kerja": tanggalMasukKerja.toIso8601String(),
    "handover": handover,
    "status": status,
    "current_level": currentLevel,
    "jenis_pengajuan": jenisPengajuan,
    "lampiran_cuti_url": lampiranCutiUrl,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "user": user.toJson(),
    "kategori_cuti": kategoriCuti.toJson(),
    "handover_users": List<dynamic>.from(handoverUsers.map((x) => x.toJson())),
    "approvals": List<dynamic>.from(approvals.map((x) => x)),
  };
}

class HandoverUser {
  String idHandoverCuti;
  String idPengajuanCuti;
  String idUserTagged;
  DateTime createdAt;
  User user;

  HandoverUser({
    required this.idHandoverCuti,
    required this.idPengajuanCuti,
    required this.idUserTagged,
    required this.createdAt,
    required this.user,
  });

  factory HandoverUser.fromJson(Map<String, dynamic> json) => HandoverUser(
    idHandoverCuti: json["id_handover_cuti"],
    idPengajuanCuti: json["id_pengajuan_cuti"],
    idUserTagged: json["id_user_tagged"],
    createdAt: DateTime.parse(json["created_at"]),
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id_handover_cuti": idHandoverCuti,
    "id_pengajuan_cuti": idPengajuanCuti,
    "id_user_tagged": idUserTagged,
    "created_at": createdAt.toIso8601String(),
    "user": user.toJson(),
  };
}

class User {
  String idUser;
  String namaPengguna;
  String email;
  String role;
  String fotoProfilUser;

  User({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    required this.fotoProfilUser,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUser: json["id_user"],
    namaPengguna: json["nama_pengguna"],
    email: json["email"],
    role: json["role"],
    fotoProfilUser: json["foto_profil_user"],
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
    "role": role,
    "foto_profil_user": fotoProfilUser,
  };
}

class KategoriCuti {
  String idKategoriCuti;
  String namaKategori;

  KategoriCuti({required this.idKategoriCuti, required this.namaKategori});

  factory KategoriCuti.fromJson(Map<String, dynamic> json) => KategoriCuti(
    idKategoriCuti: json["id_kategori_cuti"],
    namaKategori: json["nama_kategori"],
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_cuti": idKategoriCuti,
    "nama_kategori": namaKategori,
  };
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
