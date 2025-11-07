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
  String idPengajuanIzinJam;
  String idUser;
  String idKategoriIzinJam;
  DateTime tanggalIzin;
  DateTime jamMulai;
  DateTime jamSelesai;
  DateTime tanggalPengganti;
  DateTime jamMulaiPengganti;
  DateTime jamSelesaiPengganti;
  String keperluan;
  String handover;
  String lampiranIzinJamUrl;
  String status;
  dynamic currentLevel;
  String jenisPengajuan;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  User user;
  Kategori kategori;
  List<HandoverUser> handoverUsers;

  Data({
    required this.idPengajuanIzinJam,
    required this.idUser,
    required this.idKategoriIzinJam,
    required this.tanggalIzin,
    required this.jamMulai,
    required this.jamSelesai,
    required this.tanggalPengganti,
    required this.jamMulaiPengganti,
    required this.jamSelesaiPengganti,
    required this.keperluan,
    required this.handover,
    required this.lampiranIzinJamUrl,
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
    idPengajuanIzinJam: json["id_pengajuan_izin_jam"],
    idUser: json["id_user"],
    idKategoriIzinJam: json["id_kategori_izin_jam"],
    tanggalIzin: DateTime.parse(json["tanggal_izin"]),
    jamMulai: DateTime.parse(json["jam_mulai"]),
    jamSelesai: DateTime.parse(json["jam_selesai"]),
    tanggalPengganti: DateTime.parse(json["tanggal_pengganti"]),
    jamMulaiPengganti: DateTime.parse(json["jam_mulai_pengganti"]),
    jamSelesaiPengganti: DateTime.parse(json["jam_selesai_pengganti"]),
    keperluan: json["keperluan"],
    handover: json["handover"],
    lampiranIzinJamUrl: json["lampiran_izin_jam_url"],
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
    "id_pengajuan_izin_jam": idPengajuanIzinJam,
    "id_user": idUser,
    "id_kategori_izin_jam": idKategoriIzinJam,
    "tanggal_izin": tanggalIzin.toIso8601String(),
    "jam_mulai": jamMulai.toIso8601String(),
    "jam_selesai": jamSelesai.toIso8601String(),
    "tanggal_pengganti": tanggalPengganti.toIso8601String(),
    "jam_mulai_pengganti": jamMulaiPengganti.toIso8601String(),
    "jam_selesai_pengganti": jamSelesaiPengganti.toIso8601String(),
    "keperluan": keperluan,
    "handover": handover,
    "lampiran_izin_jam_url": lampiranIzinJamUrl,
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
  String idHandoverJam;
  String idPengajuanIzinJam;
  String idUserTagged;
  DateTime createdAt;
  User user;

  HandoverUser({
    required this.idHandoverJam,
    required this.idPengajuanIzinJam,
    required this.idUserTagged,
    required this.createdAt,
    required this.user,
  });

  factory HandoverUser.fromJson(Map<String, dynamic> json) => HandoverUser(
    idHandoverJam: json["id_handover_jam"],
    idPengajuanIzinJam: json["id_pengajuan_izin_jam"],
    idUserTagged: json["id_user_tagged"],
    createdAt: DateTime.parse(json["created_at"]),
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id_handover_jam": idHandoverJam,
    "id_pengajuan_izin_jam": idPengajuanIzinJam,
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
  String idKategoriIzinJam;
  String namaKategori;

  Kategori({required this.idKategoriIzinJam, required this.namaKategori});

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    idKategoriIzinJam: json["id_kategori_izin_jam"],
    namaKategori: json["nama_kategori"],
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_izin_jam": idKategoriIzinJam,
    "nama_kategori": namaKategori,
  };
}

class Meta {
  int page;
  int pageSize;
  int total;
  int totalPages;

  Meta({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
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
