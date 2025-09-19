import 'dart:convert';

ShiftKerja shiftKerjaFromJson(String str) =>
    ShiftKerja.fromJson(json.decode(str));

String shiftKerjaToJson(ShiftKerja data) => json.encode(data.toJson());

class ShiftKerja {
  String message;
  Data data;

  ShiftKerja({required this.message, required this.data});

  factory ShiftKerja.fromJson(Map<String, dynamic> json) =>
      ShiftKerja(message: json["message"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  String idShiftKerja;
  String idUser;
  DateTime tanggalMulai;
  DateTime tanggalSelesai;
  String hariKerja;
  String status;
  String idPolaKerja;
  DateTime createdAt;

  Data({
    required this.idShiftKerja,
    required this.idUser,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.hariKerja,
    required this.status,
    required this.idPolaKerja,
    required this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idShiftKerja: json["id_shift_kerja"],
    idUser: json["id_user"],
    tanggalMulai: DateTime.parse(json["tanggal_mulai"]),
    tanggalSelesai: DateTime.parse(json["tanggal_selesai"]),
    hariKerja: json["hari_kerja"],
    status: json["status"],
    idPolaKerja: json["id_pola_kerja"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id_shift_kerja": idShiftKerja,
    "id_user": idUser,
    "tanggal_mulai": tanggalMulai.toIso8601String(),
    "tanggal_selesai": tanggalSelesai.toIso8601String(),
    "hari_kerja": hariKerja,
    "status": status,
    "id_pola_kerja": idPolaKerja,
    "created_at": createdAt.toIso8601String(),
  };
}
