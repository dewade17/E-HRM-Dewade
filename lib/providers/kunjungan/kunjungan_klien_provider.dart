import 'dart:async';
import 'dart:convert';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan_klien.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

enum _ListKind { general, berlangsung, diproses, selesai }

class _ListState {
  final List<Data> items = <Data>[];
  Pagination? pagination;
  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;
  String search = '';
  String? kategoriId;
  DateTime? tanggal;
  int requestSeq = 0;

  bool get canLoadMore {
    final p = pagination;
    if (p == null) return false;
    return p.page < p.totalPages;
  }
}

class _RequestResult {
  _RequestResult({this.message, this.data});

  final String? message;
  final Map<String, dynamic>? data;
}

class KunjunganKlienProvider extends ChangeNotifier {
  KunjunganKlienProvider({ApiService? api, this.defaultPageSize = 10})
    : _api = api ?? ApiService();

  final ApiService _api;
  final int defaultPageSize;

  final Map<_ListKind, _ListState> _states = {
    for (final kind in _ListKind.values) kind: _ListState(),
  };

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  Data? _detail;
  bool _detailLoading = false;
  String? _detailError;

  bool _saving = false;
  String? _saveMessage;
  String? _saveError;

  Timer? _searchDebounce;

  _ListState get _generalState => _states[_ListKind.general]!;
  _ListState get _berlangsungState => _states[_ListKind.berlangsung]!;
  _ListState get _diprosesState => _states[_ListKind.diproses]!;
  _ListState get _selesaiState => _states[_ListKind.selesai]!;

  List<Data> get items => List<Data>.unmodifiable(_generalState.items);
  Pagination? get pagination => _generalState.pagination;
  bool get isLoading => _generalState.isLoading;
  bool get isLoadingMore => _generalState.isLoadingMore;
  String? get error => _generalState.error;
  bool get canLoadMore => _generalState.canLoadMore;
  String get search => _generalState.search;
  String? get kategoriFilter => _generalState.kategoriId;
  DateTime? get tanggalFilter => _generalState.tanggal;

  List<Data> get berlangsungItems =>
      List<Data>.unmodifiable(_berlangsungState.items);
  bool get berlangsungLoading => _berlangsungState.isLoading;
  bool get berlangsungLoadingMore => _berlangsungState.isLoadingMore;
  bool get berlangsungCanLoadMore => _berlangsungState.canLoadMore;
  String? get berlangsungError => _berlangsungState.error;
  DateTime? get berlangsungTanggalFilter => _berlangsungState.tanggal;

  List<Data> get diprosesItems => List<Data>.unmodifiable(_diprosesState.items);
  bool get diprosesLoading => _diprosesState.isLoading;
  bool get diprosesLoadingMore => _diprosesState.isLoadingMore;
  bool get diprosesCanLoadMore => _diprosesState.canLoadMore;
  String? get diprosesError => _diprosesState.error;
  DateTime? get diprosesTanggalFilter => _diprosesState.tanggal;

  List<Data> get selesaiItems => List<Data>.unmodifiable(_selesaiState.items);
  bool get selesaiLoading => _selesaiState.isLoading;
  bool get selesaiLoadingMore => _selesaiState.isLoadingMore;
  bool get selesaiCanLoadMore => _selesaiState.canLoadMore;
  String? get selesaiError => _selesaiState.error;
  DateTime? get selesaiTanggalFilter => _selesaiState.tanggal;

  Data? get detail => _detail;
  bool get isDetailLoading => _detailLoading;
  String? get detailError => _detailError;

  bool get isSaving => _saving;
  String? get saveMessage => _saveMessage;
  String? get saveError => _saveError;

  Future<void> ensureLoaded() async {
    if (_generalState.items.isEmpty && !_generalState.isLoading) {
      await refresh();
    }
  }

  Future<void> refresh({int? pageSize}) {
    final state = _generalState;
    final resolvedPageSize = pageSize ?? defaultPageSize;
    return _fetchList(
      _ListKind.general,
      page: 1,
      pageSize: resolvedPageSize,
      append: false,
      search: state.search,
      kategoriId: state.kategoriId,
      tanggal: state.tanggal,
    );
  }

