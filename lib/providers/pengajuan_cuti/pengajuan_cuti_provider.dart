import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as dto;
import 'package:e_hrm/services/api_services.dart';
import 'package:http/http.dart' as http;

class PengajuanCutiProvider extends ChangeNotifier {
  PengajuanCutiProvider();

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
  DateTime? tanggalCuti;
  DateTime? tanggalCutiFrom;
  DateTime? tanggalCutiTo;
  DateTime? tanggalMasukKerja;
  DateTime? tanggalMasukKerjaFrom;
  DateTime? tanggalMasukKerjaTo;
  String? targetUserId;

  static const Set<String> _validStatuses = <String>{
    'disetujui',
    'ditolak',
    'pending',
  };

  static final RegExp _mentionMarkupRegex = RegExp(
    '[@#]\\[__(.*?)__\\]\\(__(.*?)__\\)',
  );
  static final RegExp _uuidRegex = RegExp(
    '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\$',
  );

  static const Map<String, String> _statusSynonyms = <String, String>{
    'menunggu': 'pending',
  };

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
      final uri = Uri.parse(Endpoints.pengajuanCuti).replace(
        queryParameters: _buildQueryParameters(requestedPage, requestedPerPage),
      );

      final Map<String, dynamic> response = await _api.fetchDataPrivate(
        uri.toString(),
      );

      final List<dto.Data> parsedItems = _parseItems(
        response['data'] as dynamic,
      );

      final dto.Meta? parsedMeta = _parseMeta(response['meta']);

