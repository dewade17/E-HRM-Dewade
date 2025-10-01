import 'dart:convert';

Map<String, dynamic> _asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  if (value is num) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    } catch (_) {
      return null;
    }
  }
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String && value.trim().isNotEmpty) {
    return double.tryParse(value.trim());
  }
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String && value.trim().isNotEmpty) {
    return int.tryParse(value.trim());
  }
  return null;
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value.toString();
}

Kunjunganklien kunjunganklienFromJson(String str) =>
    Kunjunganklien.fromJson(_asJsonMap(json.decode(str)));

String kunjunganklienToJson(Kunjunganklien data) => json.encode(data.toJson());

class Kunjunganklien {
  Kunjunganklien({required this.data, this.pagination, this.message});

  final List<Data> data;
  final Pagination? pagination;
  final String? message;

  factory Kunjunganklien.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = <Data>[];
    if (rawData is List) {
      for (final item in rawData) {
        final map = _asJsonMap(item);
        if (map.isEmpty && item is! Map) continue;
        items.add(Data.fromJson(map));
      }
    }

    final paginationRaw = json['pagination'];
    final message = json['message'];

    return Kunjunganklien(
      data: items,
      pagination: paginationRaw is Map && paginationRaw.isNotEmpty
          ? Pagination.fromJson(_asJsonMap(paginationRaw))
          : null,
      message: message is String ? message : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    if (pagination != null) 'pagination': pagination!.toJson(),
    if (message != null) 'message': message,
  };
}

class Data {
  Data({
    required this.idKunjungan,
    required this.idUser,
    required this.statusKunjungan,
    this.idKategoriKunjungan,
    this.tanggal,
    this.jamMulai,
    this.jamSelesai,
    this.deskripsi,
    this.jamCheckin,
    this.jamCheckout,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.lampiranKunjunganUrl,
    this.duration,
    this.handOver,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.kategori,
    List<KunjunganReportRecipient>? reports,
  }) : reports = reports ?? const <KunjunganReportRecipient>[];

  final String idKunjungan;
  final String idUser;
  final String statusKunjungan;
  final String? idKategoriKunjungan;
  final DateTime? tanggal;
  final DateTime? jamMulai;
  final DateTime? jamSelesai;
  final String? deskripsi;
  final DateTime? jamCheckin;
  final DateTime? jamCheckout;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final String? lampiranKunjunganUrl;
  final int? duration;
  final String? handOver;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final Kategori? kategori;
  final List<KunjunganReportRecipient> reports;

  String? get kategoriIdFromRelation => kategori?.idKategoriKunjungan;

