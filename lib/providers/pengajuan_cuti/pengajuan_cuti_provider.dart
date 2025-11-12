import 'package:flutter/foundation.dart';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as dto;
import 'package:e_hrm/services/api_services.dart';

class PengajuanCutiProvider extends ChangeNotifier {
  PengajuanCutiProvider();

  final ApiService _api = ApiService();

  bool loading = false;
  String? error;

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

  static const Map<String, String> _statusSynonyms = <String, String>{
    'menunggu': 'pending',
  };

  bool get hasMore {
    final currentMeta = meta;
    if (currentMeta == null) return false;
    return currentMeta.page < currentMeta.totalPages;
  }

  Future<bool> fetch({
    int? page,
    int? perPage,
    bool append = false,
  }) async {
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
        queryParameters: _buildQueryParameters(
          requestedPage,
          requestedPerPage,
        ),
      );

      final Map<String, dynamic> response = await _api.fetchDataPrivate(
        uri.toString(),
      );

      final List<dto.Data> parsedItems =
          _parseItems(response['data'] as dynamic);

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

  Map<String, String> _buildQueryParameters(int requestedPage, int requestedPerPage) {
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
      if (tanggalCutiTo != null)
        'tanggal_cuti_to': _formatDate(tanggalCutiTo!),
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
          parsed.add(dto.Data.fromJson(
            Map<String, dynamic>.from(entry),
          ));
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
      return dto.Meta.fromJson(
        Map<String, dynamic>.from(raw),
      );
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
}
