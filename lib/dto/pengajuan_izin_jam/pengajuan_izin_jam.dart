// lib/dto/pengajuan_izin_jam/pengajuan_izin_jam.dart
import 'dart:convert';

PengajuanIzinJam pengajuanIzinJamFromJson(String str) =>
    PengajuanIzinJam.fromJson(json.decode(str));

String pengajuanIzinJamToJson(PengajuanIzinJam data) =>
    json.encode(data.toJson());

// --- FUNGSI HELPER BARU ---
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
// --- AKHIR FUNGSI HELPER ---

class PengajuanIzinJam {
  bool ok;
  List<Data> data;
  Meta meta;

  PengajuanIzinJam({required this.ok, required this.data, required this.meta});

  factory PengajuanIzinJam.fromJson(Map<String, dynamic> json) =>
      PengajuanIzinJam(
        ok: json["ok"] ?? false, // Tambahkan fallback
        data: List<Data>.from(
          (json["data"] as List? ?? []) // Jaga dari list null
              .map((x) => Data.fromJson(x as Map<String, dynamic>)),
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
  String idPengajuanIzinJam;
  String idUser;
  String idKategoriIzinJam;
  DateTime? tanggalIzin; // <-- DIUBAH JADI NULLABLE
  DateTime? jamMulai; // <-- DIUBAH JADI NULLABLE
  DateTime? jamSelesai; // <-- DIUBAH JADI NULLABLE
  DateTime? tanggalPengganti; // <-- DIUBAH JADI NULLABLE
  DateTime? jamMulaiPengganti; // <-- DIUBAH JADI NULLABLE
  DateTime? jamSelesaiPengganti; // <-- DIUBAH JADI NULLABLE
  String keperluan;
  String handover;
  String lampiranIzinJamUrl;
  String status;
  int? currentLevel; // <-- DIUBAH JADI NULLABLE
  String jenisPengajuan;
  DateTime? createdAt; // <-- DIUBAH JADI NULLABLE
  DateTime? updatedAt; // <-- DIUBAH JADI NULLABLE
  dynamic deletedAt;
  DataUser user;
  Kategori kategori;
  List<HandoverUser> handoverUsers;
  List<Approval> approvals;

  Data({
    required this.idPengajuanIzinJam,
    required this.idUser,
    required this.idKategoriIzinJam,
    this.tanggalIzin,
    this.jamMulai,
    this.jamSelesai,
    this.tanggalPengganti,
    this.jamMulaiPengganti,
    this.jamSelesaiPengganti,
    required this.keperluan,
    required this.handover,
    required this.lampiranIzinJamUrl,
    required this.status,
    this.currentLevel,
    required this.jenisPengajuan,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.user,
    required this.kategori,
    required this.handoverUsers,
    required this.approvals,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idPengajuanIzinJam: json["id_pengajuan_izin_jam"] ?? '',
    idUser: json["id_user"] ?? '',
    idKategoriIzinJam: json["id_kategori_izin_jam"] ?? '',
    tanggalIzin: _parseDateTime(json["tanggal_izin"]),
    jamMulai: _parseDateTime(json["jam_mulai"]),
    jamSelesai: _parseDateTime(json["jam_selesai"]),
    tanggalPengganti: _parseDateTime(json["tanggal_pengganti"]),
    jamMulaiPengganti: _parseDateTime(json["jam_mulai_pengganti"]),
    jamSelesaiPengganti: _parseDateTime(json["jam_selesai_pengganti"]),
    keperluan: json["keperluan"] ?? '',
    handover: json["handover"] ?? '',
    lampiranIzinJamUrl: json["lampiran_izin_jam_url"] ?? '',
    status: json["status"] ?? 'pending',
    currentLevel: _parseInt(json["current_level"]), // <-- PERBAIKAN
    jenisPengajuan: json["jenis_pengajuan"] ?? '',
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
    "id_pengajuan_izin_jam": idPengajuanIzinJam,
    "id_user": idUser,
    "id_kategori_izin_jam": idKategoriIzinJam,
    "tanggal_izin": tanggalIzin?.toIso8601String(),
    "jam_mulai": jamMulai?.toIso8601String(),
    "jam_selesai": jamSelesai?.toIso8601String(),
    "tanggal_pengganti": tanggalPengganti?.toIso8601String(),
    "jam_mulai_pengganti": jamMulaiPengganti?.toIso8601String(),
    "jam_selesai_pengganti": jamSelesaiPengganti?.toIso8601String(),
    "keperluan": keperluan,
    "handover": handover,
    "lampiran_izin_jam_url": lampiranIzinJamUrl,
    "status": status,
    "current_level": currentLevel,
    "jenis_pengajuan": jenisPengajuan,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "user": user.toJson(),
    "kategori": kategori.toJson(),
    "handover_users": List<dynamic>.from(handoverUsers.map((x) => x.toJson())),
    "approvals": List<dynamic>.from(approvals.map((x) => x.toJson())),
  };
}

class Approval {
  String idApprovalPengajuanIzinJam;
  int level;
  dynamic approverUserId;
  String approverRole;
  String decision;
  DateTime? decidedAt; // <-- DIUBAH JADI NULLABLE
  String? note; // <-- DIUBAH JADI STRING NULLABLE

  Approval({
    required this.idApprovalPengajuanIzinJam,
    required this.level,
    required this.approverUserId,
    required this.approverRole,
    required this.decision,
    this.decidedAt,
    this.note,
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
    idApprovalPengajuanIzinJam: json["id_approval_pengajuan_izin_jam"] ?? '',
    level: _parseInt(json["level"]) ?? 0, // <-- PERBAIKAN
    approverUserId: json["approver_user_id"],
    approverRole: json["approver_role"] ?? '',
    decision: json["decision"] ?? 'pending',
    decidedAt: _parseDateTime(json["decided_at"]), // <-- PERBAIKAN
    note: json["note"]?.toString(), // <-- PERBAIKAN
  );

  Map<String, dynamic> toJson() => {
    "id_approval_pengajuan_izin_jam": idApprovalPengajuanIzinJam,
    "level": level,
    "approver_user_id": approverUserId,
    "approver_role": approverRole,
    "decision": decision,
    "decided_at": decidedAt?.toIso8601String(),
    "note": note,
  };
}

// ... Sisa kelas (HandoverUser, HandoverUserUser, Kategori, DataUser, Departement, Jabatan, Meta) ...
// (Saya asumsikan kelas-kelas di bawah ini sudah benar, namun jika Anda mengalami error serupa,
//  Anda mungkin perlu menerapkan parsing aman _parseDateTime dan _parseInt juga di sana)

class HandoverUser {
  String idHandoverJam;
  String idPengajuanIzinJam;
  String idUserTagged;
  DateTime? createdAt; // <-- DIUBAH JADI NULLABLE
  HandoverUserUser user;

  HandoverUser({
    required this.idHandoverJam,
    required this.idPengajuanIzinJam,
    required this.idUserTagged,
    this.createdAt,
    required this.user,
  });

  factory HandoverUser.fromJson(Map<String, dynamic> json) => HandoverUser(
    idHandoverJam: json["id_handover_jam"] ?? '',
    idPengajuanIzinJam: json["id_pengajuan_izin_jam"] ?? '',
    idUserTagged: json["id_user_tagged"] ?? '',
    createdAt: _parseDateTime(json["created_at"]), // <-- PERBAIKAN
    user: HandoverUserUser.fromJson(
      json["user"] as Map<String, dynamic>? ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "id_handover_jam": idHandoverJam,
    "id_pengajuan_izin_jam": idPengajuanIzinJam,
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
  String idKategoriIzinJam;
  String namaKategori;

  Kategori({required this.idKategoriIzinJam, required this.namaKategori});

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    idKategoriIzinJam: json["id_kategori_izin_jam"] ?? '',
    namaKategori: json["nama_kategori"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id_kategori_izin_jam": idKategoriIzinJam,
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
