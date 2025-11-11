// To parse this JSON data, do
//
//     final pengajuanCuti = pengajuanCutiFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

PengajuanCuti pengajuanCutiFromJson(String str) =>
    PengajuanCuti.fromJson(json.decode(str));

String pengajuanCutiToJson(PengajuanCuti data) => json.encode(data.toJson());

class PengajuanCuti {
  bool ok;
  String message;
  List<Data> data;
  Upload upload;

  PengajuanCuti({
    required this.ok,
    required this.message,
    required this.data,
    required this.upload,
  });

  factory PengajuanCuti.fromJson(Map<String, dynamic> json) => PengajuanCuti(
    ok: json["ok"],
    message: json["message"],
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    upload: Upload.fromJson(json["upload"]),
  );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "upload": upload.toJson(),
  };
}

class Data {
  String idPengajuanCuti;
  String idUser;
  String idKategoriCuti;
  String keperluan;
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
  List<Approval> approvals;
  List<TanggalList> tanggalList;

  Data({
    required this.idPengajuanCuti,
    required this.idUser,
    required this.idKategoriCuti,
    required this.keperluan,
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
    required this.tanggalList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idPengajuanCuti: json["id_pengajuan_cuti"],
    idUser: json["id_user"],
    idKategoriCuti: json["id_kategori_cuti"],
    keperluan: json["keperluan"],
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
    approvals: List<Approval>.from(
      json["approvals"].map((x) => Approval.fromJson(x)),
    ),
    tanggalList: List<TanggalList>.from(
      json["tanggal_list"].map((x) => TanggalList.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id_pengajuan_cuti": idPengajuanCuti,
    "id_user": idUser,
    "id_kategori_cuti": idKategoriCuti,
    "keperluan": keperluan,
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
    "approvals": List<dynamic>.from(approvals.map((x) => x.toJson())),
    "tanggal_list": List<dynamic>.from(tanggalList.map((x) => x.toJson())),
  };
}

class Approval {
  String idApprovalPengajuanCuti;
  int level;
  dynamic approverUserId;
  String approverRole;
  String decision;
  dynamic decidedAt;
  dynamic note;

  Approval({
    required this.idApprovalPengajuanCuti,
    required this.level,
    required this.approverUserId,
    required this.approverRole,
    required this.decision,
    required this.decidedAt,
    required this.note,
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
    idApprovalPengajuanCuti: json["id_approval_pengajuan_cuti"],
    level: json["level"],
    approverUserId: json["approver_user_id"],
    approverRole: json["approver_role"],
    decision: json["decision"],
    decidedAt: json["decided_at"],
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "id_approval_pengajuan_cuti": idApprovalPengajuanCuti,
    "level": level,
    "approver_user_id": approverUserId,
    "approver_role": approverRole,
    "decision": decision,
    "decided_at": decidedAt,
    "note": note,
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
  dynamic fotoProfilUser;

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

class TanggalList {
  DateTime tanggalCuti;

  TanggalList({required this.tanggalCuti});

  factory TanggalList.fromJson(Map<String, dynamic> json) =>
      TanggalList(tanggalCuti: DateTime.parse(json["tanggal_cuti"]));

  Map<String, dynamic> toJson() => {
    "tanggal_cuti": tanggalCuti.toIso8601String(),
  };
}

class Upload {
  String key;
  String publicUrl;
  String etag;
  int size;

  Upload({
    required this.key,
    required this.publicUrl,
    required this.etag,
    required this.size,
  });

  factory Upload.fromJson(Map<String, dynamic> json) => Upload(
    key: json["key"],
    publicUrl: json["publicUrl"],
    etag: json["etag"],
    size: json["size"],
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "publicUrl": publicUrl,
    "etag": etag,
    "size": size,
  };
}
