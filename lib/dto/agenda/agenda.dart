import 'dart:convert';

AgendaKerja agendaKerjaFromJson(String str) =>
    AgendaKerja.fromJson(json.decode(str) as Map<String, dynamic>);

String agendaKerjaToJson(AgendaKerja data) => json.encode(data.toJson());

class AgendaKerja {
  final bool? ok;
  final Meta? meta;
  final List<Data> data;

  AgendaKerja({this.ok, this.meta, required this.data});

  factory AgendaKerja.fromJson(Map<String, dynamic> json) => AgendaKerja(
    ok: _asBool(json['ok']),
    meta: _parseObject(json['meta'], Meta.fromJson),
    data: (json['data'] as List? ?? const [])
        .map<Data>((dynamic item) => Data.fromJson(_ensureMap(item)))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (ok != null) 'ok': ok,
    if (meta != null) 'meta': meta!.toJson(),
    'data': data.map((x) => x.toJson()).toList(),
  };
}

class Data {
  final String idAgendaKerja;
  final String idAgenda;
  final String idUser;
  final String deskripsiKerja;
  final String status;
  final String? idAbsensi;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? durationSeconds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final Agenda? agenda;
  final Absensi? absensi;
  final User? user;

  Data({
    required this.idAgendaKerja,
    required this.idAgenda,
    required this.idUser,
    required this.deskripsiKerja,
    required this.status,
    this.idAbsensi,
    this.startDate,
    this.endDate,
    this.durationSeconds,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.agenda,
    this.absensi,
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idAgendaKerja: (json['id_agenda_kerja'] ?? json['id']).toString(),
    idAgenda: (json['id_agenda'] ?? '').toString(),
    idUser: (json['id_user'] ?? '').toString(),
    deskripsiKerja: (json['deskripsi_kerja'] ?? '').toString(),
    status: (json['status'] ?? '').toString(),
    idAbsensi: _asString(json['id_absensi']),
    startDate: _parseDateTime(json['start_date']),
    endDate: _parseDateTime(json['end_date']),
    durationSeconds: _asInt(json['duration_seconds']),
    createdAt: _parseDateTime(json['created_at']),
    updatedAt: _parseDateTime(json['updated_at']),
    deletedAt: _parseDateTime(json['deleted_at']),
    agenda: _parseObject(json['agenda'], Agenda.fromJson),
    absensi: _parseObject(json['absensi'], Absensi.fromJson),
    user: _parseObject(json['user'], User.fromJson),
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id_agenda_kerja': idAgendaKerja,
      'id_absensi': idAbsensi,
      'id_agenda': idAgenda,
      'id_user': idUser,
      'deskripsi_kerja': deskripsiKerja,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
    if (agenda != null) map['agenda'] = agenda!.toJson();
    if (absensi != null) map['absensi'] = absensi!.toJson();
    if (user != null) map['user'] = user!.toJson();
    return map;
  }
}

class Absensi {
  final String idAbsensi;
  final DateTime? tanggal;
  final String? jamMasuk;
  final String? jamPulang;

  Absensi({
    required this.idAbsensi,
    this.tanggal,
    this.jamMasuk,
    this.jamPulang,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) => Absensi(
    idAbsensi: (json['id_absensi'] ?? '').toString(),
    tanggal: _parseDateTime(json['tanggal']),
    jamMasuk: _asString(json['jam_masuk']),
    jamPulang: _asString(json['jam_pulang']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id_absensi': idAbsensi,
    if (tanggal != null) 'tanggal': tanggal!.toIso8601String(),
    if (jamMasuk != null) 'jam_masuk': jamMasuk,
    if (jamPulang != null) 'jam_pulang': jamPulang,
  };
}

class Agenda {
  final String idAgenda;
  final String? namaAgenda;

  Agenda({required this.idAgenda, this.namaAgenda});

  factory Agenda.fromJson(Map<String, dynamic> json) => Agenda(
    idAgenda: (json['id_agenda'] ?? '').toString(),
    namaAgenda: _asString(json['nama_agenda']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id_agenda': idAgenda,
    if (namaAgenda != null) 'nama_agenda': namaAgenda,
  };
}

class User {
  final String idUser;
  final String? namaPengguna;
  final String? email;
  final String? role;

  User({required this.idUser, this.namaPengguna, this.email, this.role});

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUser: (json['id_user'] ?? '').toString(),
    namaPengguna: _asString(json['nama_pengguna']),
    email: _asString(json['email']),
    role: _asString(json['role']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id_user': idUser,
    if (namaPengguna != null) 'nama_pengguna': namaPengguna,
    if (email != null) 'email': email,
    if (role != null) 'role': role,
  };
}

class Meta {
  int? total;
  int? limit;
  int? offset;
  dynamic nextOffset;
  int? page;
  int? perPage;
  int? totalPages;

  Meta({
    this.total,
    this.limit,
    this.offset,
    this.nextOffset,
    this.page,
    this.perPage,
    this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    total: _asInt(json['total']),
    limit: _asInt(json['limit']),
    offset: _asInt(json['offset']),
    nextOffset: json.containsKey('nextOffset')
        ? json['nextOffset']
        : json['next_offset'],
    page: _asInt(json['page']),
    perPage: _asInt(json['perPage'] ?? json['per_page']),
    totalPages: _asInt(json['totalPages'] ?? json['total_pages']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (total != null) 'total': total,
    if (limit != null) 'limit': limit,
    if (offset != null) 'offset': offset,
    if (nextOffset != null) 'nextOffset': nextOffset,
    if (page != null) 'page': page,
    if (perPage != null) 'perPage': perPage,
    if (totalPages != null) 'totalPages': totalPages,
  };
}

T? _parseObject<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value == null) return null;
  if (value is T) return value;
  return parser(_ensureMap(value));
}

Map<String, dynamic> _ensureMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String? _asString(dynamic value) => value == null ? null : value.toString();

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
