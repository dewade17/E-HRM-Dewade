import 'dart:convert';

import 'package:e_hrm/dto/agenda_kerja/agenda_kerja.dart' show Meta;

export 'package:e_hrm/dto/agenda_kerja/agenda_kerja.dart' show Meta;

AgendaList agendaListFromJson(String str) =>
    AgendaList.fromJson(json.decode(str) as Map<String, dynamic>);

String agendaListToJson(AgendaList data) => json.encode(data.toJson());

class AgendaList {
  final bool? ok;
  final Meta? meta;
  final List<AgendaItem> data;

  AgendaList({this.ok, this.meta, required this.data});

  factory AgendaList.fromJson(Map<String, dynamic> json) => AgendaList(
    ok: _asBool(json['ok']),
    meta: _parseMeta(json['meta']),
    data: (json['data'] as List? ?? const [])
        .map<AgendaItem>(
          (dynamic item) => AgendaItem.fromJson(_ensureMap(item)),
        )
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (ok != null) 'ok': ok,
    if (meta != null) 'meta': meta!.toJson(),
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class AgendaItem {
  final String idAgenda;
  final String? namaAgenda;
  final String? deskripsi;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AgendaItem({
    required this.idAgenda,
    this.namaAgenda,
    this.deskripsi,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AgendaItem.fromJson(Map<String, dynamic> json) => AgendaItem(
    idAgenda: (json['id_agenda'] ?? json['id'] ?? '').toString(),
    namaAgenda: _asString(json['nama_agenda'] ?? json['nama']),
    deskripsi: _asString(
      json['deskripsi_agenda'] ?? json['deskripsi'] ?? json['keterangan'],
    ),
    status: _asString(json['status']),
    createdAt: _parseDateTime(json['created_at']),
    updatedAt: _parseDateTime(json['updated_at']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id_agenda': idAgenda,
    if (namaAgenda != null) 'nama_agenda': namaAgenda,
    if (deskripsi != null) 'deskripsi_agenda': deskripsi,
    if (status != null) 'status': status,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}

Meta? _parseMeta(dynamic value) {
  if (value is Meta) return value;
  if (value is Map<String, dynamic>) return Meta.fromJson(value);
  if (value is Map) return Meta.fromJson(Map<String, dynamic>.from(value));
  return null;
}

Map<String, dynamic> _ensureMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String? _asString(dynamic value) => value?.toString();

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
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
