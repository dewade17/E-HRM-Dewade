import 'dart:convert';

PengajuanSakit pengajuanSakitFromJson(String str) =>
    PengajuanSakit.fromJson(json.decode(str));

String pengajuanSakitToJson(PengajuanSakit data) => json.encode(data.toJson());

class PengajuanSakit {
  String message;
  List<Data> data;
  Meta meta;

  PengajuanSakit({
    required this.message,
    required this.data,
    required this.meta,
  });

  factory PengajuanSakit.fromJson(Map<String, dynamic> json) => PengajuanSakit(
    message: json["message"],
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta.toJson(),
  };
}

class Data {
  String idPengajuanIzinSakit;
  String idUser;
  String idKategoriSakit;
  String handover;
  String lampiranIzinSakitUrl;
  String status;
  int currentLevel;
  String jenisPengajuan;
  DateTime tanggalPengajuan;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  DataUser user;
  Kategori kategori;
  List<HandoverUser> handoverUsers;
  List<Approval> approvals;

  Data({
    required this.idPengajuanIzinSakit,
    required this.idUser,
    required this.idKategoriSakit,
    required this.handover,
    required this.lampiranIzinSakitUrl,
    required this.status,
    required this.currentLevel,
    required this.jenisPengajuan,
    required this.tanggalPengajuan,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.user,
    required this.kategori,
    required this.handoverUsers,
    required this.approvals,
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
    tanggalPengajuan: DateTime.parse(json["tanggal_pengajuan"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    user: DataUser.fromJson(json["user"]),
    kategori: Kategori.fromJson(json["kategori"]),
    handoverUsers: List<HandoverUser>.from(
      json["handover_users"].map((x) => HandoverUser.fromJson(x)),
    ),
    approvals: List<Approval>.from(
      json["approvals"].map((x) => Approval.fromJson(x)),
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
    "tanggal_pengajuan": tanggalPengajuan.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "user": user.toJson(),
    "kategori": kategori.toJson(),
    "handover_users": List<dynamic>.from(handoverUsers.map((x) => x.toJson())),
    "approvals": List<dynamic>.from(approvals.map((x) => x.toJson())),
  };
}

class Approval {
  String idApprovalIzinSakit;
  int level;
  dynamic approverUserId;
  String approverRole;
  String decision;
  dynamic decidedAt;
  dynamic note;

  Approval({
    required this.idApprovalIzinSakit,
    required this.level,
    required this.approverUserId,
    required this.approverRole,
    required this.decision,
    required this.decidedAt,
    required this.note,
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
    idApprovalIzinSakit: json["id_approval_izin_sakit"],
    level: json["level"],
    approverUserId: json["approver_user_id"],
    approverRole: json["approver_role"],
    decision: json["decision"],
    decidedAt: json["decided_at"],
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "id_approval_izin_sakit": idApprovalIzinSakit,
    "level": level,
    "approver_user_id": approverUserId,
    "approver_role": approverRole,
    "decision": decision,
    "decided_at": decidedAt,
    "note": note,
  };
}

class HandoverUser {
  String idHandoverSakit;
  String idPengajuanIzinSakit;
  String idUserTagged;
  DateTime createdAt;
  HandoverUserUser user;

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
    user: HandoverUserUser.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id_handover_sakit": idHandoverSakit,
    "id_pengajuan_izin_sakit": idPengajuanIzinSakit,
    "id_user_tagged": idUserTagged,
    "created_at": createdAt.toIso8601String(),
    "user": user.toJson(),
  };
}

class HandoverUserUser {
  String idUser;
  String namaPengguna;
  String email;
  String role;
  String fotoProfilUser;

  HandoverUserUser({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    required this.fotoProfilUser,
  });

  factory HandoverUserUser.fromJson(Map<String, dynamic> json) =>
      HandoverUserUser(
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

class DataUser {
  String idUser;
  String namaPengguna;
  String email;
  String role;
  String fotoProfilUser;
  String idDepartement;
  Departement departement;
  Jabatan jabatan;

  DataUser({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    required this.fotoProfilUser,
    required this.idDepartement,
    required this.departement,
    required this.jabatan,
  });

  factory DataUser.fromJson(Map<String, dynamic> json) => DataUser(
    idUser: json["id_user"],
    namaPengguna: json["nama_pengguna"],
    email: json["email"],
    role: json["role"],
    fotoProfilUser: json["foto_profil_user"],
    idDepartement: json["id_departement"],
    departement: Departement.fromJson(json["departement"]),
    jabatan: Jabatan.fromJson(json["jabatan"]),
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
    "role": role,
    "foto_profil_user": fotoProfilUser,
    "id_departement": idDepartement,
    "departement": departement.toJson(),
    "jabatan": jabatan.toJson(),
  };
}

class Departement {
  String idDepartement;
  String namaDepartement;

  Departement({required this.idDepartement, required this.namaDepartement});

  factory Departement.fromJson(Map<String, dynamic> json) => Departement(
    idDepartement: json["id_departement"],
    namaDepartement: json["nama_departement"],
  );

  Map<String, dynamic> toJson() => {
    "id_departement": idDepartement,
    "nama_departement": namaDepartement,
  };
}

class Jabatan {
  String idJabatan;
  String namaJabatan;

  Jabatan({required this.idJabatan, required this.namaJabatan});

  factory Jabatan.fromJson(Map<String, dynamic> json) =>
      Jabatan(idJabatan: json["id_jabatan"], namaJabatan: json["nama_jabatan"]);

  Map<String, dynamic> toJson() => {
    "id_jabatan": idJabatan,
    "nama_jabatan": namaJabatan,
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