  factory Data.fromJson(Map<String, dynamic> json) {
    final kategoriRaw = json['kategori'];
    final reportsRaw = json['reports'];

    return Data(
      idKunjungan: (json['id_kunjungan'] ?? '').toString(),
      idUser: (json['id_user'] ?? '').toString(),
      statusKunjungan: (json['status_kunjungan'] ?? '').toString(),
      idKategoriKunjungan:
          _parseString(json['id_kategori_kunjungan']) ??
          _parseString(json['id_master_data_kunjungan']),
      tanggal: _parseDateTime(json['tanggal']),
      jamMulai: _parseDateTime(json['jam_mulai']),
      jamSelesai: _parseDateTime(json['jam_selesai']),
      deskripsi: _parseString(json['deskripsi']),
      jamCheckin: _parseDateTime(json['jam_checkin']),
      jamCheckout: _parseDateTime(json['jam_checkout']),
      startLatitude: _parseDouble(json['start_latitude']),
      startLongitude: _parseDouble(json['start_longitude']),
      endLatitude: _parseDouble(json['end_latitude']),
      endLongitude: _parseDouble(json['end_longitude']),
      lampiranKunjunganUrl: _parseString(json['lampiran_kunjungan_url']),
      duration: _parseInt(json['duration']),
      handOver: _parseString(json['hand_over']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      deletedAt: _parseDateTime(json['deleted_at']),
      kategori: kategoriRaw is Map && kategoriRaw.isNotEmpty
          ? Kategori.fromJson(_asJsonMap(kategoriRaw))
          : null,
      reports: reportsRaw is List
          ? reportsRaw
                .map(
                  (item) => KunjunganReportRecipient.fromJson(_asJsonMap(item)),
                )
                .toList()
          : const <KunjunganReportRecipient>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'id_kunjungan': idKunjungan,
    'id_user': idUser,
    if (idKategoriKunjungan != null)
      'id_kategori_kunjungan': idKategoriKunjungan,
    if (tanggal != null) 'tanggal': tanggal!.toIso8601String(),
    if (jamMulai != null) 'jam_mulai': jamMulai!.toIso8601String(),
    if (jamSelesai != null) 'jam_selesai': jamSelesai!.toIso8601String(),
    if (deskripsi != null) 'deskripsi': deskripsi,
    if (jamCheckin != null) 'jam_checkin': jamCheckin!.toIso8601String(),
    if (jamCheckout != null) 'jam_checkout': jamCheckout!.toIso8601String(),
    if (startLatitude != null) 'start_latitude': startLatitude,
    if (startLongitude != null) 'start_longitude': startLongitude,
    if (endLatitude != null) 'end_latitude': endLatitude,
    if (endLongitude != null) 'end_longitude': endLongitude,
    if (lampiranKunjunganUrl != null)
      'lampiran_kunjungan_url': lampiranKunjunganUrl,
    'status_kunjungan': statusKunjungan,
    if (duration != null) 'duration': duration,
    if (handOver != null) 'hand_over': handOver,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
    if (kategori != null) 'kategori': kategori!.toJson(),
    'reports': reports.map((item) => item.toJson()).toList(),
  };
}

class Kategori {
  Kategori({this.idKategoriKunjungan, this.kategoriKunjungan});

  final String? idKategoriKunjungan;
  final String? kategoriKunjungan;

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    idKategoriKunjungan:
        _parseString(json['id_kategori_kunjungan']) ??
        _parseString(json['id_master_data_kunjungan']),
    kategoriKunjungan: _parseString(json['kategori_kunjungan']),
  );

  Map<String, dynamic> toJson() => {
    if (idKategoriKunjungan != null)
      'id_kategori_kunjungan': idKategoriKunjungan,
    if (kategoriKunjungan != null) 'kategori_kunjungan': kategoriKunjungan,
  };
}

class KunjunganReportRecipient {
  KunjunganReportRecipient({
    required this.idKunjunganReportRecipient,
    this.idUser,
    this.recipientRoleSnapshot,
    this.catatan,
    this.status,
    this.notifiedAt,
    this.readAt,
    this.actedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String idKunjunganReportRecipient;
  final String? idUser;
  final String? recipientRoleSnapshot;
  final String? catatan;
  final String? status;
  final DateTime? notifiedAt;
  final DateTime? readAt;
  final DateTime? actedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory KunjunganReportRecipient.fromJson(Map<String, dynamic> json) {
    return KunjunganReportRecipient(
      idKunjunganReportRecipient: (json['id_kunjungan_report_recipient'] ?? '')
          .toString(),
      idUser: _parseString(json['id_user']),
      recipientRoleSnapshot: _parseString(json['recipient_role_snapshot']),
      catatan: _parseString(json['catatan']),
      status: _parseString(json['status']),
      notifiedAt: _parseDateTime(json['notified_at']),
      readAt: _parseDateTime(json['read_at']),
      actedAt: _parseDateTime(json['acted_at']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id_kunjungan_report_recipient': idKunjunganReportRecipient,
    if (idUser != null) 'id_user': idUser,
    if (recipientRoleSnapshot != null)
      'recipient_role_snapshot': recipientRoleSnapshot,
    if (catatan != null) 'catatan': catatan,
    if (status != null) 'status': status,
    if (notifiedAt != null) 'notified_at': notifiedAt!.toIso8601String(),
    if (readAt != null) 'read_at': readAt!.toIso8601String(),
    if (actedAt != null) 'acted_at': actedAt!.toIso8601String(),
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}

class Pagination {
  Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, [int fallback = 0]) {
      final parsed = _parseInt(value);
      return parsed ?? fallback;
    }

    return Pagination(
      page: toInt(json['page'], 1),
      pageSize: toInt(json['pageSize'], 10),
      total: toInt(json['total'], 0),
      totalPages: toInt(json['totalPages'], 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'pageSize': pageSize,
    'total': total,
    'totalPages': totalPages,
  };
}
