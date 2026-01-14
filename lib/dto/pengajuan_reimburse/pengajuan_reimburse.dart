import 'dart:convert';

PengajuanReimburse pengajuanReimburseFromJson(String str) =>
    PengajuanReimburse.fromJson(json.decode(str));

String pengajuanReimburseToJson(PengajuanReimburse data) =>
    json.encode(data.toJson());

class PengajuanReimburse {
  bool ok;
  List<Data> data;
  Meta meta;

  PengajuanReimburse({
    required this.ok,
    required this.data,
    required this.meta,
  });

  factory PengajuanReimburse.fromJson(Map<String, dynamic> json) =>
      PengajuanReimburse(
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
  String idReimburse;
  String idUser;
  String idDepartement;
  String idKategoriKeperluan;
  DateTime tanggal;
  String keterangan;
  String totalPengeluaran;
  String metodePembayaran;
  String nomorRekening;
  String namaPemilikRekening;
  String jenisBank;
  String buktiPembayaranUrl;
  String status;
  int currentLevel;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  Departement departement;
  KategoriKeperluan kategoriKeperluan;
  List<Item> items;
  List<Approval> approvals;

  Data({
    required this.idReimburse,
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
    idReimburse: json["id_reimburse"],
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
    "id_reimburse": idReimburse,
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
  String idApprovalReimburse;
  String idReimburse;
  int level;
  String approverUserId;
  String approverRole;
  String decision;
  DateTime decidedAt;
  String note;
  String buktiApprovalReimburseUrl;
  Approver approver;

  Approval({
    required this.idApprovalReimburse,
    required this.idReimburse,
    required this.level,
    required this.approverUserId,
    required this.approverRole,
    required this.decision,
    required this.decidedAt,
    required this.note,
    required this.buktiApprovalReimburseUrl,
    required this.approver,
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
    idApprovalReimburse: json["id_approval_reimburse"],
    idReimburse: json["id_reimburse"],
    level: json["level"],
    approverUserId: json["approver_user_id"],
    approverRole: json["approver_role"],
    decision: json["decision"],
    decidedAt: DateTime.parse(json["decided_at"]),
    note: json["note"],
    buktiApprovalReimburseUrl: json["bukti_approval_reimburse_url"],
    approver: Approver.fromJson(json["approver"]),
  );

  Map<String, dynamic> toJson() => {
    "id_approval_reimburse": idApprovalReimburse,
    "id_reimburse": idReimburse,
    "level": level,
    "approver_user_id": approverUserId,
    "approver_role": approverRole,
    "decision": decision,
    "decided_at": decidedAt.toIso8601String(),
    "note": note,
    "bukti_approval_reimburse_url": buktiApprovalReimburseUrl,
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
  String idReimburseItem;
  String namaItemReimburse;
  String harga;

  Item({
    required this.idReimburseItem,
    required this.namaItemReimburse,
    required this.harga,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    idReimburseItem: json["id_reimburse_item"],
    namaItemReimburse: json["nama_item_reimburse"],
    harga: json["harga"],
  );

  Map<String, dynamic> toJson() => {
    "id_reimburse_item": idReimburseItem,
    "nama_item_reimburse": namaItemReimburse,
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
