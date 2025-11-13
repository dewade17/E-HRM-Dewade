// To parse this JSON data, do
//
//     final pengajuanCuti = pengajuanCutiFromJson(jsonString);

import 'package:e_hrm/dto/agenda_kerja/agenda_kerja.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

PengajuanCuti pengajuanCutiFromJson(String str) =>
    PengajuanCuti.fromJson(json.decode(str));

String pengajuanCutiToJson(PengajuanCuti data) => json.encode(data.toJson());

class PengajuanCuti {
  bool ok;
  List<Data> data;
  Meta meta;

  PengajuanCuti({required this.ok, required this.data, required this.meta});

  factory PengajuanCuti.fromJson(Map<String, dynamic> json) => PengajuanCuti(
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
  DateTime tanggalMasukKerja;
  String handover;
  String status;
  int currentLevel;
  String jenisPengajuan;
  String lampiranCutiUrl;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  User user;
  KategoriCuti kategoriCuti;
  List<HandoverUser> handoverUsers;
  List<Approval> approvals;
  DateTime? tanggalCuti;
  DateTime? tanggalSelesai;
  List<DateTime> tanggalList;

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
    this.tanggalCuti,
    this.tanggalSelesai,
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
    currentLevel: json["current_level"] is int
        ? json["current_level"]
        : json["current_level"] is num
        ? (json["current_level"] as num).toInt()
        : json["current_level"] is String
        ? int.tryParse(json["current_level"] as String) ?? 0
        : 0,
    jenisPengajuan: json["jenis_pengajuan"],
    lampiranCutiUrl: json["lampiran_cuti_url"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    user: User.fromJson(json["user"]),
    kategoriCuti: KategoriCuti.fromJson(json["kategori_cuti"]),
    handoverUsers: _parseHandoverUsers(json["handover_users"]),
    approvals: _parseApprovals(json["approvals"]),
    tanggalCuti: json["tanggal_cuti"] != null
        ? DateTime.parse(json["tanggal_cuti"])
        : null,
    tanggalSelesai: json["tanggal_selesai"] != null
        ? DateTime.parse(json["tanggal_selesai"])
        : null,
    tanggalList: _parseDateList(json["tanggal_list"]),
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
    if (tanggalCuti != null) "tanggal_cuti": tanggalCuti!.toIso8601String(),
    if (tanggalSelesai != null)
      "tanggal_selesai": tanggalSelesai!.toIso8601String(),
    "tanggal_list": List<dynamic>.from(
      tanggalList.map((x) => x.toIso8601String()),
    ),
  };
}

List<HandoverUser> _parseHandoverUsers(dynamic raw) {
  if (raw is List) {
    return raw
        .map<HandoverUser?>((entry) {
          if (entry is HandoverUser) return entry;
          if (entry is Map<String, dynamic>) {
            return HandoverUser.fromJson(entry);
          }
          if (entry is Map) {
            return HandoverUser.fromJson(
              Map<String, dynamic>.from(entry as Map),
            );
          }
          return null;
        })
        .whereType<HandoverUser>()
        .toList(growable: false);
  }
  return <HandoverUser>[];
}

List<Approval> _parseApprovals(dynamic raw) {
  if (raw is List) {
    return raw
        .map<Approval?>((entry) {
          if (entry is Approval) return entry;
          if (entry is Map<String, dynamic>) {
            return Approval.fromJson(entry);
          }
          if (entry is Map) {
            return Approval.fromJson(Map<String, dynamic>.from(entry as Map));
          }
          return null;
        })
        .whereType<Approval>()
        .toList(growable: false);
  }
  return <Approval>[];
}

List<DateTime> _parseDateList(dynamic raw) {
  if (raw is List) {
    return raw
        .where((entry) => entry != null)
        .map<DateTime?>((entry) {
          if (entry is DateTime) return entry;
          final value = entry.toString();
          if (value.isEmpty) return null;
          return DateTime.tryParse(value);
        })
        .whereType<DateTime>()
        .toList(growable: false);
  }
  if (raw is String && raw.isNotEmpty) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return <DateTime>[parsed];
    }
  }
  return <DateTime>[];
}

class Approval {
  String idApprovalPengajuanCuti;
  int level;
  dynamic approverUserId;
  Role approverRole;
  String decision;
  DateTime decidedAt;
  String note;

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
    approverRole: roleValues.map[json["approver_role"]]!,
    decision: json["decision"],
    decidedAt: DateTime.parse(json["decided_at"]),
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "id_approval_pengajuan_cuti": idApprovalPengajuanCuti,
    "level": level,
    "approver_user_id": approverUserId,
    "approver_role": roleValues.reverse[approverRole],
    "decision": decision,
    "decided_at": decidedAt.toIso8601String(),
    "note": note,
  };
}

enum Role { KARYAWAN, SUPERADMIN }

final roleValues = EnumValues({
  "KARYAWAN": Role.KARYAWAN,
  "SUPERADMIN": Role.SUPERADMIN,
});

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
  NamaPengguna namaPengguna;
  Email email;
  Role role;
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
    namaPengguna: namaPenggunaValues.map[json["nama_pengguna"]]!,
    email: emailValues.map[json["email"]]!,
    role: roleValues.map[json["role"]]!,
    fotoProfilUser: json["foto_profil_user"],
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPenggunaValues.reverse[namaPengguna],
    "email": emailValues.reverse[email],
    "role": roleValues.reverse[role],
    "foto_profil_user": fotoProfilUser,
  };
}

enum Email { ADITYA_YOGANTARAZ_GMAIL_COM, ODE_GMAIL_COM }

final emailValues = EnumValues({
  "aditya.yogantaraz@gmail.com": Email.ADITYA_YOGANTARAZ_GMAIL_COM,
  "ode@gmail.com": Email.ODE_GMAIL_COM,
});

enum NamaPengguna { ADITYA, ODE }

final namaPenggunaValues = EnumValues({
  "aditya": NamaPengguna.ADITYA,
  "ode": NamaPengguna.ODE,
});

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

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
