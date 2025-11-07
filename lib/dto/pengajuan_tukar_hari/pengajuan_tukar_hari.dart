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
  String idIzinTukarHari;
  String idUser;
  DateTime hariIzin;
  DateTime hariPengganti;
  String kategori;
  String keperluan;
  String handover;
  String status;
  dynamic currentLevel;
  String jenisPengajuan;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  User user;
  List<HandoverUser> handoverUsers;

  Data({
    required this.idIzinTukarHari,
    required this.idUser,
    required this.hariIzin,
    required this.hariPengganti,
    required this.kategori,
    required this.keperluan,
    required this.handover,
    required this.status,
    this.currentLevel,
    required this.jenisPengajuan,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.user,
    required this.handoverUsers,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idIzinTukarHari: json["id_izin_tukar_hari"],
    idUser: json["id_user"],
    hariIzin: DateTime.parse(json["hari_izin"]),
    hariPengganti: DateTime.parse(json["hari_pengganti"]),
    kategori: json["kategori"],
    keperluan: json["keperluan"],
    handover: json["handover"],
    status: json["status"],
    currentLevel: json["current_level"],
    jenisPengajuan: json["jenis_pengajuan"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    user: User.fromJson(json["user"]),
    handoverUsers: List<HandoverUser>.from(
      json["handover_users"].map((x) => HandoverUser.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id_izin_tukar_hari": idIzinTukarHari,
    "id_user": idUser,
    "hari_izin": hariIzin.toIso8601String(),
    "hari_pengganti": hariPengganti.toIso8601String(),
    "kategori": kategori,
    "keperluan": keperluan,
    "handover": handover,
    "status": status,
    "current_level": currentLevel,
    "jenis_pengajuan": jenisPengajuan,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "user": user.toJson(),
    "handover_users": List<dynamic>.from(handoverUsers.map((x) => x.toJson())),
  };
}

class HandoverUser {
  String idHandoverTukarHari;
  String idIzinTukarHari;
  String idUserTagged;
  DateTime createdAt;
  User user;

  HandoverUser({
    required this.idHandoverTukarHari,
    required this.idIzinTukarHari,
    required this.idUserTagged,
    required this.createdAt,
    required this.user,
  });

  factory HandoverUser.fromJson(Map<String, dynamic> json) => HandoverUser(
    idHandoverTukarHari: json["id_handover_tukar_hari"],
    idIzinTukarHari: json["id_izin_tukar_hari"],
    idUserTagged: json["id_user_tagged"],
    createdAt: DateTime.parse(json["created_at"]),
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id_handover_tukar_hari": idHandoverTukarHari,
    "id_izin_tukar_hari": idIzinTukarHari,
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
