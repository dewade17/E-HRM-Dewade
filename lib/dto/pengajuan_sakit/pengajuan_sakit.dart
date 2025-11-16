// lib/dto/pengajuan_sakit/pengajuan_sakit.dart

import 'dart:convert';

PengajuanSakit pengajuanSakitFromJson(String str) =>
    PengajuanSakit.fromJson(json.decode(str));

String pengajuanSakitToJson(PengajuanSakit data) => json.encode(data.toJson());

// --- HELPER PARSING BARU (Diambil dari referensi pengajuan_izin_jam) ---
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<HandoverUser> _parseHandoverUsers(dynamic raw) {
  if (raw is List) {
    return raw
        .map((x) {
          try {
            return HandoverUser.fromJson(x as Map<String, dynamic>);
          } catch (e) {
            return null;
          }
        })
        .whereType<HandoverUser>()
        .toList();
  }
  return <HandoverUser>[]; // Selalu kembalikan list, bukan null
}

List<Approval> _parseApprovals(dynamic raw) {
  if (raw is List) {
    return raw
        .map((x) {
          try {
            return Approval.fromJson(x as Map<String, dynamic>);
          } catch (e) {
            return null;
          }
        })
        .whereType<Approval>()
        .toList();
  }
  return <Approval>[]; // Selalu kembalikan list, bukan null
}
// --- AKHIR HELPER PARSING ---

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
    message: json["message"] ?? 'OK', // Fallback
    data: List<Data>.from(
      (json["data"] as List? ?? []) // Jaga dari list null
          .map((x) => Data.fromJson(x as Map<String, dynamic>)),
    ),
    meta: Meta.fromJson(json["meta"] as Map<String, dynamic>? ?? {}),
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
  int? currentLevel; // <-- DIUBAH JADI NULLABLE
  String jenisPengajuan;
  DateTime? tanggalPengajuan; // <-- DIUBAH JADI NULLABLE
  DateTime? createdAt; // <-- DIUBAH JADI NULLABLE
  DateTime? updatedAt; // <-- DIUBAH JADI NULLABLE
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
    this.currentLevel,
    required this.jenisPengajuan,
    this.tanggalPengajuan,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.user,
    required this.kategori,
    required this.handoverUsers,
    required this.approvals,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idPengajuanIzinSakit: json["id_pengajuan_izin_sakit"] ?? '',
    idUser: json["id_user"] ?? '',
    idKategoriSakit: json["id_kategori_sakit"] ?? '',
    handover: json["handover"] ?? '',
    lampiranIzinSakitUrl: json["lampiran_izin_sakit_url"] ?? '',
    status: json["status"] ?? 'pending',
    currentLevel: _parseInt(json["current_level"]), // <-- PERBAIKAN
    jenisPengajuan: json["jenis_pengajuan"] ?? '',
    tanggalPengajuan: _parseDateTime(
      json["tanggal_pengajuan"],
    ), // <-- PERBAIKAN
    createdAt: _parseDateTime(json["created_at"]), // <-- PERBAIKAN
    updatedAt: _parseDateTime(json["updated_at"]), // <-- PERBAIKAN
    deletedAt: json["deleted_at"],
    user: DataUser.fromJson(json["user"] as Map<String, dynamic>? ?? {}),
    kategori: Kategori.fromJson(
      json["kategori"] as Map<String, dynamic>? ?? {},
    ),
    handoverUsers: _parseHandoverUsers(json["handover_users"]), // <-- PERBAIKAN
    approvals: _parseApprovals(json["approvals"]), // <-- PERBAIKAN
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
    "tanggal_pengajuan": tanggalPengajuan?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "user": user.toJson(),
    "kategori": kategori.toJson(),
    "handover_users": List<dynamic>.from(handoverUsers.map((x) => x.toJson())),
    "approvals": List<dynamic>.from(approvals.map((x) => x.toJson())),
  };
}

