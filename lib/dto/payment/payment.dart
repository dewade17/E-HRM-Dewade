import 'dart:convert';

Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));

String paymentToJson(Payment data) => json.encode(data.toJson());

class Payment {
  bool ok;
  List<Data> data;
  Meta meta;

  Payment({required this.ok, required this.data, required this.meta});

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
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
  String idPayment;
  String idUser;
  String idDepartement;
  String idKategoriKeperluan;
  DateTime tanggal;
  String keterangan;
  String nominalPembayaran;
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
  List<Approval> approvals;

  Data({
    required this.idPayment,
    required this.idUser,
    required this.idDepartement,
    required this.idKategoriKeperluan,
    required this.tanggal,
    required this.keterangan,
    required this.nominalPembayaran,
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
    required this.approvals,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idPayment: json["id_payment"],
    idUser: json["id_user"],
    idDepartement: json["id_departement"],
    idKategoriKeperluan: json["id_kategori_keperluan"],
    tanggal: DateTime.parse(json["tanggal"]),
    keterangan: json["keterangan"],
    nominalPembayaran: json["nominal_pembayaran"],
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
    approvals: List<Approval>.from(
      json["approvals"].map((x) => Approval.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id_payment": idPayment,
    "id_user": idUser,
    "id_departement": idDepartement,
    "id_kategori_keperluan": idKategoriKeperluan,
    "tanggal": tanggal.toIso8601String(),
    "keterangan": keterangan,
    "nominal_pembayaran": nominalPembayaran,
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
    "approvals": List<dynamic>.from(approvals.map((x) => x.toJson())),
  };
}

class Approval {
  String idApprovalPayment;
  String idPayment;
  int level;
  String approverUserId;
  String approverRole;
  String decision;
  DateTime decidedAt;
  String note;
  String buktiApprovalPaymentUrl;
  Approver approver;

  Approval({
    required this.idApprovalPayment,
    required this.idPayment,
    required this.level,
    required this.approverUserId,
    required this.approverRole,
    required this.decision,
    required this.decidedAt,
    required this.note,
    required this.buktiApprovalPaymentUrl,
    required this.approver,
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
    idApprovalPayment: json["id_approval_payment"],
    idPayment: json["id_payment"],
    level: json["level"],
    approverUserId: json["approver_user_id"],
    approverRole: json["approver_role"],
    decision: json["decision"],
    decidedAt: DateTime.parse(json["decided_at"]),
    note: json["note"],
    buktiApprovalPaymentUrl: json["bukti_approval_payment_url"],
    approver: Approver.fromJson(json["approver"]),
  );

  Map<String, dynamic> toJson() => {
    "id_approval_payment": idApprovalPayment,
    "id_payment": idPayment,
    "level": level,
    "approver_user_id": approverUserId,
    "approver_role": approverRole,
    "decision": decision,
    "decided_at": decidedAt.toIso8601String(),
    "note": note,
    "bukti_approval_payment_url": buktiApprovalPaymentUrl,
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
