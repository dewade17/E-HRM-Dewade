import 'dart:convert';

Map<String, dynamic> _asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

KategoriKunjungan kategoriKunjunganFromJson(String str) =>
    KategoriKunjungan.fromJson(_asJsonMap(json.decode(str)));

String kategoriKunjunganToJson(KategoriKunjungan data) =>
    json.encode(data.toJson());

KategoriKunjunganList kategoriKunjunganListFromJson(String str) =>
    KategoriKunjunganList.fromJson(_asJsonMap(json.decode(str)));

String kategoriKunjunganListToJson(KategoriKunjunganList data) =>
    json.encode(data.toJson());

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

class KategoriKunjungan {
  KategoriKunjungan({required this.message, required this.data});

  final String message;
  final KategoriKunjunganItem data;

  factory KategoriKunjungan.fromJson(Map<String, dynamic> json) {
    return KategoriKunjungan(
      message: json['message'] as String? ?? '',
      data: KategoriKunjunganItem.fromJson(_asJsonMap(json['data'])),
    );
  }

  Map<String, dynamic> toJson() => {'message': message, 'data': data.toJson()};
}

class KategoriKunjunganList {
  KategoriKunjunganList({required this.data, this.pagination, this.message});

  final List<KategoriKunjunganItem> data;
  final Pagination? pagination;
  final String? message;

  factory KategoriKunjunganList.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = <KategoriKunjunganItem>[];

    if (rawData is List) {
      for (final item in rawData) {
        final map = _asJsonMap(item);
        if (map.isEmpty && item is! Map) continue;
        items.add(KategoriKunjunganItem.fromJson(map));
      }
    }

    final paginationRaw = json['pagination'];
    return KategoriKunjunganList(
      data: items,
      pagination: paginationRaw is Map && paginationRaw.isNotEmpty
          ? Pagination.fromJson(_asJsonMap(paginationRaw))
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    if (pagination != null) 'pagination': pagination!.toJson(),
    if (message != null) 'message': message,
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
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    return Pagination(
      page: toInt(json['page'], 1),
      pageSize: toInt(json['pageSize']),
      total: toInt(json['total']),
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

class KategoriKunjunganItem {
  KategoriKunjunganItem({
    required this.idKategoriKunjungan, // DIPERBARUI
    required this.kategoriKunjungan,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String idKategoriKunjungan; // DIPERBARUI
  final String kategoriKunjungan;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory KategoriKunjunganItem.fromJson(Map<String, dynamic> json) {
    return KategoriKunjunganItem(
      // DIPERBARUI: Menggunakan kunci JSON yang benar
      idKategoriKunjungan: (json['id_kategori_kunjungan'] ?? '').toString(),
      kategoriKunjungan: (json['kategori_kunjungan'] ?? '').toString(),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      deletedAt: _parseDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    // DIPERBARUI: Menggunakan kunci JSON yang benar
    'id_kategori_kunjungan': idKategoriKunjungan,
    'kategori_kunjungan': kategoriKunjungan,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
  };
}