  Future<void> loadMore() {
    final state = _generalState;
    if (state.isLoading || state.isLoadingMore || !state.canLoadMore) {
      return Future<void>.value();
    }
    final nextPage = (state.pagination?.page ?? 1) + 1;
    final pageSize = state.pagination?.pageSize ?? defaultPageSize;
    return _fetchList(
      _ListKind.general,
      page: nextPage,
      pageSize: pageSize,
      append: true,
      search: state.search,
      kategoriId: state.kategoriId,
      tanggal: state.tanggal,
    );
  }

  void setSearch(
    String value, {
    Duration debounce = const Duration(milliseconds: 350),
  }) {
    final trimmed = value.trim();
    if (_generalState.search == trimmed) return;
    _generalState.search = trimmed;
    _searchDebounce?.cancel();
    if (debounce.inMilliseconds <= 0) {
      refresh();
    } else {
      _searchDebounce = Timer(debounce, () {
        refresh();
      });
    }
    notifyListeners();
  }

  Future<void> setKategoriFilter(String? id) {
    final normalized = (id ?? '').trim();
    final newValue = normalized.isEmpty ? null : normalized;
    if (_generalState.kategoriId == newValue) {
      return Future<void>.value();
    }
    _generalState.kategoriId = newValue;
    return refresh();
  }

  Future<void> setTanggalFilter(DateTime? tanggal) {
    if (_sameDay(_generalState.tanggal, tanggal)) {
      return Future<void>.value();
    }
    _generalState.tanggal = _normalizeDateOnly(tanggal);
    return refresh();
  }

  Future<void> refreshStatusBerlangsung({int? pageSize}) {
    final state = _berlangsungState;
    final resolvedPageSize = pageSize ?? defaultPageSize;
    return _fetchList(
      _ListKind.berlangsung,
      page: 1,
      pageSize: resolvedPageSize,
      append: false,
      tanggal: state.tanggal,
    );
  }

  Future<void> loadMoreStatusBerlangsung() {
    final state = _berlangsungState;
    if (state.isLoading || state.isLoadingMore || !state.canLoadMore) {
      return Future<void>.value();
    }
    final nextPage = (state.pagination?.page ?? 1) + 1;
    final pageSize = state.pagination?.pageSize ?? defaultPageSize;
    return _fetchList(
      _ListKind.berlangsung,
      page: nextPage,
      pageSize: pageSize,
      append: true,
      tanggal: state.tanggal,
    );
  }

  Future<void> setTanggalStatusBerlangsung(DateTime? tanggal) {
    if (_sameDay(_berlangsungState.tanggal, tanggal)) {
      return Future<void>.value();
    }
    _berlangsungState.tanggal = _normalizeDateOnly(tanggal);
    return refreshStatusBerlangsung();
  }

  Future<void> refreshStatusDiproses({int? pageSize}) {
    final state = _diprosesState;
    final resolvedPageSize = pageSize ?? defaultPageSize;
    return _fetchList(
      _ListKind.diproses,
      page: 1,
      pageSize: resolvedPageSize,
      append: false,
      tanggal: state.tanggal,
    );
  }

  Future<void> loadMoreStatusDiproses() {
    final state = _diprosesState;
    if (state.isLoading || state.isLoadingMore || !state.canLoadMore) {
      return Future<void>.value();
    }
    final nextPage = (state.pagination?.page ?? 1) + 1;
    final pageSize = state.pagination?.pageSize ?? defaultPageSize;
    return _fetchList(
      _ListKind.diproses,
      page: nextPage,
      pageSize: pageSize,
      append: true,
      tanggal: state.tanggal,
    );
  }

  Future<void> setTanggalStatusDiproses(DateTime? tanggal) {
    if (_sameDay(_diprosesState.tanggal, tanggal)) {
      return Future<void>.value();
    }
    _diprosesState.tanggal = _normalizeDateOnly(tanggal);
    return refreshStatusDiproses();
  }

  Future<void> refreshStatusSelesai({int? pageSize}) {
    final state = _selesaiState;
    final resolvedPageSize = pageSize ?? defaultPageSize;
    return _fetchList(
      _ListKind.selesai,
      page: 1,
      pageSize: resolvedPageSize,
      append: false,
      tanggal: state.tanggal,
    );
  }

