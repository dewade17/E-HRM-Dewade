// To parse this JSON data, do
//
//     final shiftKerjaRealTime = shiftKerjaRealTimeFromJson(jsonString);

import 'dart:convert';

ShiftKerjaRealTime shiftKerjaRealTimeFromJson(String str) =>
    ShiftKerjaRealTime.fromJson(json.decode(str));

String shiftKerjaRealTimeToJson(ShiftKerjaRealTime data) =>
    json.encode(data.toJson());

class ShiftKerjaRealTime {
  DateTime date;
  int total;
  List<Data> data;

  ShiftKerjaRealTime({
    required this.date,
    required this.total,
    required this.data,
  });

  factory ShiftKerjaRealTime.fromJson(Map<String, dynamic> json) =>
      ShiftKerjaRealTime(
        date: DateTime.parse(json["date"]),
        total: json["total"],
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "date":
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "total": total,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
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
  DateTime updatedAt;
  dynamic deletedAt;
  User user;
  PolaKerja polaKerja;

  Data({
    required this.idShiftKerja,
    required this.idUser,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.hariKerja,
    required this.status,
    required this.idPolaKerja,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.user,
    required this.polaKerja,
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
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    user: User.fromJson(json["user"]),
    polaKerja: PolaKerja.fromJson(json["polaKerja"]),
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
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "user": user.toJson(),
    "polaKerja": polaKerja.toJson(),
  };
}

class PolaKerja {
  String idPolaKerja;
  String namaPolaKerja;
  DateTime jamMulai;
  DateTime jamSelesai;
  DateTime jamIstirahatMulai;
  DateTime jamIstirahatSelesai;
  int maksJamIstirahat;

  PolaKerja({
    required this.idPolaKerja,
    required this.namaPolaKerja,
    required this.jamMulai,
    required this.jamSelesai,
    required this.jamIstirahatMulai,
    required this.jamIstirahatSelesai,
    required this.maksJamIstirahat,
  });

  factory PolaKerja.fromJson(Map<String, dynamic> json) => PolaKerja(
    idPolaKerja: json["id_pola_kerja"],
    namaPolaKerja: json["nama_pola_kerja"],
    jamMulai: DateTime.parse(json["jam_mulai"]),
    jamSelesai: DateTime.parse(json["jam_selesai"]),
    jamIstirahatMulai: DateTime.parse(json["jam_istirahat_mulai"]),
    jamIstirahatSelesai: DateTime.parse(json["jam_istirahat_selesai"]),
    maksJamIstirahat: json["maks_jam_istirahat"],
  );

  Map<String, dynamic> toJson() => {
    "id_pola_kerja": idPolaKerja,
    "nama_pola_kerja": namaPolaKerja,
    "jam_mulai": jamMulai.toIso8601String(),
    "jam_selesai": jamSelesai.toIso8601String(),
    "jam_istirahat_mulai": jamIstirahatMulai.toIso8601String(),
    "jam_istirahat_selesai": jamIstirahatSelesai.toIso8601String(),
    "maks_jam_istirahat": maksJamIstirahat,
  };
}

class User {
  String idUser;
  String namaPengguna;
  String email;

  User({required this.idUser, required this.namaPengguna, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUser: json["id_user"],
    namaPengguna: json["nama_pengguna"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
  };
}