// ======================================================
// ===== PERBAIKAN UTAMA ADA DI KELAS APPROVAL INI =====
// ======================================================
class Approval {
  String idApprovalIzinSakit;
  int level;
  dynamic approverUserId;
  String approverRole;
  String decision;
  DateTime? decidedAt; // <-- DIUBAH JADI NULLABLE
  String? note; // <-- DIUBAH JADI NULLABLE

  Approval({
    required this.idApprovalIzinSakit,
    required this.level,
    required this.approverUserId,
    required this.approverRole,
    required this.decision,
    this.decidedAt, // <-- Diperbarui
    this.note, // <-- Diperbarui
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
    idApprovalIzinSakit: json["id_approval_izin_sakit"] ?? '',
    level: _parseInt(json["level"]) ?? 0, // <-- Menggunakan parser aman
    approverUserId: json["approver_user_id"],
    approverRole: json["approver_role"] ?? '',
    decision: json["decision"] ?? 'pending',
    decidedAt: _parseDateTime(
      json["decided_at"],
    ), // <-- Menggunakan parser aman
    note: json["note"]?.toString(), // <-- Dibuat aman
  );

  Map<String, dynamic> toJson() => {
    "id_approval_izin_sakit": idApprovalIzinSakit,
    "level": level,
    "approver_user_id": approverUserId,
    "approver_role": approverRole,
    "decision": decision,
    "decided_at": decidedAt?.toIso8601String(), // <-- Aman jika decidedAt null
    "note": note, // <-- Aman jika note null
  };
}
// ======================================================
// ======================================================

class HandoverUser {
  String idHandoverSakit;
  String idPengajuanIzinSakit;
  String idUserTagged;
  DateTime? createdAt; // <-- DIUBAH JADI NULLABLE
  HandoverUserUser user;

  HandoverUser({
    required this.idHandoverSakit,
    required this.idPengajuanIzinSakit,
    required this.idUserTagged,
    this.createdAt,
    required this.user,
  });

  factory HandoverUser.fromJson(Map<String, dynamic> json) => HandoverUser(
    idHandoverSakit: json["id_handover_sakit"] ?? '',
    idPengajuanIzinSakit: json["id_pengajuan_izin_sakit"] ?? '',
    idUserTagged: json["id_user_tagged"] ?? '',
    createdAt: _parseDateTime(json["created_at"]), // <-- PERBAIKAN
    user: HandoverUserUser.fromJson(
      json["user"] as Map<String, dynamic>? ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "id_handover_sakit": idHandoverSakit,
    "id_pengajuan_izin_sakit": idPengajuanIzinSakit,
    "id_user_tagged": idUserTagged,
    "created_at": createdAt?.toIso8601String(),
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
        idUser: json["id_user"] ?? '',
        namaPengguna: json["nama_pengguna"] ?? '',
        email: json["email"] ?? '',
        role: json["role"] ?? '',
        fotoProfilUser: json["foto_profil_user"] ?? '',
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
    idKategoriSakit: json["id_kategori_sakit"] ?? '',
    namaKategori: json["nama_kategori"] ?? '',
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
    idUser: json["id_user"] ?? '',
    namaPengguna: json["nama_pengguna"] ?? '',
    email: json["email"] ?? '',
    role: json["role"] ?? '',
    fotoProfilUser: json["foto_profil_user"] ?? '',
    idDepartement: json["id_departement"] ?? '',
    departement: Departement.fromJson(
      json["departement"] as Map<String, dynamic>? ?? {},
    ),
    jabatan: Jabatan.fromJson(json["jabatan"] as Map<String, dynamic>? ?? {}),
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
    page: _parseInt(json["page"]) ?? 1,
    pageSize: _parseInt(json["pageSize"]) ?? 20,
    total: _parseInt(json["total"]) ?? 0,
    totalPages: _parseInt(json["totalPages"]) ?? 1,
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "pageSize": pageSize,
    "total": total,
    "totalPages": totalPages,
  };
}
