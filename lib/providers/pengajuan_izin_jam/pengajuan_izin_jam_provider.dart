// lib/providers/pengajuan_izin_jam/pengajuan_izin_jam_provider.dart

import 'dart:convert';
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pengajuan_izin_jam/pengajuan_izin_jam.dart' as dto;
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:e_hrm/utils/mention_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:e_hrm/dto/approvers/approvers.dart' as dto_approvers;

class PengajuanIzinJamProvider extends ChangeNotifier {
  PengajuanIzinJamProvider();

  final ApiService _api = ApiService();

  bool loading = false;
  String? error;

  bool _saving = false;
  String? _saveError;
  String? _saveMessage;

  List<dto.Data> items = <dto.Data>[];
  dto.Meta? meta;

  int page = 1;
  int perPage = 20;

  String? statusFilter;
  String? keyword;
  DateTime? tanggal;
  DateTime? tanggalFrom;
  DateTime? tanggalTo;
  String? targetUserId;

  static const Set<String> _validStatuses = <String>{
    'disetujui',
    'ditolak',
    'pending',
  };

  static const Map<String, String> _statusSynonyms = <String, String>{
    'menunggu': 'pending',
  };

  bool get hasMore {
    final currentMeta = meta;
    if (currentMeta == null) return false;
    return currentMeta.page < currentMeta.totalPages;
  }

  bool get saving => _saving;
  String? get saveError => _saveError;
  String? get saveMessage => _saveMessage;