      if (append) {
        final merged = <String, dto.Data>{
          for (final entry in items) entry.idPengajuanCuti: entry,
        };
        for (final entry in parsedItems) {
          merged[entry.idPengajuanCuti] = entry;
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
          (item) => item.idPengajuanCuti == trimmedId,
        );
        return cached;
      } catch (_) {}
    }

    final uri = Uri.parse('${Endpoints.pengajuanCuti}/$trimmedId');

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
    String? idKategoriCuti,
    DateTime? tanggalCuti,
    DateTime? tanggalCutiFrom,
    DateTime? tanggalCutiTo,
    DateTime? tanggalMasukKerja,
    DateTime? tanggalMasukKerjaFrom,
    DateTime? tanggalMasukKerjaTo,
    String? userId,
  }) {
    statusFilter = _normalizeStatus(status);
    kategoriFilter = _normalizeString(idKategoriCuti);
    this.tanggalCuti = tanggalCuti;
    this.tanggalCutiFrom = tanggalCutiFrom;
    this.tanggalCutiTo = tanggalCutiTo;
    this.tanggalMasukKerja = tanggalMasukKerja;
    this.tanggalMasukKerjaFrom = tanggalMasukKerjaFrom;
    this.tanggalMasukKerjaTo = tanggalMasukKerjaTo;
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
      tanggalCuti = null;
      tanggalCutiFrom = null;
      tanggalCutiTo = null;
      tanggalMasukKerja = null;
      tanggalMasukKerjaFrom = null;
      tanggalMasukKerjaTo = null;
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
    required String idKategoriCuti,
    required String keperluan,
    required List<DateTime> tanggalList,
    required DateTime tanggalMasukKerja,
    String? handover,
    String? jenisPengajuan,
    List<String>? handoverUserIds,
    List<String>? supervisorIds,
    ApproversPengajuanProvider? approversProvider,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
    String supervisorsFieldName = 'recipient',
  }) async {
    _startSaving();

    // --- PERBAIKAN DIMULAI ---
    if (tanggalList.isEmpty) {
      _finishSaving(error: 'Tanggal cuti tidak boleh kosong.');
      return null;
    }
    // Pastikan diurutkan untuk dapat tanggal_cuti (pertama) & tanggal_selesai (terakhir)
    final List<DateTime> sortedDates = List<DateTime>.from(tanggalList)..sort();
    final DateTime tanggalCuti = sortedDates.first;
    final DateTime tanggalSelesai = sortedDates.last;
    // --- PERBAIKAN SELESAI ---

    final payload = <String, dynamic>{
      'id_kategori_cuti': idKategoriCuti,
      'keperluan': keperluan,
      'tanggal_masuk_kerja': _formatDate(tanggalMasukKerja),
      // --- TAMBAHAN BARU ---
      'tanggal_cuti': _formatDate(tanggalCuti),
      'tanggal_selesai': _formatDate(tanggalSelesai),
      // --- AKHIR TAMBAHAN ---
      if (handover != null) 'handover': handover,
      if (jenisPengajuan != null) 'jenis_pengajuan': jenisPengajuan,
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
      payload.addAll(_buildApprovalFormFields(approverIds));
    }

    final List<String> handoverIds = _resolveHandoverUserIds(
      provided: handoverUserIds,
      handover: handover,
    ).toList(growable: false);

    if (handoverIds.isNotEmpty) {
      payload['handover_tag_user_ids'] = jsonEncode(handoverIds);
    }

    final files = <http.MultipartFile>[
      if (lampiran != null) lampiran,
      ..._createMultipartStrings(supervisorsFieldName, approverIds),
      ..._createMultipartStrings('$supervisorsFieldName[]', approverIds),
      ..._createMultipartStrings('recipient_ids', approverIds),
      ..._createMultipartStrings('recipient_ids[]', approverIds),
      ..._createMultipartStrings(
        'tanggal_list',
        tanggalList.map((t) => _formatDate(t)).toList(),
      ),
      ..._createMultipartStrings('handover_tag_user_ids', handoverIds),
      ..._createMultipartStrings('handover_tag_user_ids[]', handoverIds),
    ];

    try {
      final response = await _api.postFormDataPrivate(
        Endpoints.pengajuanCuti,
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
        if (kDebugMode) {
          debugPrint(
            '[PengajuanCutiProvider] Approvals response (create): '
            '${created.approvals.map((a) => {'id': a.approverUserId, 'level': a.level}).toList()}',
          );
        }
      }

      final message =
          _extractMessage(response) ?? 'Pengajuan cuti berhasil dibuat.';
      _finishSaving(message: message);
      return created;
    } catch (e) {
      _finishSaving(error: e.toString());
      return null;
    }
  }

  Future<dto.Data?> updatePengajuan(
    String id, {
    required String idKategoriCuti,
    required String keperluan,
    required List<DateTime> tanggalList,
    required DateTime tanggalMasukKerja,
    String? handover,
    List<String>? handoverUserIds,
    String? jenisPengajuan,
    List<String>? supervisorIds,
    ApproversPengajuanProvider? approversProvider,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
    String supervisorsFieldName = 'recipient',
  }) async {
    _startSaving();

    // --- PERBAIKAN DIMULAI ---
    if (tanggalList.isEmpty) {
      _finishSaving(error: 'Tanggal cuti tidak boleh kosong.');
      return null;
    }
    // Pastikan diurutkan untuk dapat tanggal_cuti (pertama) & tanggal_selesai (terakhir)
    final List<DateTime> sortedDates = List<DateTime>.from(tanggalList)..sort();
    final DateTime tanggalCuti = sortedDates.first;
    final DateTime tanggalSelesai = sortedDates.last;
    // --- PERBAIKAN SELESAI ---

    final payload = <String, dynamic>{
      'id_kategori_cuti': idKategoriCuti,
      'keperluan': keperluan,
      'tanggal_masuk_kerja': _formatDate(tanggalMasukKerja),
      // --- TAMBAHAN BARU ---
      'tanggal_cuti': _formatDate(tanggalCuti),
      'tanggal_selesai': _formatDate(tanggalSelesai),
      // --- AKHIR TAMBAHAN ---
      if (handover != null) 'handover': handover,
      if (jenisPengajuan != null) 'jenis_pengajuan': jenisPengajuan,
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
      payload.addAll(_buildApprovalFormFields(approverIds));
    }

    final List<String> handoverIds = _resolveHandoverUserIds(
      provided: handoverUserIds,
      handover: handover,
    ).toList(growable: false);

    if (handoverIds.isNotEmpty) {
      payload['handover_tag_user_ids'] = jsonEncode(handoverIds);
    }

    final files = <http.MultipartFile>[
      if (lampiran != null) lampiran,
      ..._createMultipartStrings(supervisorsFieldName, approverIds),
      ..._createMultipartStrings('$supervisorsFieldName[]', approverIds),
      ..._createMultipartStrings('recipient_ids', approverIds),
      ..._createMultipartStrings('recipient_ids[]', approverIds),
      ..._createMultipartStrings(
        'tanggal_list',
        tanggalList.map((t) => _formatDate(t)).toList(),
      ),
      ..._createMultipartStrings('handover_tag_user_ids', handoverIds),
      ..._createMultipartStrings('handover_tag_user_ids[]', handoverIds),
    ];

    try {
      final response = await _api.putFormDataPrivate(
        '${Endpoints.pengajuanCuti}/$id',
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
        if (kDebugMode) {
          debugPrint(
            '[PengajuanCutiProvider] Approvals response (update): '
            '${updated.approvals.map((a) => {'id': a.approverUserId, 'level': a.level}).toList()}',
          );
        }
      }

      final message =
          _extractMessage(response) ?? 'Pengajuan cuti berhasil diperbarui.';
      _finishSaving(message: message);
      return updated;
    } catch (e) {
      _finishSaving(error: e.toString());
      return null;
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
        'id_kategori_cuti': kategoriFilter!,
      if (targetUserId != null && targetUserId!.isNotEmpty)
        'id_user': targetUserId!,
      if (tanggalCuti != null) 'tanggal_cuti': _formatDate(tanggalCuti!),
      if (tanggalCutiFrom != null)
        'tanggal_cuti_from': _formatDate(tanggalCutiFrom!),
      if (tanggalCutiTo != null) 'tanggal_cuti_to': _formatDate(tanggalCutiTo!),
      if (tanggalMasukKerja != null)
        'tanggal_masuk_kerja': _formatDate(tanggalMasukKerja!),
      if (tanggalMasukKerjaFrom != null)
        'tanggal_masuk_kerja_from': _formatDate(tanggalMasukKerjaFrom!),
      if (tanggalMasukKerjaTo != null)
        'tanggal_masuk_kerja_to': _formatDate(tanggalMasukKerjaTo!),
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
    }

    if (handover != null && handover.isNotEmpty) {
      for (final match in _mentionMarkupRegex.allMatches(handover)) {
        final String first = match.group(1) ?? '';
        final String second = match.group(2) ?? '';
        final String? candidate = _pickBestMentionId(first, second);
        if (candidate != null) {
          add(candidate);
        }
      }
    }

    return unique;
  }

  String? _pickBestMentionId(String first, String second) {
    final String a = first.trim();
    final String b = second.trim();
    final bool aIsUuid = _looksLikeUuid(a);
    final bool bIsUuid = _looksLikeUuid(b);

    if (aIsUuid && !bIsUuid) return a;
    if (bIsUuid && !aIsUuid) return b;
    if (aIsUuid && bIsUuid) return a;
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

  dto.Data? _parseSingleData(dynamic raw) {
    if (raw == null) return null;
    if (raw is dto.Data) return raw;
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('id_pengajuan_cuti')) {
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
      (existing) => existing.idPengajuanCuti == item.idPengajuanCuti,
    );
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
  }

  String? _extractMessage(Map<String, dynamic> response) {
    final dynamic message = response['message'] ?? response['msg'];
    return message is String ? message : null;
  }
}
