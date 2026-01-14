// To parse this JSON data, do
//
//     final pocketMoney = pocketMoneyFromJson(jsonString);

import 'package:e_hrm/dto/pengajuan_izin_jam/kategori_izin_jam.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

PocketMoney pocketMoneyFromJson(String str) =>
    PocketMoney.fromJson(json.decode(str));

String pocketMoneyToJson(PocketMoney data) => json.encode(data.toJson());

class PocketMoney {
  bool ok;
  List<Data> data;
  Meta meta;

  PocketMoney({required this.ok, required this.data, required this.meta});

  factory PocketMoney.fromJson(Map<String, dynamic> json) => PocketMoney(
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
  String idPocketMoney;
  String idUser;
  String idDepartement;
  String idKategoriKeperluan;
  DateTime tanggal;
  String keterangan;
  String totalPengeluaran;
  String metodePembayaran;
  dynamic nomorRekening;
  dynamic namaPemilikRekening;
  dynamic jenisBank;
  String buktiPembayaranUrl;
  String status;
  dynamic currentLevel;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  Departement departement;
  KategoriKeperluan kategoriKeperluan;
  List<Item> items;
  List<Approval> approvals;

  Data({
    required this.idPocketMoney,
    required this.idUser,
    required this.idDepartement,
    required this.idKategoriKeperluan,
    required this.tanggal,
    required this.keterangan,
    required this.totalPengeluaran,
    required this.metodePembayaran,
    required this.nomorRekening,
    required this.namaPemilikRekening,
    required this.jenisBank,
    required this.buktiPembayaranUrl,
    required this.status,
    required this.currentLevel,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.departement,
    required this.kategoriKeperluan,
    required this.items,
    required this.approvals,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idPocketMoney: json["id_pocket_money"],
    idUser: json["id_user"],
    idDepartement: json["id_departement"],
    idKategoriKeperluan: json["id_kategori_keperluan"],
    tanggal: DateTime.parse(json["tanggal"]),
    keterangan: json["keterangan"],
    totalPengeluaran: json["total_pengeluaran"],
    metodePembayaran: json["metode_pembayaran"],
    nomorRekening: json["nomor_rekening"],
    namaPemilikRekening: json["nama_pemilik_rekening"],
    jenisBank: json["jenis_bank"],
    buktiPembayaranUrl: json["bukti_pembayaran_url"],
    status: json["status"],
    currentLevel: json["current_level"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    departement: Departement.fromJson(json["departement"]),
    kategoriKeperluan: KategoriKeperluan.fromJson(json["kategori_keperluan"]),
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    approvals: List<Approval>.from(
      json["approvals"].map((x) => Approval.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id_pocket_money": idPocketMoney,
    "id_user": idUser,
    "id_departement": idDepartement,
    "id_kategori_keperluan": idKategoriKeperluan,
    "tanggal": tanggal.toIso8601String(),
    "keterangan": keterangan,
    "total_pengeluaran": totalPengeluaran,
    "metode_pembayaran": metodePembayaran,
    "nomor_rekening": nomorRekening,
    "nama_pemilik_rekening": namaPemilikRekening,
    "jenis_bank": jenisBank,
    "bukti_pembayaran_url": buktiPembayaranUrl,
    "status": status,
    "current_level": currentLevel,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "departement": departement.toJson(),
    "kategori_keperluan": kategoriKeperluan.toJson(),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "approvals": List<dynamic>.from(approvals.map((x) => x.toJson())),
  };
}

class Approval {
  String idApprovalPocketMoney;
  String idPocketMoney;
  int level;
  String approverUserId;
  String approverRole;
  String decision;
  DateTime decidedAt;
  String note;
  String buktiApprovalPocketMoneyUrl;
  Approver approver;

  Approval({
    required this.idApprovalPocketMoney,
    required this.idPocketMoney,
    required this.level,
    required this.approverUserId,
    required this.approverRole,
    required this.decision,
    required this.decidedAt,
    required this.note,
    required this.buktiApprovalPocketMoneyUrl,
    required this.approver,
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
    idApprovalPocketMoney: json["id_approval_pocket_money"],
    idPocketMoney: json["id_pocket_money"],
    level: json["level"],
    approverUserId: json["approver_user_id"],
    approverRole: json["approver_role"],
    decision: json["decision"],
    decidedAt: DateTime.parse(json["decided_at"]),
    note: json["note"],
    buktiApprovalPocketMoneyUrl: json["bukti_approval_pocket_money_url"],
    approver: Approver.fromJson(json["approver"]),
  );

  Map<String, dynamic> toJson() => {
    "id_approval_pocket_money": idApprovalPocketMoney,
    "id_pocket_money": idPocketMoney,
    "level": level,
    "approver_user_id": approverUserId,
    "approver_role": approverRole,
    "decision": decision,
    "decided_at": decidedAt.toIso8601String(),
    "note": note,
    "bukti_approval_pocket_money_url": buktiApprovalPocketMoneyUrl,
    "approver": approver.toJson(),
  };
}

class Approver {
  String idUser;
  String namaPengguna;
  String email;
  String role;
  dynamic fotoProfilUser;

  Approver({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    required this.fotoProfilUser,
  });

  factory Approver.fromJson(Map<String, dynamic> json) => Approver(
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

class Item {
  String idPocketMoneyItem;
  String namaItemPocketMoney;
  String harga;

  Item({
    required this.idPocketMoneyItem,
    required this.namaItemPocketMoney,
    required this.harga,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    idPocketMoneyItem: json["id_pocket_money_item"],
    namaItemPocketMoney: json["nama_item_pocket_money"],
    harga: json["harga"],
  );

  Map<String, dynamic> toJson() => {
    "id_pocket_money_item": idPocketMoneyItem,
    "nama_item_pocket_money": namaItemPocketMoney,
    "harga": harga,
  };
}

class KategoriKeperluan {
  String idKategoriKeperluan;
  String namaKeperluan;

  KategoriKeperluan({
    required this.idKategoriKeperluan,
    required this.namaKeperluan,
  });

  factory KategoriKeperluan.fromJson(Map<String, dynamic> json) =>
      KategoriKeperluan(
        idKategoriKeperluan: json["id_kategori_keperluan"],
        namaKeperluan: json["nama_keperluan"],
      );

  Map<String, dynamic> toJson() => {
    "id_kategori_keperluan": idKategoriKeperluan,
    "nama_keperluan": namaKeperluan,
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
