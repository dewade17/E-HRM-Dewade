import 'package:flutter/foundation.dart';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pengajuan_izin_jam/pengajuan_izin_jam.dart' as dto;
import 'package:e_hrm/services/api_services.dart';

class PengajuanIzinJamProvider extends ChangeNotifier {
  PengajuanIzinJamProvider();

  final ApiService _api = ApiService();

  bool loading = false;
  String? error;

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
      value.toIso8601String().split('T').first;
}
