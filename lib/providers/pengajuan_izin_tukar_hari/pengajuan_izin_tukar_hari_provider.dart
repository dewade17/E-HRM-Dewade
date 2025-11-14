import 'dart:convert';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pengajuan_tukar_hari/pengajuan_tukar_hari.dart'
    as dto;
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PengajuanIzinTukarHariProvider extends ChangeNotifier {
  PengajuanIzinTukarHariProvider();

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
  String? kategoriFilter;
  DateTime? pairDate;
  DateTime? pairDateFrom;
  DateTime? pairDateTo;
  String? targetUserId;

  static const Set<String> _validStatuses = <String>{
    'disetujui',
    'ditolak',
    'pending',
  };

  static const Map<String, String> _statusSynonyms = <String, String>{
    'menunggu': 'pending',
  };

  static final RegExp _mentionMarkupRegex = RegExp(
    '[@#]\[__(.*?)__\]\(__(.*?)__\)',
  );

  static final RegExp _uuidRegex = RegExp(
    '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\$',
  );

  bool get saving => _saving;
  String? get saveError => _saveError;
  String? get saveMessage => _saveMessage;

  bool get hasMore {
    final currentMeta = meta;
    if (currentMeta == null) return false;
    return currentMeta.page < currentMeta.totalPages;
  }

  Future<bool> fetch({int? page, int? perPage, bool append = false}) async {
    var requestedPage = page ?? this.page;
    if (requestedPage < 1) {
      requestedPage = 1;
    }

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
      final uri = Uri.parse(Endpoints.pengajuanIzinTukarHari).replace(
        queryParameters: _buildQueryParameters(requestedPage, requestedPerPage),
      );

      final Map<String, dynamic> response = await _api.fetchDataPrivate(
        uri.toString(),
      );

      final List<dto.Data> parsedItems = _parseItems(response['data']);
      final dto.Meta? parsedMeta = _parseMeta(response['meta']);

      if (append) {
        final merged = <String, dto.Data>{
          for (final entry in items) entry.idIzinTukarHari: entry,
        };
        for (final entry in parsedItems) {
          merged[entry.idIzinTukarHari] = entry;
        }
        items = merged.values.toList();
      } else {
        items = parsedItems;
      }

      meta = parsedMeta;
      this.page = parsedMeta?.page ?? requestedPage;
      this.perPage = parsedMeta?.perPage ?? requestedPerPage;

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
          (item) => item.idIzinTukarHari == trimmedId,
        );
        return cached;
      } catch (_) {}
    }

    final uri = Uri.parse(Endpoints.pengajuanIzinTukarHariDetail(trimmedId));

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
    String? kategori,
    DateTime? pairDate,
    DateTime? pairDateFrom,
    DateTime? pairDateTo,
    String? userId,
  }) {
    statusFilter = _normalizeStatus(status);
    kategoriFilter = _normalizeString(kategori);
    this.pairDate = pairDate;
    this.pairDateFrom = pairDateFrom;
    this.pairDateTo = pairDateTo;
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
      kategoriFilter = null;
      pairDate = null;
      pairDateFrom = null;
      pairDateTo = null;
      targetUserId = null;
    }

    notifyListeners();
  }

  void clearSaveState() {
    final shouldNotify = _saving || _saveError != null || _saveMessage != null;
    _saving = false;
    _saveError = null;
    _saveMessage = null;
    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<dto.Data?> createPengajuan({
    required String kategori,
    required String keperluan,
    String? handover,
    Iterable<String>? handoverTagUserIds,
    Iterable<String>? approverUserIds,
    Iterable<Map<String, dynamic>>? pairPayloads,
    Iterable<DateTime>? hariIzinList,
    Iterable<DateTime>? hariPenggantiList,
    ApproversPengajuanProvider? approversProvider,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
  }) async {
    _startSaving();

    final List<_PairPayload> normalizedPairs = _normalizePairPayloads(
      pairPayloads,
      hariIzinList,
      hariPenggantiList,
    );

    if (normalizedPairs.isEmpty) {
      _finishSaving(error: 'Pasangan tanggal tukar hari wajib diisi.');
      return null;
    }

    final payload = <String, dynamic>{
      'kategori': kategori,
      'keperluan': keperluan,
      if (handover != null) 'handover': handover,
    };

    if (additionalFields != null) {
      payload.addAll(additionalFields);
    }

    final List<String> approverIds = _collectApproverIds(
      approverUserIds: approverUserIds,
      approversProvider: approversProvider,
    );

    if (approverIds.isNotEmpty) {
      payload['approvals'] = jsonEncode(
        List<Map<String, dynamic>>.generate(
          approverIds.length,
          (index) => <String, dynamic>{
            'approver_user_id': approverIds[index],
            'level': index + 1,
          },
        ),
      );
      payload.addAll(_buildApprovalFormFields(approverIds));
    }

    final List<String> handoverIds = _resolveHandoverUserIds(
      provided: handoverTagUserIds,
      handover: handover,
    ).toList(growable: false);

    if (handoverIds.isNotEmpty) {
      payload['handover_tag_user_ids'] = jsonEncode(handoverIds);
    }

    payload['pairs'] = jsonEncode(
      normalizedPairs.map((pair) => pair.toJson()).toList(),
    );

    payload['hari_izin'] = jsonEncode(
      normalizedPairs.map((pair) => pair.hariIzin).toList(),
    );
    payload['hari_pengganti'] = jsonEncode(
      normalizedPairs.map((pair) => pair.hariPengganti).toList(),
    );

    final files = <http.MultipartFile>[
      if (lampiran != null) lampiran,
      ..._createMultipartStrings('handover_tag_user_ids', handoverIds),
      ..._createMultipartStrings('handover_tag_user_ids[]', handoverIds),
      ..._createMultipartStrings(
        'hari_izin[]',
        normalizedPairs.map((pair) => pair.hariIzin),
      ),
      ..._createMultipartStrings(
        'hari_pengganti[]',
        normalizedPairs.map((pair) => pair.hariPengganti),
      ),
      ..._createPairMultipartFields(normalizedPairs),
    ];

    try {
      final response = await _api.postFormDataPrivate(
        Endpoints.pengajuanIzinTukarHari,
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
          _extractMessage(response) ??
          'Pengajuan izin tukar hari berhasil dibuat.';
      _finishSaving(message: message);
      return created;
    } catch (e) {
      _finishSaving(error: e.toString());
      return null;
    }
  }

  Future<dto.Data?> updatePengajuan(
    String id, {
    required String kategori,
    required String keperluan,
    String? handover,
    Iterable<String>? handoverTagUserIds,
    Iterable<String>? approverUserIds,
    Iterable<Map<String, dynamic>>? pairPayloads,
    Iterable<DateTime>? hariIzinList,
    Iterable<DateTime>? hariPenggantiList,
    ApproversPengajuanProvider? approversProvider,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
  }) async {
    _startSaving();

    final List<_PairPayload> normalizedPairs = _normalizePairPayloads(
      pairPayloads,
      hariIzinList,
      hariPenggantiList,
    );

    if (normalizedPairs.isEmpty) {
      _finishSaving(error: 'Pasangan tanggal tukar hari wajib diisi.');
      return null;
    }

    final payload = <String, dynamic>{
      'kategori': kategori,
      'keperluan': keperluan,
      if (handover != null) 'handover': handover,
    };

    if (additionalFields != null) {
      payload.addAll(additionalFields);
    }

    final List<String> approverIds = _collectApproverIds(
      approverUserIds: approverUserIds,
      approversProvider: approversProvider,
    );

    if (approverIds.isNotEmpty) {
      payload['approvals'] = jsonEncode(
        List<Map<String, dynamic>>.generate(
          approverIds.length,
          (index) => <String, dynamic>{
            'approver_user_id': approverIds[index],
            'level': index + 1,
          },
        ),
      );
      payload.addAll(_buildApprovalFormFields(approverIds));
    }

    final List<String> handoverIds = _resolveHandoverUserIds(
      provided: handoverTagUserIds,
      handover: handover,
    ).toList(growable: false);

    if (handoverIds.isNotEmpty) {
      payload['handover_tag_user_ids'] = jsonEncode(handoverIds);
    }

    payload['pairs'] = jsonEncode(
      normalizedPairs.map((pair) => pair.toJson()).toList(),
    );
    payload['hari_izin'] = jsonEncode(
      normalizedPairs.map((pair) => pair.hariIzin).toList(),
    );
    payload['hari_pengganti'] = jsonEncode(
      normalizedPairs.map((pair) => pair.hariPengganti).toList(),
    );

    final files = <http.MultipartFile>[
      if (lampiran != null) lampiran,
      ..._createMultipartStrings('handover_tag_user_ids', handoverIds),
      ..._createMultipartStrings('handover_tag_user_ids[]', handoverIds),
      ..._createMultipartStrings(
        'hari_izin[]',
        normalizedPairs.map((pair) => pair.hariIzin),
      ),
      ..._createMultipartStrings(
        'hari_pengganti[]',
        normalizedPairs.map((pair) => pair.hariPengganti),
      ),
      ..._createPairMultipartFields(normalizedPairs),
    ];

    try {
      final response = await _api.putFormDataPrivate(
        Endpoints.pengajuanIzinTukarHariUpdate(id.trim()),
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

      if (parsedMeta != null) {
        meta = parsedMeta;
      }

      if (updated != null) {
        _upsertItem(updated);
      }

      final message =
          _extractMessage(response) ??
          'Pengajuan izin tukar hari berhasil diperbarui.';
      _finishSaving(message: message);
      return updated;
    } catch (e) {
      _finishSaving(error: e.toString());
      return null;
    }
  }

  Future<bool> deletePengajuan(
    String id, {
    Map<String, dynamic>? payload,
  }) async {
    _startSaving();

    try {
      final trimmedId = id.trim();
      if (trimmedId.isEmpty) {
        throw ArgumentError('ID pengajuan tidak boleh kosong.');
      }

      final response = payload != null && payload.isNotEmpty
          ? await _api.deleteWithFormDataPrivate(
              Endpoints.pengajuanIzinTukarHariDelete(trimmedId),
              payload,
            )
          : await _api.deleteDataPrivate(
              Endpoints.pengajuanIzinTukarHariDelete(trimmedId),
            );

      _removeItem(trimmedId);

      final message =
          _extractMessage(response) ??
          'Pengajuan izin tukar hari berhasil dihapus.';
      _finishSaving(message: message);
      return true;
    } catch (e) {
      _finishSaving(error: e.toString());
      return false;
    }
  }

  Map<String, String> _buildQueryParameters(
    int requestedPage,
    int requestedPerPage,
  ) {
    final Map<String, String> params = <String, String>{
      'page': requestedPage.toString(),
      'perPage': requestedPerPage.toString(),
      if (statusFilter != null && statusFilter!.isNotEmpty)
        'status': statusFilter!,
      if (kategoriFilter != null && kategoriFilter!.isNotEmpty)
        'kategori': kategoriFilter!,
      if (targetUserId != null && targetUserId!.isNotEmpty)
        'id_user': targetUserId!,
      if (pairDate != null) 'pair_date': _formatDate(pairDate!),
      if (pairDateFrom != null) 'pair_date_from': _formatDate(pairDateFrom!),
      if (pairDateTo != null) 'pair_date_to': _formatDate(pairDateTo!),
    };
    return params;
  }

  List<dto.Data> _parseItems(dynamic raw) {
    if (raw is List) {
      final List<dto.Data> parsed = <dto.Data>[];
      for (final entry in raw) {
        if (entry == null) continue;
        if (entry is dto.Data) {
          parsed.add(entry);
          continue;
        }

        if (entry is Map<String, dynamic>) {
          parsed.add(dto.Data.fromJson(entry));
          continue;
        }

        if (entry is Map) {
          parsed.add(dto.Data.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
      return parsed;
    }
    return <dto.Data>[];
  }

  dto.Meta? _parseMeta(dynamic raw) {
    if (raw is dto.Meta) return raw;
    if (raw is Map<String, dynamic>) return dto.Meta.fromJson(raw);
    if (raw is Map) {
      return dto.Meta.fromJson(Map<String, dynamic>.from(raw));
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

  List<String> _collectApproverIds({
    Iterable<String>? approverUserIds,
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

    if (approverUserIds != null) {
      for (final id in approverUserIds) {
        add(id);
      }
    }

    return ordered;
  }

  Map<String, String> _buildApprovalFormFields(List<String> approverIds) {
    final Map<String, String> fields = <String, String>{};
    for (var index = 0; index < approverIds.length; index++) {
      final id = approverIds[index];
      fields['approvals[$index][approver_user_id]'] = id;
      fields['approvals[$index][level]'] = '${index + 1}';
    }
    return fields;
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
      for (final match in _mentionMarkupRegex.allMatches(handover)) {
        final String idPart = match.group(2) ?? '';
        final String displayPart = match.group(3) ?? '';
        final String? candidate = _pickBestMentionId(idPart, displayPart);
        if (candidate != null) {
          add(candidate);
        }
      }
    }

    return unique;
  }

  String? _pickBestMentionId(String first, String second) {
    final String a = first.trim().replaceAll(RegExp(r'_'), '');
    final String b = second.trim().replaceAll(RegExp(r'_'), '');

    final bool aIsUuid = _looksLikeUuid(a);
    final bool bIsUuid = _looksLikeUuid(b);

    if (aIsUuid) return a;
    if (bIsUuid) return b;

    if (a.isNotEmpty && !a.contains(' ')) return a;
    if (b.isNotEmpty && !b.contains(' ')) return b;
    if (a.isNotEmpty) return a;
    if (b.isNotEmpty) return b;
    return null;
  }

  bool _looksLikeUuid(String value) {
    return _uuidRegex.hasMatch(value);
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

  List<http.MultipartFile> _createPairMultipartFields(
    List<_PairPayload> pairs,
  ) {
    final files = <http.MultipartFile>[];
    for (var index = 0; index < pairs.length; index++) {
      final pair = pairs[index];
      files.add(
        http.MultipartFile.fromString(
          'pairs[$index][hari_izin]',
          pair.hariIzin,
        ),
      );
      files.add(
        http.MultipartFile.fromString(
          'pairs[$index][hari_pengganti]',
          pair.hariPengganti,
        ),
      );
      if (pair.catatan != null && pair.catatan!.isNotEmpty) {
        files.add(
          http.MultipartFile.fromString(
            'pairs[$index][catatan_pair]',
            pair.catatan!,
          ),
        );
      }
    }
    return files;
  }

  dto.Data? _parseSingleData(dynamic raw) {
    if (raw == null) return null;
    if (raw is dto.Data) return raw;
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('id_izin_tukar_hari')) {
        return dto.Data.fromJson(raw);
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
      (existing) => existing.idIzinTukarHari == item.idIzinTukarHari,
    );
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
  }

  void _removeItem(String id) {
    items.removeWhere((item) => item.idIzinTukarHari == id);
  }

  String? _extractMessage(Map<String, dynamic> response) {
    final dynamic message = response['message'] ?? response['msg'];
    return message is String ? message : null;
  }

  List<_PairPayload> _normalizePairPayloads(
    Iterable<Map<String, dynamic>>? pairPayloads,
    Iterable<DateTime>? hariIzinList,
    Iterable<DateTime>? hariPenggantiList,
  ) {
    final List<_PairPayload> normalized = <_PairPayload>[];

    if (pairPayloads != null) {
      for (final raw in pairPayloads) {
        if (raw.isEmpty) continue;
        final String? izin = _coerceDateString(raw['hari_izin']);
        final String? pengganti = _coerceDateString(raw['hari_pengganti']);
        final String? catatan = _coerceOptionalString(raw['catatan_pair']);
        if (izin == null || pengganti == null) continue;
        normalized.add(_PairPayload(izin, pengganti, catatan));
      }
    }

    final List<DateTime>? izinDates = hariIzinList != null
        ? List<DateTime>.from(hariIzinList)
        : null;
    final List<DateTime>? penggantiDates = hariPenggantiList != null
        ? List<DateTime>.from(hariPenggantiList)
        : null;

    if (normalized.isEmpty && izinDates != null && penggantiDates != null) {
      final count = izinDates.length < penggantiDates.length
          ? izinDates.length
          : penggantiDates.length;
      for (var i = 0; i < count; i++) {
        normalized.add(
          _PairPayload(
            _formatDate(izinDates[i]),
            _formatDate(penggantiDates[i]),
            null,
          ),
        );
      }
    }

    return normalized;
  }

  String? _coerceDateString(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) {
      return _formatDate(value);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return _formatDate(parsed);
      }
      return trimmed;
    }
    return null;
  }

  String? _coerceOptionalString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value.toString();
  }
}

class _PairPayload {
  _PairPayload(this.hariIzin, this.hariPengganti, this.catatan);

  final String hariIzin;
  final String hariPengganti;
  final String? catatan;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'hari_izin': hariIzin,
    'hari_pengganti': hariPengganti,
    if (catatan != null) 'catatan_pair': catatan,
  };
}