  Future<bool> fetch({int? page, int? perPage, bool append = false}) async {
    var requestedPage = page ?? this.page;
    if (requestedPage < 1) requestedPage = 1;

    var requestedPerPage = perPage ?? this.perPage;
    if (requestedPerPage < 1) {
      requestedPerPage = 1;
    } else if (requestedPerPage > 100) {
      requestedPerPage = 100;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(Endpoints.pengajuanIzinJam).replace(
        queryParameters: _buildQueryParameters(requestedPage, requestedPerPage),
      );

      final Map<String, dynamic> response = await _api.fetchDataPrivate(
        uri.toString(),
      );

      final List<dto.Data> parsedItems = _parseItems(response['data']);
      final dto.Meta? parsedMeta = _parseMeta(response['meta']);

      if (append) {
        final merged = <String, dto.Data>{
          for (final entry in items) entry.idPengajuanIzinJam: entry,
        };
        for (final entry in parsedItems) {
          merged[entry.idPengajuanIzinJam] = entry;
        }
        items = merged.values.toList();
      } else {
        items = parsedItems;
      }

      meta = parsedMeta;
      this.page = parsedMeta?.page ?? requestedPage;
      this.perPage = parsedMeta?.pageSize ?? requestedPerPage;

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<dto.Data?> createPengajuan({
    required String idKategoriIzinJam,
    required String keperluan,
    required DateTime tanggalIzin,
    required DateTime jamMulai,
    required DateTime jamSelesai,
    required DateTime tanggalPengganti,
    required DateTime jamMulaiPengganti,
    required DateTime jamSelesaiPengganti,
    String? handover,
    List<String>? handoverUserIds,
    List<String>? supervisorIds,
    ApproversPengajuanProvider? approversProvider,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
    String supervisorsFieldName = 'recipient',
  }) async {
    _startSaving();

    final payload = <String, dynamic>{
      'id_kategori_izin_jam': idKategoriIzinJam,
      'keperluan': keperluan,
      'tanggal_izin': _formatDate(tanggalIzin),
      'jam_mulai': _formatDateTime(jamMulai),
      'jam_selesai': _formatDateTime(jamSelesai),
      'tanggal_pengganti': _formatDate(tanggalPengganti),
      'jam_mulai_pengganti': _formatDateTime(jamMulaiPengganti),
      'jam_selesai_pengganti': _formatDateTime(jamSelesaiPengganti),
      if (handover != null && handover.isNotEmpty) 'handover': handover,
    };

    if (additionalFields != null) {
      payload.addAll(additionalFields);
    }

    final List<String> approverIds = _collectApproverIds(
      supervisorIds: supervisorIds,
      approversProvider: approversProvider,
    );

    if (approverIds.isNotEmpty) {
      payload['recipient_ids'] = jsonEncode(approverIds);
    }

    final List<dto_approvers.User> approvers =
        (approversProvider?.selectedUsers ?? [])
            .where((user) => user.idUser.trim().isNotEmpty)
            .toList(growable: false);

    if (approvers.isNotEmpty) {
      payload['approvals'] = jsonEncode(
        List<Map<String, dynamic>>.generate(
          approvers.length,
          (index) => <String, dynamic>{
            'approver_user_id': approvers[index].idUser,
            'level': index + 1,
            'approver_role': approvers[index].role.trim().toUpperCase(),
          },
        ),
      );
    }

    final List<String> handoverIds = _resolveHandoverUserIds(
      provided: handoverUserIds,
      handover: handover,
    ).toList(growable: false);

    // [PERBAIKAN 1]: Hapus pengiriman 'tag_user_ids' dalam payload JSON
    // if (handoverIds.isNotEmpty) {
    //   payload['tag_user_ids'] = jsonEncode(handoverIds);
    // }

    final files = <http.MultipartFile>[
      if (lampiran != null) lampiran,
      // [PERBAIKAN 2]: HANYA kirim field 'tag_user_ids' (backend akan handle array)
      ..._createMultipartStrings('tag_user_ids', handoverIds),
      // [PERBAIKAN 3]: Hapus field 'tag_user_ids[]'
      // ..._createMultipartStrings('tag_user_ids[]', handoverIds),
    ];

    // --- TAMBAHAN DEBUG PRINT ---
    if (kDebugMode) {
      print("--- [DEBUG] CREATE PENGAJUAN IZIN JAM (Telah Diperbaiki) ---");
      print("Endpoint: ${Endpoints.pengajuanIzinJam}");
      print("--- Payload Fields ---");
      payload.forEach((key, value) {
        print("$key: $value");
      });
      print("--- Multipart Files ---");
      if (files.isEmpty) {
        print("(Tidak ada file)");
      } else {
        for (var file in files) {
          if (file.filename != null) {
            print(
              "File: ${file.field} (name: ${file.filename}, size: ${file.length}, type: ${file.contentType})",
            );
          } else {
            // Untuk file 'tag_user_ids', kita print manual agar terlihat
            if (file.field == 'tag_user_ids') {
              print(
                "Field (from string): ${file.field} (ID terkirim: ${handoverIds.join(', ')})",
              );
            } else {
              print("Field (from string): ${file.field}");
            }
          }
        }
      }
      print("--------------------------------------");
    }
    // --- AKHIR TAMBAHAN DEBUG PRINT ---

    try {
      final response = await _api.postFormDataPrivate(
        Endpoints.pengajuanIzinJam,
        payload,
        files: files.isEmpty ? null : files,
      );

      final dto.Data? created = _parseSingleData(response['data']);
      final dto.Meta? parsedMeta = _parseMeta(
        response['meta'] ??
            (response['data'] is Map<String, dynamic>
                ? (response['data'] as Map<String, dynamic>)['meta']
                : null),
      );

      if (parsedMeta != null) {
        meta = parsedMeta;
      }

      if (created != null) {
        _upsertItem(created);
      }

      final message =
          _extractMessage(response) ?? 'Pengajuan izin jam berhasil dibuat.';
      _finishSaving(message: message);
      return created;
    } catch (e) {
      _finishSaving(error: e.toString());
      return null;
    }
  }

  Future<dto.Data?> fetchDetail(String id, {bool useCache = true}) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    if (useCache) {
      try {
        final dto.Data cached = items.firstWhere(
          (item) => item.idPengajuanIzinJam == trimmedId,
        );
        return cached;
      } catch (_) {}
    }

    final uri = Uri.parse(Endpoints.pengajuanIzinJamDetail(trimmedId));

    final Map<String, dynamic> response = await _api.fetchDataPrivate(
      uri.toString(),
    );

    final dto.Data? parsed = _parseSingleData(response['data']);
    if (parsed != null) {
      _upsertItem(parsed);
      notifyListeners();
    }
    return parsed;
  }

  Future<bool> loadMore() {
    if (loading) return Future<bool>.value(false);
    final currentMeta = meta;
    if (currentMeta != null && currentMeta.page >= currentMeta.totalPages) {
      return Future<bool>.value(false);
    }

    final nextPage = (currentMeta?.page ?? page) + 1;
    return fetch(page: nextPage, perPage: perPage, append: true);
  }

  Future<bool> refresh() {
    return fetch(page: 1, perPage: perPage, append: false);
  }

  Future<bool> applyFilters({
    String? status,
    String? keyword,
    DateTime? tanggal,
    DateTime? tanggalFrom,
    DateTime? tanggalTo,
    String? userId,
  }) {
    statusFilter = _normalizeStatus(status);
    this.keyword = _normalizeString(keyword);
    this.tanggal = tanggal;
    this.tanggalFrom = tanggalFrom;
    this.tanggalTo = tanggalTo;
    targetUserId = _normalizeString(userId);
    return fetch(page: 1, perPage: perPage, append: false);
  }

  void reset({bool keepFilters = false}) {
    loading = false;
    error = null;
    items = <dto.Data>[];
    meta = null;
    page = 1;
    perPage = 20;

    if (!keepFilters) {
      statusFilter = null;
      keyword = null;
      tanggal = null;
      tanggalFrom = null;
      tanggalTo = null;
      targetUserId = null;
    }

    notifyListeners();
  }

  Map<String, String> _buildQueryParameters(int page, int perPage) {
    final Map<String, String> params = <String, String>{
      'page': '$page',
      'pageSize': '$perPage',
    };

    final status = statusFilter;
    if (status != null) {
      params['status'] = status;
    }

    final userId = targetUserId;
    if (userId != null && userId.isNotEmpty) {
      params['id_user'] = userId;
    }

    final keyword = this.keyword;
    if (keyword != null && keyword.isNotEmpty) {
      params['q'] = keyword;
    }

    final tanggal = this.tanggal;
    if (tanggal != null) {
      params['tanggal'] = _formatDate(tanggal);
    } else {
      final from = tanggalFrom;
      final to = tanggalTo;
      if (from != null) {
        params['from'] = _formatDate(from);
      }
      if (to != null) {
        params['to'] = _formatDate(to);
      }
    }

    return params;
  }

  List<dto.Data> _parseItems(dynamic raw) {
    if (raw == null) return <dto.Data>[];
    if (raw is dto.Data) return <dto.Data>[raw];
    if (raw is List) {
      return raw
          .map((item) => _parseSingleData(item))
          .whereType<dto.Data>()
          .toList();
    }
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data')) {
        return _parseItems(raw['data']);
      }
      if (raw.containsKey('id_pengajuan_izin_jam')) {
        final parsed = dto.Data.fromJson(raw);
        return <dto.Data>[parsed];
      }
      final List<dto.Data> items = <dto.Data>[];
      for (final entry in raw.values) {
        items.addAll(_parseItems(entry));
      }
      return items;
    }
    if (raw is Map) {
      return _parseItems(Map<String, dynamic>.from(raw));
    }
    return <dto.Data>[];
  }

  dto.Meta? _parseMeta(dynamic raw) {
    if (raw == null) return null;
    if (raw is dto.Meta) return raw;
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('page') && raw.containsKey('pageSize')) {
        return dto.Meta.fromJson(raw);
      }
      if (raw.containsKey('meta')) {
        return _parseMeta(raw['meta']);
      }
    }
    if (raw is Map) {
      return _parseMeta(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  dto.Data? _parseSingleData(dynamic raw) {
    if (raw == null) return null;
    if (raw is dto.Data) return raw;
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('id_pengajuan_izin_jam')) {
        return dto.Data.fromJson(raw);
      }
      if (raw.containsKey('data')) {
        return _parseSingleData(raw['data']);
      }
      for (final value in raw.values) {
        final parsed = _parseSingleData(value);
        if (parsed != null) return parsed;
      }
    }
    if (raw is Map) {
      return _parseSingleData(Map<String, dynamic>.from(raw));
    }
    if (raw is List) {
      for (final entry in raw) {
        final parsed = _parseSingleData(entry);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  void _upsertItem(dto.Data item) {
    final index = items.indexWhere(
      (existing) => existing.idPengajuanIzinJam == item.idPengajuanIzinJam,
    );
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
  }

  String? _normalizeStatus(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    final candidate = _statusSynonyms[trimmed] ?? trimmed;
    return _validStatuses.contains(candidate) ? candidate : null;
  }

  String? _normalizeString(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String _formatDate(DateTime value) =>
      value.toLocal().toIso8601String().split('T').first;

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final datePart = _formatDate(local);
    final hh = _twoDigits(local.hour);
    final mm = _twoDigits(local.minute);
    final ss = _twoDigits(local.second);
    return '$datePart $hh:$mm:$ss';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  void _startSaving() {
    _saving = true;
    _saveError = null;
    _saveMessage = null;
    notifyListeners();
  }

  void _finishSaving({String? message, String? error}) {
    _saving = false;
    _saveMessage = message;
    _saveError = error;
    notifyListeners();
  }

  List<String> _collectApproverIds({
    List<String>? supervisorIds,
    ApproversPengajuanProvider? approversProvider,
  }) {
    final List<String> ordered = <String>[];
    final Set<String> seen = <String>{};

    void add(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return;
      if (seen.add(trimmed)) {
        ordered.add(trimmed);
      }
    }

    if (approversProvider != null) {
      for (final id in approversProvider.selectedRecipientIds) {
        add(id);
      }
    }

    if (supervisorIds != null) {
      for (final id in supervisorIds) {
        add(id);
      }
    }

    return ordered;
  }

  Iterable<String> _resolveHandoverUserIds({
    Iterable<String>? provided,
    String? handover,
  }) {
    final Set<String> unique = <String>{};

    void add(String? raw) {
      final trimmed = raw?.trim();
      if (trimmed == null || trimmed.isEmpty) return;
      unique.add(trimmed);
    }

    if (provided != null) {
      for (final value in provided) {
        add(value);
      }
      if (unique.isNotEmpty) {
        return unique;
      }
    }

    if (handover != null && handover.isNotEmpty) {
      for (final id in MentionParser.extractMentionedUserIds(handover)) {
        add(id);
      }
    }

    return unique;
  }

  List<http.MultipartFile> _createMultipartStrings(
    String fieldName,
    Iterable<String> values,
  ) {
    final files = <http.MultipartFile>[];
    for (final value in values) {
      files.add(http.MultipartFile.fromString(fieldName, value));
    }
    return files;
  }

  String? _extractMessage(Map<String, dynamic> response) {
    final dynamic message = response['message'] ?? response['msg'];
    return message is String ? message : null;
  }
}
