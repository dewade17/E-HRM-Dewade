import 'dart:convert';

AgendaKerja agendaKerjaFromJson(String str) =>
    AgendaKerja.fromJson(json.decode(str));

String agendaKerjaToJson(AgendaKerja data) => json.encode(data.toJson());

class AgendaKerja {
  bool ok;
  Meta meta;
  List<Data> data;

  AgendaKerja({required this.ok, required this.meta, required this.data});

  factory AgendaKerja.fromJson(Map<String, dynamic> json) => AgendaKerja(
    ok: json["ok"],
    meta: Meta.fromJson(json["meta"]),
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "meta": meta.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Data {
  String idAgendaKerja;
  String idAbsensi;
  String idAgenda;
  String idUser;
  String deskripsiKerja;
  DateTime startDate;
  DateTime endDate;
  int durationSeconds;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  Agenda agenda;
  Absensi absensi;
  User user;

  Data({
    required this.idAgendaKerja,
    required this.idAbsensi,
    required this.idAgenda,
    required this.idUser,
    required this.deskripsiKerja,
    required this.startDate,
    required this.endDate,
    required this.durationSeconds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.agenda,
    required this.absensi,
    required this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idAgendaKerja: json["id_agenda_kerja"],
    idAbsensi: json["id_absensi"],
    idAgenda: json["id_agenda"],
    idUser: json["id_user"],
    deskripsiKerja: json["deskripsi_kerja"],
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    durationSeconds: json["duration_seconds"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    agenda: Agenda.fromJson(json["agenda"]),
    absensi: Absensi.fromJson(json["absensi"]),
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id_agenda_kerja": idAgendaKerja,
    "id_absensi": idAbsensi,
    "id_agenda": idAgenda,
    "id_user": idUser,
    "deskripsi_kerja": deskripsiKerja,
    "start_date": startDate.toIso8601String(),
    "end_date": endDate.toIso8601String(),
    "duration_seconds": durationSeconds,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "agenda": agenda.toJson(),
    "absensi": absensi.toJson(),
    "user": user.toJson(),
  };
}

class Absensi {
  String idAbsensi;
  DateTime tanggal;
  DateTime jamMasuk;
  dynamic jamPulang;

  Absensi({
    required this.idAbsensi,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamPulang,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) => Absensi(
    idAbsensi: json["id_absensi"],
    tanggal: DateTime.parse(json["tanggal"]),
    jamMasuk: DateTime.parse(json["jam_masuk"]),
    jamPulang: json["jam_pulang"],
  );

  Map<String, dynamic> toJson() => {
    "id_absensi": idAbsensi,
    "tanggal": tanggal.toIso8601String(),
    "jam_masuk": jamMasuk.toIso8601String(),
    "jam_pulang": jamPulang,
  };
}

class Agenda {
  String idAgenda;
  String namaAgenda;

  Agenda({required this.idAgenda, required this.namaAgenda});

  factory Agenda.fromJson(Map<String, dynamic> json) =>
      Agenda(idAgenda: json["id_agenda"], namaAgenda: json["nama_agenda"]);

  Map<String, dynamic> toJson() => {
    "id_agenda": idAgenda,
    "nama_agenda": namaAgenda,
  };
}

class User {
  String idUser;
  String namaPengguna;
  String email;
  String role;

  User({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUser: json["id_user"],
    namaPengguna: json["nama_pengguna"],
    email: json["email"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
    "role": role,
  };
}

class Meta {
  int total;
  int limit;
  int offset;
  dynamic nextOffset;

  Meta({
    required this.total,
    required this.limit,
    required this.offset,
    required this.nextOffset,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    total: json["total"],
    limit: json["limit"],
    offset: json["offset"],
    nextOffset: json["nextOffset"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "limit": limit,
    "offset": offset,
    "nextOffset": nextOffset,
  };
}
