import 'dart:convert';

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.isUtc ? value.toLocal() : value;
  if (value is String && value.isNotEmpty) {
    final raw = value.trim();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;

    final hasTimeZoneSuffix = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);

    if (parsed.isUtc || hasTimeZoneSuffix) {
      return parsed.toLocal();
    }

    return parsed;
  }
  return null;
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

String _parseApproverRole(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    final dynamic name = value['nama_pengguna'];
    if (name is String && name.isNotEmpty) return name;
  }
  return value.toString();
}

IzinTukarHari izinTukarHariFromJson(String str) =>
    IzinTukarHari.fromJson(json.decode(str));

String izinTukarHariToJson(IzinTukarHari data) => json.encode(data.toJson());

class IzinTukarHari {
  bool ok;
  List<Data> data;
  Meta meta;

  IzinTukarHari({required this.ok, required this.data, required this.meta});

  factory IzinTukarHari.fromJson(Map<String, dynamic> json) => IzinTukarHari(
    ok: json["ok"] ?? false,
    data: List<Data>.from(
      (json["data"] as List? ?? []).map(
        (x) => Data.fromJson(x as Map<String, dynamic>),
      ),
    ),
    meta: Meta.fromJson(json["meta"] as Map<String, dynamic>? ?? {}),
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
  String kategori;
  String keperluan;
  String handover;
  String lampiranIzinTukarHariUrl;
  String status;
  int currentLevel;
  String jenisPengajuan;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  DataUser user;
  List<HandoverUser> handoverUsers;
  List<Approval> approvals;
  List<Pair> pairs;

  Data({
    required this.idIzinTukarHari,
    required this.idUser,
    required this.kategori,
    required this.keperluan,
    required this.handover,
    required this.lampiranIzinTukarHariUrl,
    required this.status,
    required this.currentLevel,
    required this.jenisPengajuan,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.user,
    required this.handoverUsers,
    required this.approvals,
    required this.pairs,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idIzinTukarHari: json["id_izin_tukar_hari"] ?? '',
    idUser: json["id_user"] ?? '',
    kategori: json["kategori"] ?? '',
    keperluan: json["keperluan"] ?? '',
    handover: json["handover"] ?? '',
    lampiranIzinTukarHariUrl: json["lampiran_izin_tukar_hari_url"] ?? '',
    status: json["status"] ?? 'pending',
    currentLevel: _parseInt(json["current_level"]),
    jenisPengajuan: json["jenis_pengajuan"] ?? '',
    createdAt: _parseDateTime(json["created_at"]),
    updatedAt: _parseDateTime(json["updated_at"]),
    deletedAt: json["deleted_at"],
    user: DataUser.fromJson(json["user"] as Map<String, dynamic>? ?? {}),
    handoverUsers: (json["handover_users"] as List? ?? [])
        .map((x) => HandoverUser.fromJson(x as Map<String, dynamic>))
        .toList(),
    approvals: (json["approvals"] as List? ?? [])
        .map((x) => Approval.fromJson(x as Map<String, dynamic>))
        .toList(),
    pairs: (json["pairs"] as List? ?? [])
        .map((x) => Pair.fromJson(x as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "id_izin_tukar_hari": idIzinTukarHari,
    "id_user": idUser,
    "kategori": kategori,
    "keperluan": keperluan,
    "handover": handover,
    "lampiran_izin_tukar_hari_url": lampiranIzinTukarHariUrl,
    "status": status,
    "current_level": currentLevel,
    "jenis_pengajuan": jenisPengajuan,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "user": user.toJson(),
    "handover_users": List<dynamic>.from(handoverUsers.map((x) => x.toJson())),
    "approvals": List<dynamic>.from(approvals.map((x) => x.toJson())),
    "pairs": List<dynamic>.from(pairs.map((x) => x.toJson())),
  };
}

class Approval {
  String idApprovalIzinTukarHari;
  int level;
  dynamic approverUserId;
  String? approverRole;
  String decision;
  DateTime? decidedAt;
  String? note;
  DataUser? approver;

  Approval({
    required this.idApprovalIzinTukarHari,
    required this.level,
    required this.approverUserId,
    this.approverRole,
    required this.decision,
    this.decidedAt,
    this.note,
    this.approver,
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
    idApprovalIzinTukarHari: json["id_approval_izin_tukar_hari"] ?? '',
    level: _parseInt(json["level"]),
    approverUserId: json["approver_user_id"],
    approverRole: _parseApproverRole(json["approver_role"]),
    decision: json["decision"] ?? 'pending',
    decidedAt: _parseDateTime(json["decided_at"]),
    note: json["note"],
    approver: json["approver"] == null
        ? null
        : DataUser.fromJson(json["approver"] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    "id_approval_izin_tukar_hari": idApprovalIzinTukarHari,
    "level": level,
    "approver_user_id": approverUserId,
    "approver_role": approverRole,
    "decision": decision,
    "decided_at": decidedAt?.toIso8601String(),
    "note": note,
    if (approver != null) "approver": approver!.toJson(),
  };
}

class HandoverUser {
  String idHandoverTukarHari;
  String idIzinTukarHari;
  String idUserTagged;
  DateTime? createdAt;
  DataUser user;

  HandoverUser({
    required this.idHandoverTukarHari,
    required this.idIzinTukarHari,
    required this.idUserTagged,
    this.createdAt,
    required this.user,
  });

  factory HandoverUser.fromJson(Map<String, dynamic> json) => HandoverUser(
    idHandoverTukarHari: json["id_handover_tukar_hari"] ?? '',
    idIzinTukarHari: json["id_izin_tukar_hari"] ?? '',
    idUserTagged: json["id_user_tagged"] ?? '',
    createdAt: _parseDateTime(json["created_at"]),
    user: DataUser.fromJson(json["user"] as Map<String, dynamic>? ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "id_handover_tukar_hari": idHandoverTukarHari,
    "id_izin_tukar_hari": idIzinTukarHari,
    "id_user_tagged": idUserTagged,
    "created_at": createdAt?.toIso8601String(),
    "user": user.toJson(),
  };
}

class Pair {
  String idIzinTukarHariPair;
  DateTime? hariIzin;
  DateTime? hariPengganti;
  dynamic catatanPair;

  Pair({
    required this.idIzinTukarHariPair,
    this.hariIzin,
    this.hariPengganti,
    required this.catatanPair,
  });

  factory Pair.fromJson(Map<String, dynamic> json) => Pair(
    idIzinTukarHariPair: json["id_izin_tukar_hari_pair"] ?? '',
    hariIzin: _parseDateTime(json["hari_izin"]),
    hariPengganti: _parseDateTime(json["hari_pengganti"]),
    catatanPair: json["catatan_pair"],
  );

  Map<String, dynamic> toJson() => {
    "id_izin_tukar_hari_pair": idIzinTukarHariPair,
    "hari_izin": hariIzin?.toIso8601String(),
    "hari_pengganti": hariPengganti?.toIso8601String(),
    "catatan_pair": catatanPair,
  };
}

class DataUser {
  String idUser;
  String namaPengguna;
  String email;
  String role;
  String fotoProfilUser;
  String idDepartement;
  Departement? departement;
  Jabatan? jabatan;

  DataUser({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    required this.fotoProfilUser,
    required this.idDepartement,
    this.departement,
    this.jabatan,
  });

  factory DataUser.fromJson(Map<String, dynamic> json) => DataUser(
    idUser: json["id_user"] ?? '',
    namaPengguna: json["nama_pengguna"] ?? '',
    email: json["email"] ?? '',
    role: json["role"] ?? '',
    fotoProfilUser: json["foto_profil_user"] ?? '',
    idDepartement: json["id_departement"] ?? '',
    departement: json["departement"] == null
        ? null
        : Departement.fromJson(json["departement"]),
    jabatan: json["jabatan"] == null ? null : Jabatan.fromJson(json["jabatan"]),
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
    "role": role,
    "foto_profil_user": fotoProfilUser,
    "id_departement": idDepartement,
    "departement": departement?.toJson(),
    "jabatan": jabatan?.toJson(),
  };
}

class Departement {
  String idDepartement;
  String namaDepartement;

  Departement({required this.idDepartement, required this.namaDepartement});

  factory Departement.fromJson(Map<String, dynamic> json) => Departement(
    idDepartement: json["id_departement"] ?? '',
    namaDepartement: json["nama_departement"] ?? '',
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

  factory Jabatan.fromJson(Map<String, dynamic> json) => Jabatan(
    idJabatan: json["id_jabatan"] ?? '',
    namaJabatan: json["nama_jabatan"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id_jabatan": idJabatan,
    "nama_jabatan": namaJabatan,
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
    page: _parseInt(json["page"], fallback: 1),
    perPage: _parseInt(json["perPage"], fallback: 20),
    total: _parseInt(json["total"]),
    totalPages: _parseInt(json["totalPages"], fallback: 1),
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "perPage": perPage,
    "total": total,
    "totalPages": totalPages,
  };
}