  Future<void> loadMoreStatusSelesai() {
    final state = _selesaiState;
    if (state.isLoading || state.isLoadingMore || !state.canLoadMore) {
      return Future<void>.value();
    }
    final nextPage = (state.pagination?.page ?? 1) + 1;
    final pageSize = state.pagination?.pageSize ?? defaultPageSize;
    return _fetchList(
      _ListKind.selesai,
      page: nextPage,
      pageSize: pageSize,
      append: true,
      tanggal: state.tanggal,
    );
  }

  Future<void> setTanggalStatusSelesai(DateTime? tanggal) {
    if (_sameDay(_selesaiState.tanggal, tanggal)) {
      return Future<void>.value();
    }
    _selesaiState.tanggal = _normalizeDateOnly(tanggal);
    return refreshStatusSelesai();
  }

  Future<Data?> fetchDetail(String id) async {
    _detailLoading = true;
    _detailError = null;
    notifyListeners();
    try {
      final res = await _api.fetchDataPrivate(
        Endpoints.kunjunganKlienDetail(id),
      );
      final dataRaw = res['data'];
      if (dataRaw is Map) {
        final item = Data.fromJson(Map<String, dynamic>.from(dataRaw));
        _detail = item;
        _applyUpdatedItem(item);
        return item;
      }
      _detail = null;
      _detailError = 'Data kunjungan tidak ditemukan.';
      return null;
    } catch (e) {
      _detailError = e.toString();
      return null;
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  void clearDetail() {
    if (_detail == null && _detailError == null) return;
    _detail = null;
    _detailError = null;
    notifyListeners();
  }

  Future<Data?> createKunjungan({
    required String idKategoriKunjungan,
    required DateTime tanggal,
    DateTime? jamMulai,
    DateTime? jamSelesai,
    String? deskripsi,
    Map<String, dynamic>? additionalFields,
  }) async {
    final payload = <String, dynamic>{
      'id_kategori_kunjungan': idKategoriKunjungan,
      'tanggal': tanggal,
      if (jamMulai != null) 'jam_mulai': jamMulai,
      if (jamSelesai != null) 'jam_selesai': jamSelesai,
      if (deskripsi != null && deskripsi.trim().isNotEmpty)
        'deskripsi': deskripsi.trim(),
    };
    if (additionalFields != null) {
      payload.addAll(additionalFields);
    }

    _startSaving();
    try {
      final res = await _api.postDataPrivate(
        Endpoints.kunjunganKlien,
        _prepareJsonPayload(payload),
      );
      final dataRaw = res['data'];
      Data? item;
      if (dataRaw is Map) {
        item = Data.fromJson(Map<String, dynamic>.from(dataRaw));
        _applyUpdatedItem(item, preferInsertToTop: true);
      }
      _saveMessage = res['message']?.toString();
      _saveError = null;
      return item;
    } catch (e) {
      _saveError = e.toString();
      _saveMessage = null;
      return null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<Data?> updateKunjungan(
    String id, {
    String? idKategoriKunjungan,
    DateTime? tanggal,
    DateTime? jamMulai,
    DateTime? jamSelesai,
    String? deskripsi,
    String? handOver,
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
    String? lampiranKunjunganUrl,
    bool removeLampiran = false,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
  }) async {
    final payload = <String, dynamic>{
      if (idKategoriKunjungan != null)
        'id_kategori_kunjungan': idKategoriKunjungan,
      if (tanggal != null) 'tanggal': tanggal,
      if (jamMulai != null) 'jam_mulai': jamMulai,
      if (jamSelesai != null) 'jam_selesai': jamSelesai,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (handOver != null) 'hand_over': handOver,
      if (startLatitude != null) 'start_latitude': startLatitude,
      if (startLongitude != null) 'start_longitude': startLongitude,
      if (endLatitude != null) 'end_latitude': endLatitude,
      if (endLongitude != null) 'end_longitude': endLongitude,
    };

    if (removeLampiran) {
      payload['lampiran_kunjungan_url'] = null;
    } else if (lampiranKunjunganUrl != null) {
      payload['lampiran_kunjungan_url'] = lampiranKunjunganUrl;
    }

    if (additionalFields != null) {
      payload.addAll(additionalFields);
    }

    if (payload.isEmpty && lampiran == null) {
      _saveError = 'Tidak ada data yang diubah.';
      _saveMessage = null;
      notifyListeners();
      return null;
    }

    _startSaving();
    try {
      final result = await _putWithOptionalFile(
        Endpoints.kunjunganKlienDetail(id),
        payload: payload,
        lampiran: lampiran,
      );
      Data? item;
      if (result.data != null) {
        item = Data.fromJson(result.data!);
        _applyUpdatedItem(item);
      }
      _saveMessage = result.message;
      _saveError = null;
      return item;
    } catch (e) {
      _saveError = e.toString();
      _saveMessage = null;
      return null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<Data?> submitStartKunjungan(
    String id, {
    DateTime? jamCheckin,
    double? startLatitude,
    double? startLongitude,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
  }) async {
    final payload = <String, dynamic>{
      if (jamCheckin != null) 'jam_checkin': jamCheckin,
      if (startLatitude != null) 'start_latitude': startLatitude,
      if (startLongitude != null) 'start_longitude': startLongitude,
    };

    if (additionalFields != null) {
      payload.addAll(additionalFields);
    }

    if (payload.isEmpty && lampiran == null) {
      _saveError = 'Tidak ada data check-in yang diberikan.';
      _saveMessage = null;
      notifyListeners();
      return null;
    }

    _startSaving();
    try {
      final result = await _putWithOptionalFile(
        Endpoints.kunjunganKlienStartSubmit(id),
        payload: payload,
        lampiran: lampiran,
      );
      Data? item;
      if (result.data != null) {
        item = Data.fromJson(result.data!);
        _applyUpdatedItem(item);
      }
      _saveMessage = result.message ?? 'Check-in kunjungan berhasil.';
      _saveError = null;
      return item;
    } catch (e) {
      _saveError = e.toString();
      _saveMessage = null;
      return null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<Data?> submitEndKunjungan(
    String id, {
    String? deskripsi,
    DateTime? jamCheckout,
    double? endLatitude,
    double? endLongitude,
    String? idKategoriKunjungan,
    String? lampiranKunjunganUrl,
    bool removeLampiran = false,
    List<Map<String, dynamic>>? recipients,
    http.MultipartFile? lampiran,
    Map<String, dynamic>? additionalFields,
  }) async {
    final payload = <String, dynamic>{
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (jamCheckout != null) 'jam_checkout': jamCheckout,
      if (endLatitude != null) 'end_latitude': endLatitude,
      if (endLongitude != null) 'end_longitude': endLongitude,
      if (idKategoriKunjungan != null)
        'id_kategori_kunjungan': idKategoriKunjungan,
    };

    if (removeLampiran) {
      payload['lampiran_kunjungan_url'] = null;
    } else if (lampiranKunjunganUrl != null) {
      payload['lampiran_kunjungan_url'] = lampiranKunjunganUrl;
    }

    if (recipients != null) {
      payload['recipients'] = recipients;
    }

    if (additionalFields != null) {
      payload.addAll(additionalFields);
    }

    if (payload.isEmpty && lampiran == null) {
      _saveError = 'Tidak ada data check-out yang diberikan.';
      _saveMessage = null;
      notifyListeners();
      return null;
    }

    _startSaving();
    try {
      final result = await _putWithOptionalFile(
        Endpoints.kunjunganKlienEndSubmit(id),
        payload: payload,
        lampiran: lampiran,
      );
      Data? item;
      if (result.data != null) {
        item = Data.fromJson(result.data!);
        _applyUpdatedItem(item);
      }
      _saveMessage = result.message ?? 'Check-out kunjungan berhasil.';
      _saveError = null;
      return item;
    } catch (e) {
      _saveError = e.toString();
      _saveMessage = null;
      return null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteKunjungan(String id) async {
    _startSaving();
    try {
      final res = await _api.deleteDataPrivate(
        Endpoints.kunjunganKlienDetail(id),
      );
      _saveMessage = res['message']?.toString();
      _saveError = null;
      _removeItem(id);
      return true;
    } catch (e) {
      _saveError = e.toString();
      _saveMessage = null;
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  void clearSaveState() {
    if (_saveMessage == null && _saveError == null) return;
    _saveMessage = null;
    _saveError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchList(
    _ListKind kind, {
    required int page,
    required int pageSize,
    required bool append,
    String? search,
    String? kategoriId,
    DateTime? tanggal,
  }) async {
    final state = _states[kind]!;
    if (append) {
      if (state.isLoading || state.isLoadingMore) return;
      state.isLoadingMore = true;
    } else {
      state.isLoading = true;
      state.error = null;
      state.pagination = null;
    }

    if (!append) {
      if (kind == _ListKind.general && search != null) {
        state.search = search;
      }
      if (kategoriId != null || kind != _ListKind.general) {
        state.kategoriId = kategoriId;
      }
      if (tanggal != null || kind != _ListKind.general) {
        state.tanggal = tanggal;
      }
    }

    final seq = ++state.requestSeq;
    notifyListeners();

    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    final effectiveSearch = kind == _ListKind.general
        ? (search ?? state.search)
        : null;
    final effectiveKategori = kategoriId ?? state.kategoriId;
    final effectiveTanggal = tanggal ?? state.tanggal;

    if (kind == _ListKind.general &&
        effectiveSearch != null &&
        effectiveSearch.isNotEmpty) {
      params['q'] = effectiveSearch;
    }
    if (effectiveKategori != null && effectiveKategori.isNotEmpty) {
      params['id_kategori_kunjungan'] = effectiveKategori;
    }
    if (effectiveTanggal != null) {
      params['tanggal'] = _formatDateQuery(effectiveTanggal);
    }

    final endpoint = _resolveEndpoint(kind);

    try {
      final uri = Uri.parse(endpoint).replace(queryParameters: params);
      final res = await _api.fetchDataPrivate(uri.toString());
      if (seq != state.requestSeq) return;

      final parsed = Kunjunganklien.fromJson(Map<String, dynamic>.from(res));
      final items = parsed.data;

      if (!append) {
        state.items
          ..clear()
          ..addAll(items);
      } else {
        for (final item in items) {
          final index = state.items.indexWhere(
            (existing) => existing.idKunjungan == item.idKunjungan,
          );
          if (index >= 0) {
            state.items[index] = item;
          } else {
            state.items.add(item);
          }
        }
      }

      state.pagination =
          parsed.pagination ??
          Pagination(
            page: page,
            pageSize: pageSize,
            total: parsed.pagination?.total ?? state.items.length,
            totalPages:
                parsed.pagination?.totalPages ??
                _calculateTotalPages(state.items.length, pageSize),
          );
      state.error = null;
    } catch (e) {
      if (!append) {
        state.items.clear();
      }
      state.error = e.toString();
    } finally {
      if (seq == state.requestSeq) {
        state.isLoading = false;
        state.isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  String _resolveEndpoint(_ListKind kind) {
    switch (kind) {
      case _ListKind.general:
        return Endpoints.kunjunganKlien;
      case _ListKind.berlangsung:
        return Endpoints.kunjunganKlienStatusBerlangsung('');
      case _ListKind.diproses:
        return Endpoints.kunjunganKlienStatusDiproses('');
      case _ListKind.selesai:
        return Endpoints.kunjunganKlienStatusSekesai('');
    }
  }

  String _formatDateQuery(DateTime date) {
    final normalized = _normalizeDateOnly(date)!;
    return _dateFormatter.format(normalized);
  }

  DateTime? _normalizeDateOnly(DateTime? value) {
    if (value == null) return null;
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  bool _sameDay(DateTime? a, DateTime? b) {
    final da = _normalizeDateOnly(a);
    final db = _normalizeDateOnly(b);
    if (da == null && db == null) return true;
    if (da == null || db == null) return false;
    return da.year == db.year && da.month == db.month && da.day == db.day;
  }

  void _applyUpdatedItem(Data item, {bool preferInsertToTop = false}) {
    for (final entry in _states.entries) {
      final kind = entry.key;
      final state = entry.value;
      final shouldInclude = _shouldInclude(kind, state, item);
      final index = state.items.indexWhere(
        (existing) => existing.idKunjungan == item.idKunjungan,
      );
      if (index >= 0) {
        if (shouldInclude) {
          state.items[index] = item;
        } else {
          state.items.removeAt(index);
        }
      } else if (shouldInclude) {
        if (preferInsertToTop) {
          state.items.insert(0, item);
        } else {
          state.items.add(item);
        }
      }
    }

    if (_detail?.idKunjungan == item.idKunjungan) {
      _detail = item;
    }
  }

  bool _shouldInclude(_ListKind kind, _ListState state, Data item) {
    final status = item.statusKunjungan.toLowerCase();
    switch (kind) {
      case _ListKind.berlangsung:
        if (status != 'berlangsung') return false;
        break;
      case _ListKind.diproses:
        if (status != 'diproses') return false;
        break;
      case _ListKind.selesai:
        if (status != 'selesai') return false;
        break;
      case _ListKind.general:
        break;
    }

    final kategoriFilter = state.kategoriId;
    if (kategoriFilter != null && kategoriFilter.isNotEmpty) {
      final kategoriId =
          item.idKategoriKunjungan ?? item.kategoriIdFromRelation;
      if (kategoriId != kategoriFilter) return false;
    }

    final tanggalFilter = state.tanggal;
    if (tanggalFilter != null) {
      final itemDate = _normalizeDateOnly(item.tanggal);
      if (!_sameDay(itemDate, tanggalFilter)) return false;
    }

    if (kind == _ListKind.general) {
      final searchTerm = state.search.trim().toLowerCase();
      if (searchTerm.isNotEmpty) {
        final deskripsi = item.deskripsi?.toLowerCase() ?? '';
        final handOver = item.handOver?.toLowerCase() ?? '';
        if (!deskripsi.contains(searchTerm) && !handOver.contains(searchTerm)) {
          return false;
        }
      }
    }

    return true;
  }

  void _removeItem(String id) {
    for (final state in _states.values) {
      state.items.removeWhere((item) => item.idKunjungan == id);
    }
    if (_detail?.idKunjungan == id) {
      _detail = null;
      _detailError = null;
    }
  }

  void _startSaving() {
    _saving = true;
    _saveError = null;
    _saveMessage = null;
    notifyListeners();
  }

  Future<_RequestResult> _putWithOptionalFile(
    String url, {
    required Map<String, dynamic> payload,
    http.MultipartFile? lampiran,
  }) async {
    Map<String, dynamic> response;
    if (lampiran != null) {
      response = await _api.putFormDataPrivate(
        url,
        _prepareFormPayload(payload),
        files: <http.MultipartFile>[lampiran],
      );
    } else {
      response = await _api.updateDataPrivate(
        url,
        _prepareJsonPayload(payload),
      );
    }

    final message = response['message']?.toString();
    final dataRaw = response['data'];
    final dataMap = dataRaw is Map ? Map<String, dynamic>.from(dataRaw) : null;
    return _RequestResult(message: message, data: dataMap);
  }

  Map<String, dynamic> _prepareJsonPayload(Map<String, dynamic> payload) {
    final result = <String, dynamic>{};
    payload.forEach((key, value) {
      if (value is DateTime) {
        result[key] = value.toIso8601String();
      } else if (value is List) {
        result[key] = value
            .map((item) => item is Map ? Map<String, dynamic>.from(item) : item)
            .toList();
      } else if (value is Map) {
        result[key] = Map<String, dynamic>.from(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  Map<String, dynamic> _prepareFormPayload(Map<String, dynamic> payload) {
    final result = <String, dynamic>{};
    payload.forEach((key, value) {
      if (value == null) {
        result[key] = '';
      } else if (value is DateTime) {
        result[key] = value.toIso8601String();
      } else if (value is bool) {
        result[key] = value ? '1' : '0';
      } else if (value is List || value is Map) {
        result[key] = jsonEncode(value);
      } else {
        result[key] = value.toString();
      }
    });
    return result;
  }

  int _calculateTotalPages(int total, int pageSize) {
    if (pageSize <= 0) return 1;
    return (total / pageSize).ceil();
  }
}
