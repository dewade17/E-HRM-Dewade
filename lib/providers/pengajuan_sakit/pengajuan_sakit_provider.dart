// lib/providers/pengajuan_sakit/pengajuan_sakit_provider.dart

import 'dart:convert';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/approvers/approvers.dart' as dto_approvers;
import 'package:e_hrm/dto/pengajuan_sakit/pengajuan_sakit.dart' as dto;
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:e_hrm/utils/mention_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PengajuanSakitProvider extends ChangeNotifier {
  PengajuanSakitProvider();

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
  DateTime? tanggalPengajuan;
  DateTime? tanggalPengajuanFrom;
  DateTime? tanggalPengajuanTo;
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
      final uri = Uri.parse(Endpoints.pengajuanSakit).replace(
        queryParameters: _buildQueryParameters(requestedPage, requestedPerPage),
      );

      final Map<String, dynamic> response = await _api.fetchDataPrivate(
        uri.toString(),
      );

      final List<dto.Data> parsedItems = _parseItems(response['data']);
      final dto.Meta? parsedMeta = _parseMeta(response['meta']);

      if (append) {
        final merged = <String, dto.Data>{
          for (final entry in items) entry.idPengajuanIzinSakit: entry,
        };
        for (final entry in parsedItems) {
          merged[entry.idPengajuanIzinSakit] = entry;
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

  Future<dto.Data?> fetchDetail(String id, {bool useCache = true}) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    if (useCache) {
      try {
        final dto.Data cached = items.firstWhere(
          (item) => item.idPengajuanIzinSakit == trimmedId,
        );
        return cached;
      } catch (_) {}
    }

    final uri = Uri.parse(Endpoints.pengajuanSakitDetail(trimmedId));

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
    tanggalPengajuan = tanggal;
    tanggalPengajuanFrom = tanggalFrom;
    tanggalPengajuanTo = tanggalTo;
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
      tanggalPengajuan = null;
      tanggalPengajuanFrom = null;
      tanggalPengajuanTo = null;
      targetUserId = null;
    }

    notifyListeners();
  }

  Future<dto.Data?> createPengajuan({
    required String idKategoriSakit,
    DateTime? tanggalPengajuan,
    String? handover,
    String? status,
    int? currentLevel,
    String? idUser,
    List<String>? handoverUserIds,
    ApproversPengajuanProvider? approversProvider,
    List<Map<String, dynamic>>? approvals,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
  }) async {
    _startSaving();

    final payload = <String, dynamic>{
      'id_kategori_sakit': idKategoriSakit.trim(),
      if (idUser != null && idUser.trim().isNotEmpty) 'id_user': idUser.trim(),
      if (tanggalPengajuan != null)
        'tanggal_pengajuan': _formatDate(tanggalPengajuan),
      if (handover != null && handover.trim().isNotEmpty) 'handover': handover,
    };

    final normalizedStatus = _normalizeStatus(status ?? 'pending');
    if (normalizedStatus != null) {
      payload['status'] = normalizedStatus;
    }

    if (currentLevel != null) {
      payload['current_level'] = currentLevel;
    }

    if (additionalFields != null) {
      payload.addAll(additionalFields);
    }

    // --- [FIX: APPROVALS] ---
    // Menggunakan JSON Encode, bukan field terpisah
    final List<Map<String, dynamic>> approvalList =
        approvals ?? _buildApprovalsFromProvider(approversProvider);

    if (approvalList.isNotEmpty) {
      payload['approvals'] = jsonEncode(approvalList);
    }
    // --- [END FIX] ---

    final List<String> tagUserIds = _resolveHandoverUserIds(
      provided: handoverUserIds,
      handover: handover,
    );

    // Kirim tag_user_ids sebagai multipart string (array)
    final files = <http.MultipartFile>[
      if (lampiran != null) lampiran,
      ..._createMultipartStrings('tag_user_ids', tagUserIds),
      // Opsional: kirim dengan kurung siku jika backend membutuhkannya
      // ..._createMultipartStrings('tag_user_ids[]', tagUserIds),
    ];

    if (kDebugMode) {
      print("--- [DEBUG] CREATE PENGAJUAN SAKIT (FIXED JSON) ---");
      payload.forEach((key, value) => print("$key: $value"));
      print("-------------------------------------------------");
    }

    try {
      final response = await _api.postFormDataPrivate(
        Endpoints.pengajuanSakit,
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
      _applyMeta(parsedMeta);

      if (created != null) {
        _upsertItem(created);
        notifyListeners();
      }

      final message =
          _extractMessage(response) ?? 'Pengajuan izin sakit berhasil dibuat.';
      _finishSaving(message: message);
      return created;
    } catch (e) {
      if (kDebugMode) {
        print("--- [DEBUG] ERROR CREATE ---");
        print(e.toString());
      }
      _finishSaving(error: e.toString());
      return null;
    }
  }

  Future<dto.Data?> updatePengajuan(
    String id, {
    required String idKategoriSakit,
    DateTime? tanggalPengajuan,
    String? handover,
    String? status,
    int? currentLevel,
    String? idUser,
    List<String>? handoverUserIds,
    ApproversPengajuanProvider? approversProvider,
    List<Map<String, dynamic>>? approvals,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
  }) async {
    _startSaving();

    final payload = <String, dynamic>{
      'id_kategori_sakit': idKategoriSakit.trim(),
      if (idUser != null && idUser.trim().isNotEmpty) 'id_user': idUser.trim(),
      if (tanggalPengajuan != null)
        'tanggal_pengajuan': _formatDate(tanggalPengajuan),
      if (handover != null) 'handover': handover,
    };

    final normalizedStatus = _normalizeStatus(status);
    if (normalizedStatus != null) {
      payload['status'] = normalizedStatus;
    }

    if (currentLevel != null) {
      payload['current_level'] = currentLevel;
    }

    if (additionalFields != null) {
      payload.addAll(additionalFields);
    }

    // --- [FIX: APPROVALS] ---
    // Menggunakan JSON Encode
    final List<Map<String, dynamic>> approvalList =
        approvals ?? _buildApprovalsFromProvider(approversProvider);

    if (approvalList.isNotEmpty) {
      payload['approvals'] = jsonEncode(approvalList);
    }
    // --- [END FIX] ---

    final List<String>? tagUserIds = _resolveTagIdsForUpdate(
      provided: handoverUserIds,
      handover: handover,
    );

    final files = <http.MultipartFile>[
      if (lampiran != null) lampiran,
      if (tagUserIds != null)
        ..._createMultipartStrings('tag_user_ids', tagUserIds),
    ];

    if (kDebugMode) {
      print("--- [DEBUG] UPDATE PENGAJUAN SAKIT (FIXED JSON) ---");
      payload.forEach((key, value) => print("$key: $value"));
      print("-------------------------------------------------");
    }

    try {
      final response = await _api.putFormDataPrivate(
        '${Endpoints.pengajuanSakit}/$id',
        payload,
        files: files.isEmpty ? null : files,
      );

      final dto.Data? updated = _parseSingleData(response['data']);
      final dto.Meta? parsedMeta = _parseMeta(
        response['meta'] ??
            (response['data'] is Map<String, dynamic>
                ? (response['data'] as Map<String, dynamic>)['meta']
                : null),
      );
      _applyMeta(parsedMeta);

      if (updated != null) {
        _upsertItem(updated);
        notifyListeners();
      }

      final message =
          _extractMessage(response) ??
          'Pengajuan izin sakit berhasil diperbarui.';
      _finishSaving(message: message);
      return updated;
    } catch (e) {
      if (kDebugMode) {
        print("--- [DEBUG] ERROR UPDATE ---");
        print(e.toString());
      }
      _finishSaving(error: e.toString());
      return null;
    }
  }

  Future<bool> deletePengajuan(String id, {bool hardDelete = false}) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return false;

    try {
      final uri = hardDelete
          ? '${Endpoints.pengajuanSakit}/$trimmedId?hard=1'
          : '${Endpoints.pengajuanSakit}/$trimmedId';
      await _api.deleteDataPrivate(uri);
      _removeItem(trimmedId);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Map<String, String> _buildQueryParameters(
    int requestedPage,
    int requestedPerPage,
  ) {
    final params = <String, String>{
      'page': requestedPage.toString(),
      'pageSize': requestedPerPage.toString(),
      if (statusFilter != null && statusFilter!.isNotEmpty)
        'status': statusFilter!,
      if (keyword != null && keyword!.isNotEmpty) 'q': keyword!,
      if (targetUserId != null && targetUserId!.isNotEmpty)
        'id_user': targetUserId!,
      if (tanggalPengajuan != null)
        'tanggal_pengajuan': _formatDate(tanggalPengajuan!),
      if (tanggalPengajuanFrom != null)
        'tanggal_pengajuan_from': _formatDate(tanggalPengajuanFrom!),
      if (tanggalPengajuanTo != null)
        'tanggal_pengajuan_to': _formatDate(tanggalPengajuanTo!),
    };
    return params;
  }

  List<dto.Data> _parseItems(dynamic raw) {
    if (raw is List) {
      final parsed = <dto.Data>[];
      for (final entry in raw) {
        if (entry == null) continue;
        if (entry is dto.Data) {
          parsed.add(entry);
          continue;
        }
        if (entry is Map<String, dynamic>) {
          try {
            parsed.add(dto.Data.fromJson(entry));
          } catch (e) {
            debugPrint("Failed to parse PengajuanSakit Data: $e. Item: $entry");
          }
          continue;
        }
        if (entry is Map) {
          try {
            parsed.add(dto.Data.fromJson(Map<String, dynamic>.from(entry)));
          } catch (e) {
            debugPrint("Failed to parse PengajuanSakit Data: $e. Item: $entry");
          }
        }
      }
      return parsed;
    }
    return <dto.Data>[];
  }

  dto.Meta? _parseMeta(dynamic raw) {
    if (raw is dto.Meta) return raw;
    if (raw is Map<String, dynamic>) {
      try {
        return dto.Meta.fromJson(raw);
      } catch (e) {
        debugPrint("Failed to parse PengajuanSakit Meta: $e. Item: $raw");
        return null;
      }
    }
    if (raw is Map) {
      try {
        return dto.Meta.fromJson(Map<String, dynamic>.from(raw));
      } catch (e) {
        debugPrint("Failed to parse PengajuanSakit Meta: $e. Item: $raw");
        return null;
      }
    }
    return null;
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
      value.toIso8601String().split('T').first;

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

  void _applyMeta(dto.Meta? parsedMeta) {
    if (parsedMeta == null) return;
    meta = parsedMeta;
    page = parsedMeta.page;
    perPage = parsedMeta.pageSize;
  }

  List<Map<String, dynamic>> _buildApprovalsFromProvider(
    ApproversPengajuanProvider? provider,
  ) {
    if (provider == null) return <Map<String, dynamic>>[];
    final List<dto_approvers.User> selected = provider.selectedUsers
        .where((user) => user.idUser.trim().isNotEmpty)
        .toList(growable: false);
    if (selected.isEmpty) return <Map<String, dynamic>>[];

    return List<Map<String, dynamic>>.generate(selected.length, (index) {
      final dto_approvers.User user = selected[index];
      return <String, dynamic>{
        'approver_user_id': user.idUser,
        'approver_role': user.role.trim().toUpperCase(),
        'level': index + 1,
      };
    });
  }

  List<String> _resolveHandoverUserIds({
    Iterable<String>? provided,
    String? handover,
  }) {
    final ids = <String>{};

    if (provided != null) {
      for (final value in provided) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) continue;
        ids.add(trimmed);
      }
      if (ids.isNotEmpty || handover == null || handover.isEmpty) {
        return ids.toList(growable: false);
      }
    }

    if (handover != null && handover.isNotEmpty) {
      ids.addAll(MentionParser.extractMentionedUserIds(handover));
    }

    return ids.toList(growable: false);
  }

  List<String>? _resolveTagIdsForUpdate({
    Iterable<String>? provided,
    String? handover,
  }) {
    if (provided == null && handover == null) {
      return null;
    }
    return _resolveHandoverUserIds(provided: provided, handover: handover);
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

  dto.Data? _parseSingleData(dynamic raw) {
    if (raw == null) return null;
    if (raw is dto.Data) return raw;
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('id_pengajuan_izin_sakit')) {
        try {
          return dto.Data.fromJson(raw);
        } catch (e) {
          debugPrint("Failed to parse PengajuanSakit Data: $e. Item: $raw");
          return null;
        }
      }
      for (final entry in raw.values) {
        final parsed = _parseSingleData(entry);
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
      (existing) => existing.idPengajuanIzinSakit == item.idPengajuanIzinSakit,
    );
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
  }

  void _removeItem(String id) {
    items.removeWhere((element) => element.idPengajuanIzinSakit == id);
  }

  String? _extractMessage(Map<String, dynamic> response) {
    final dynamic message = response['message'] ?? response['msg'];
    return message is String ? message : null;
  }
}
