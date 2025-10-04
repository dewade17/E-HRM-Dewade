import 'dart:convert';

ShiftKerjaRealTime shiftKerjaRealTimeFromJson(String source) =>
    ShiftKerjaRealTime.fromJson(json.decode(source));

String shiftKerjaRealTimeToJson(ShiftKerjaRealTime data) =>
    json.encode(data.toJson());

class ShiftKerjaRealTime {
  ShiftKerjaRealTime({
    required this.date,
    required this.total,
    required this.data,
  });

  final DateTime date;
  final int total;
  final List<Data> data;

  factory ShiftKerjaRealTime.fromJson(Map<String, dynamic> json) {
    final parsedDate = _parseDateTime(json['date']);
    if (parsedDate == null) {
      throw const FormatException('Tanggal respons shift kerja tidak valid.');
    }

    return ShiftKerjaRealTime(
      date: parsedDate,
      total: (json['total'] as num?)?.toInt() ?? 0,
      data: _parseDataList(json['data']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': _formatDateOnly(date),
    'total': total,
    'data': data.map((Data e) => e.toJson()).toList(),
  };
}

class Data {
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

  final String idShiftKerja;
  final String idUser;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final List<String>? hariKerja;
  final String status;
  final String? idPolaKerja;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final User? user;
  final PolaKerja? polaKerja;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idShiftKerja: _string(json['id_shift_kerja']),
    idUser: _string(json['id_user']),
    tanggalMulai: _parseDateTime(json['tanggal_mulai']),
    tanggalSelesai: _parseDateTime(json['tanggal_selesai']),
    hariKerja: _parseHariKerja(json['hari_kerja']),
    status: _string(json['status']),
    idPolaKerja: _stringOrNull(json['id_pola_kerja']),
    createdAt: _parseDateTime(json['created_at']),
    updatedAt: _parseDateTime(json['updated_at']),
    deletedAt: _parseDateTime(json['deleted_at']),
    user: _parseUser(json['user']),
    polaKerja: _parsePolaKerja(json['polaKerja'] ?? json['pola_kerja']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id_shift_kerja': idShiftKerja,
    'id_user': idUser,
    'tanggal_mulai': tanggalMulai?.toIso8601String(),
    'tanggal_selesai': tanggalSelesai?.toIso8601String(),
    'hari_kerja': hariKerja?.toList(),
    'status': status,
    'id_pola_kerja': idPolaKerja,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'user': user?.toJson(),
    'polaKerja': polaKerja?.toJson(),
  };
}

class PolaKerja {
  PolaKerja({
    required this.idPolaKerja,
    required this.namaPolaKerja,
    required this.jamMulai,
    required this.jamSelesai,
    required this.jamIstirahatMulai,
    required this.jamIstirahatSelesai,
    required this.maksJamIstirahat,
  });

  final String idPolaKerja;
  final String namaPolaKerja;
  final String? jamMulai;
  final String? jamSelesai;
  final String? jamIstirahatMulai;
  final String? jamIstirahatSelesai;
  final int? maksJamIstirahat;

  factory PolaKerja.fromJson(Map<String, dynamic> json) => PolaKerja(
    idPolaKerja: _string(json['id_pola_kerja']),
    namaPolaKerja: _string(json['nama_pola_kerja']),
    jamMulai: _stringOrNull(json['jam_mulai']),
    jamSelesai: _stringOrNull(json['jam_selesai']),
    jamIstirahatMulai: _stringOrNull(json['jam_istirahat_mulai']),
    jamIstirahatSelesai: _stringOrNull(json['jam_istirahat_selesai']),
    maksJamIstirahat: _parseInt(json['maks_jam_istirahat']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id_pola_kerja': idPolaKerja,
    'nama_pola_kerja': namaPolaKerja,
    'jam_mulai': jamMulai,
    'jam_selesai': jamSelesai,
    'jam_istirahat_mulai': jamIstirahatMulai,
    'jam_istirahat_selesai': jamIstirahatSelesai,
    'maks_jam_istirahat': maksJamIstirahat,
  };
}

class User {
  User({required this.idUser, required this.namaPengguna, required this.email});

  final String idUser;
  final String namaPengguna;
  final String? email;

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUser: _string(json['id_user']),
    namaPengguna: _string(json['nama_pengguna']),
    email: _stringOrNull(json['email']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id_user': idUser,
    'nama_pengguna': namaPengguna,
    'email': email,
  };
}

List<Data> _parseDataList(dynamic raw) {
  if (raw is List) {
    final List<Data> parsed = <Data>[];
    for (final dynamic item in raw) {
      if (item is Data) {
        parsed.add(item);
      } else if (item is Map<String, dynamic>) {
        parsed.add(Data.fromJson(item));
      } else if (item is Map) {
        parsed.add(Data.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return parsed;
  }
  return const <Data>[];
}

User? _parseUser(dynamic raw) {
  if (raw is User) return raw;
  if (raw is Map<String, dynamic>) return User.fromJson(raw);
  if (raw is Map) return User.fromJson(Map<String, dynamic>.from(raw));
  return null;
}

PolaKerja? _parsePolaKerja(dynamic raw) {
  if (raw is PolaKerja) return raw;
  if (raw is Map<String, dynamic>) return PolaKerja.fromJson(raw);
  if (raw is Map) return PolaKerja.fromJson(Map<String, dynamic>.from(raw));
  return null;
}

List<String>? _parseHariKerja(dynamic raw) {
  if (raw == null) return null;
  if (raw is List) {
    return raw.map((dynamic e) => e.toString()).toList();
  }
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.split(',').map((String e) => e.trim()).toList();
  }
  return null;
}

DateTime? _parseDateTime(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  final value = raw.toString().trim();
  if (value.isEmpty) return null;
  return DateTime.tryParse(value);
}

int? _parseInt(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw.toString());
}

String _string(dynamic raw, [String fallback = '']) {
  if (raw == null) return fallback;
  final value = raw.toString();
  return value.isEmpty ? fallback : value;
}

String? _stringOrNull(dynamic raw) {
  if (raw == null) return null;
  final value = raw.toString().trim();
  return value.isEmpty ? null : value;
}

String _formatDateOnly(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
