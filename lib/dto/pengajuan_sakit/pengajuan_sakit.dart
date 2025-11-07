import 'package:meta/meta.dart';
import 'dart:convert';

Kategoricuti kategoricutiFromJson(String str) =>
    Kategoricuti.fromJson(json.decode(str));

String kategoricutiToJson(Kategoricuti data) => json.encode(data.toJson());

class Kategoricuti {
  String message;
  Data data;

  Kategoricuti({required this.message, required this.data});

  factory Kategoricuti.fromJson(Map<String, dynamic> json) =>
      Kategoricuti(message: json["message"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  String idPengajuanIzinSakit;
  String idUser;
  String idKategoriSakit;
  String handover;
  dynamic lampiranIzinSakitUrl;
  String status;
  int currentLevel;
  String jenisPengajuan;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  User user;
  Kategori kategori;
  List<HandoverUser> handoverUsers;

  Data({
    required this.idPengajuanIzinSakit,
    required this.idUser,
    required this.idKategoriSakit,
    required this.handover,
    required this.lampiranIzinSakitUrl,
    required this.status,
    required this.currentLevel,
    required this.jenisPengajuan,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.user,
    required this.kategori,
    required this.handoverUsers,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idPengajuanIzinSakit: json["id_pengajuan_izin_sakit"],
    idUser: json["id_user"],
    idKategoriSakit: json["id_kategori_sakit"],
    handover: json["handover"],
    lampiranIzinSakitUrl: json["lampiran_izin_sakit_url"],
    status: json["status"],
    currentLevel: json["current_level"],
    jenisPengajuan: json["jenis_pengajuan"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    user: User.fromJson(json["user"]),
    kategori: Kategori.fromJson(json["kategori"]),
    handoverUsers: List<HandoverUser>.from(
      json["handover_users"].map((x) => HandoverUser.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id_pengajuan_izin_sakit": idPengajuanIzinSakit,
    "id_user": idUser,
    "id_kategori_sakit": idKategoriSakit,
    "handover": handover,
    "lampiran_izin_sakit_url": lampiranIzinSakitUrl,
    "status": status,
    "current_level": currentLevel,
    "jenis_pengajuan": jenisPengajuan,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "user": user.toJson(),
    "kategori": kategori.toJson(),
    "handover_users": List<dynamic>.from(handoverUsers.map((x) => x.toJson())),
  };
}

class HandoverUser {
  String idHandoverSakit;
  String idPengajuanIzinSakit;
  String idUserTagged;
  DateTime createdAt;
  User user;

  HandoverUser({
    required this.idHandoverSakit,
    required this.idPengajuanIzinSakit,
    required this.idUserTagged,
    required this.createdAt,
    required this.user,
  });

  factory HandoverUser.fromJson(Map<String, dynamic> json) => HandoverUser(
    idHandoverSakit: json["id_handover_sakit"],
    idPengajuanIzinSakit: json["id_pengajuan_izin_sakit"],
    idUserTagged: json["id_user_tagged"],
    createdAt: DateTime.parse(json["created_at"]),
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id_handover_sakit": idHandoverSakit,
    "id_pengajuan_izin_sakit": idPengajuanIzinSakit,
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

class Kategori {
  String idKategoriSakit;
  String namaKategori;

  Kategori({required this.idKategoriSakit, required this.namaKategori});

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    idKategoriSakit: json["id_kategori_sakit"],
    namaKategori: json["nama_kategori"],
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_sakit": idKategoriSakit,
    "nama_kategori": namaKategori,
  };
}
