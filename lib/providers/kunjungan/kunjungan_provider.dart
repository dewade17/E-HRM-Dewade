import 'dart:async';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan.dart' as dto;
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class KunjunganProvider extends ChangeNotifier {
  KunjunganProvider({this.defaultPageSize = 10});

  static const Object _unset = Object();

  final ApiService _api = ApiService();
  final int defaultPageSize;

  final List<dto.Data> _items = <dto.Data>[];
  final Map<String, dto.Data> _cache = <String, dto.Data>{};
  final Set<String> _mutationIds = <String>{};

  dto.Pagination? _pagination;
  String _search = '';
  String? _kategoriId;
  DateTime? _tanggal;
  String? _error;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSaving = false;
  String? _lastMessage;
  String? _selectedId;
  Timer? _debounce;
  int _requestSeq = 0;

  List<dto.Data> get items => List.unmodifiable(_items);
  dto.Pagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get lastMessage => _lastMessage;
  String get search => _search;
  String? get kategoriId => _kategoriId;
  DateTime? get tanggalFilter => _tanggal;
  bool get canLoadMore =>
      _pagination != null && _pagination!.page < _pagination!.totalPages;
  String? get selectedId => _selectedId;
  dto.Data? get selectedItem => _selectedId == null ? null : byId(_selectedId!);

  bool isMutating(String id) => _mutationIds.contains(id);

  dto.Data? byId(String id) {
    final cached = _cache[id];
    if (cached != null) return cached;
    for (final item in _items) {
      if (item.idKunjungan == id) {
        _cache[id] = item;
        return item;
      }
    }
    return null;
  }

  Future<void> ensureLoaded() async {
    if (_items.isEmpty && !_isLoading) {
      await refresh();
    }
  }

  Future<void> refresh({
    Object? search = _unset,
    Object? kategoriId = _unset,
    Object? tanggal = _unset,
    int? pageSize,
  }) async {
    if (search != _unset) {
      final value = (search as String?)?.trim() ?? '';
      _search = value;
    }
    if (kategoriId != _unset) {
      final value = (kategoriId as String?)?.trim();
      _kategoriId = value == null || value.isEmpty ? null : value;
    }
    if (tanggal != _unset) {
      _tanggal = tanggal is DateTime ? tanggal : null;
    }
    await _fetch(page: 1, pageSize: pageSize ?? defaultPageSize, append: false);
  }

  Future<void> loadMore() async {
    if (!canLoadMore || _isLoading || _isLoadingMore) return;
    final nextPage = (_pagination?.page ?? 1) + 1;
    await _fetch(
      page: nextPage,
      pageSize: _pagination?.pageSize ?? defaultPageSize,
      append: true,
    );
  }

  void setSearch(
    String value, {
    Duration debounce = const Duration(milliseconds: 350),
  }) {
    final trimmed = value.trim();
    if (_search == trimmed) return;
    _search = trimmed;
    _debounce?.cancel();
    if (debounce.inMilliseconds <= 0) {
      refresh(search: trimmed);
    } else {
      _debounce = Timer(debounce, () {
        refresh(search: trimmed);
      });
    }
  }

  Future<void> setKategoriFilter(String? id) {
    final normalized = id?.trim();
    return refresh(
      kategoriId: normalized == null || normalized.isEmpty ? null : normalized,
    );
  }

  Future<void> setTanggalFilter(DateTime? tanggal) {
    return refresh(tanggal: tanggal);
  }

  Future<void> clearFilters() {
    _search = '';
    _kategoriId = null;
    _tanggal = null;
    return refresh();
  }

  void setSelectedId(String? id) {
    if (_selectedId == id) return;
    _selectedId = id;
    notifyListeners();
  }

  void clearMessage() {
    if (_lastMessage == null) return;
    _lastMessage = null;
    notifyListeners();
  }

  Future<dto.Data?> fetchDetail(String id, {bool forceRefresh = false}) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;

    if (!forceRefresh) {
      final cached = byId(trimmed);
      if (cached != null) {
        _selectedId ??= cached.idKunjungan;
        return cached;
      }
    }

    try {
      final res = await _api.fetchDataPrivate(
        Endpoints.kunjunganKlienDetail(trimmed),
      );
      final dataMap = _asMap(res['data'] ?? res);
      if (dataMap.isEmpty) return null;
      final item = dto.Data.fromJson(dataMap);
      _cache[item.idKunjungan] = item;

      final index = _items.indexWhere(
        (element) => element.idKunjungan == item.idKunjungan,
      );
      if (index >= 0) {
        _items[index] = item;
      }

      _selectedId ??= item.idKunjungan;
      notifyListeners();
      return item;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<dto.Data?> create(
    Map<String, dynamic> body, {
    List<http.MultipartFile>? files,
    bool refreshAfter = true,
  }) async {
    // Auto-fill tanggal (YYYY-MM-DD) dan jam_mulai jika tidak dikirim dari UI
    final now = DateTime.now();
    if (!body.containsKey('tanggal') ||
        body['tanggal'] == null ||
        (body['tanggal'] is String &&
            (body['tanggal'] as String).trim().isEmpty)) {
      body['tanggal'] = DateTime(now.year, now.month, now.day);
    }
    if (!body.containsKey('jam_mulai') ||
        body['jam_mulai'] == null ||
        (body['jam_mulai'] is String &&
            (body['jam_mulai'] as String).trim().isEmpty)) {
      body['jam_mulai'] = now;
    }
    _isSaving = true;
    _error = null;
    _lastMessage = null;
    notifyListeners();

    try {
      final hasFiles = files != null && files.isNotEmpty;
      final payload = _prepareBody(body, forForm: hasFiles);
      final response = hasFiles
          ? await _api.postFormDataPrivate(
              Endpoints.kunjunganKlien,
              payload,
              files: files,
            )
          : await _api.postDataPrivate(Endpoints.kunjunganKlien, payload);

      final dataMap = _asMap(response['data']);
      final item = dataMap.isEmpty ? null : dto.Data.fromJson(dataMap);
      if (item != null) {
        _cache[item.idKunjungan] = item;
        _selectedId ??= item.idKunjungan;
        if (!refreshAfter) {
          final existingIndex = _items.indexWhere(
            (element) => element.idKunjungan == item.idKunjungan,
          );
          if (existingIndex >= 0) {
            _items[existingIndex] = item;
          } else {
            _items.insert(0, item);
            final pagination = _pagination;
            if (pagination != null) {
              final newTotal = pagination.total + 1;
              final newTotalPages = pagination.pageSize > 0
                  ? ((newTotal + pagination.pageSize - 1) ~/
                        pagination.pageSize)
                  : pagination.totalPages;
              _pagination = dto.Pagination(
                page: pagination.page,
                pageSize: pagination.pageSize,
                total: newTotal,
                totalPages: newTotalPages,
              );
            }
          }
        }
      }
      _lastMessage = response['message'] as String?;

      if (refreshAfter) {
        await refresh();
      }

      return item;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<dto.Data?> update(
    String id,
    Map<String, dynamic> body, {
    List<http.MultipartFile>? files,
  }) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;

    _mutationIds.add(trimmed);
    _error = null;
    _lastMessage = null;
    notifyListeners();

    try {
      final hasFiles = files != null && files.isNotEmpty;
      final payload = _prepareBody(body, forForm: hasFiles);
      final response = hasFiles
          ? await _api.putFormDataPrivate(
              Endpoints.kunjunganKlienDetail(trimmed),
              payload,
              files: files,
            )
          : await _api.updateDataPrivate(
              Endpoints.kunjunganKlienDetail(trimmed),
              payload,
            );

      final dataMap = _asMap(response['data']);
      final item = dataMap.isEmpty ? null : dto.Data.fromJson(dataMap);
      if (item != null) {
        _cache[item.idKunjungan] = item;
        final index = _items.indexWhere(
          (element) => element.idKunjungan == item.idKunjungan,
        );
        if (index >= 0) {
          _items[index] = item;
        }
        _selectedId ??= item.idKunjungan;
      }
      _lastMessage = response['message'] as String?;
      return item;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      final removed = _mutationIds.remove(trimmed);
      if (removed) notifyListeners();
    }
  }

  Future<dto.Data?> submitKunjungan(
    String id,
    Map<String, dynamic> body,
  ) async {
    // Auto-fill jam_selesai jika belum diisi; hitung duration bila memungkinkan
    final now = DateTime.now();
    if (!body.containsKey('jam_selesai') ||
        body['jam_selesai'] == null ||
        (body['jam_selesai'] is String &&
            (body['jam_selesai'] as String).trim().isEmpty)) {
      body['jam_selesai'] = now;
    }
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;

    _mutationIds.add(trimmed);
    _error = null;
    _lastMessage = null;
    notifyListeners();

    try {
      final payload = _prepareBody(body, forForm: false);
      final response = await _api.updateDataPrivate(
        Endpoints.kunjunganKlienSubmit(trimmed),
        payload,
      );

      final dataMap = _asMap(response['data']);
      final item = dataMap.isEmpty ? null : dto.Data.fromJson(dataMap);
      if (item != null) {
        _cache[item.idKunjungan] = item;
        final index = _items.indexWhere(
          (element) => element.idKunjungan == item.idKunjungan,
        );
        if (index >= 0) {
          _items[index] = item;
        }
      }
      _lastMessage = response['message'] as String?;
      return item;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      final removed = _mutationIds.remove(trimmed);
      if (removed) notifyListeners();
    }
  }

  Future<bool> delete(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return false;

    _mutationIds.add(trimmed);
    _error = null;
    _lastMessage = null;
    notifyListeners();

    try {
      final response = await _api.deleteDataPrivate(
        Endpoints.kunjunganKlienDetail(trimmed),
      );
      _items.removeWhere((item) => item.idKunjungan == trimmed);
      _cache.remove(trimmed);
      if (_selectedId == trimmed) {
        _selectedId = _items.isNotEmpty ? _items.first.idKunjungan : null;
      }
      final pagination = _pagination;
      if (pagination != null) {
        final newTotal = pagination.total > 0 ? pagination.total - 1 : 0;
        final newTotalPages = pagination.pageSize > 0 && newTotal > 0
            ? ((newTotal + pagination.pageSize - 1) ~/ pagination.pageSize)
            : (newTotal == 0 ? 0 : 1);
        _pagination = dto.Pagination(
          page: pagination.page,
          pageSize: pagination.pageSize,
          total: newTotal,
          totalPages: newTotalPages,
        );
      }
      _lastMessage = response['message'] as String?;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      final removed = _mutationIds.remove(trimmed);
      if (removed) notifyListeners();
    }
  }

  Future<void> _fetch({
    required int page,
    required int pageSize,
    required bool append,
  }) async {
    if (_isLoading && !append) return;

    final seq = ++_requestSeq;
    if (append) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _error = null;
      _pagination = null;
    }
    notifyListeners();

    try {
      final params = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (_search.isNotEmpty) 'search': _search,
        if (_kategoriId != null) 'id_master_data_kunjungan': _kategoriId!,
        if (_tanggal != null) 'tanggal': _tanggal!.toIso8601String(),
      };

      final uri = Uri.parse(
        Endpoints.kunjunganKlien,
      ).replace(queryParameters: params);
      final res = await _api.fetchDataPrivate(uri.toString());
      if (seq != _requestSeq) return;

      final parsed = dto.KunjunganKlien.fromJson(_asMap(res));
      final fetched = parsed.data;

      if (!append) {
        _items
          ..clear()
          ..addAll(fetched);
      } else {
        for (final item in fetched) {
          final index = _items.indexWhere(
            (element) => element.idKunjungan == item.idKunjungan,
          );
          if (index >= 0) {
            _items[index] = item;
          } else {
            _items.add(item);
          }
        }
      }

      for (final item in fetched) {
        _cache[item.idKunjungan] = item;
      }

      _pagination = parsed.pagination;

      if (_selectedId != null && byId(_selectedId!) == null) {
        _selectedId = _items.isNotEmpty ? _items.first.idKunjungan : null;
      } else if (_selectedId == null && _items.isNotEmpty) {
        _selectedId = _items.first.idKunjungan;
      }

      _error = null;
    } catch (e) {
      if (seq != _requestSeq) return;
      if (!append) {
        _items.clear();
      }
      _error = e.toString();
    } finally {
      if (seq == _requestSeq) {
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Map<String, dynamic> _prepareBody(
    Map<String, dynamic> body, {
    required bool forForm,
  }) {
    final result = <String, dynamic>{};
    body.forEach((key, value) {
      if (value == null) {
        if (forForm) {
          result[key] = '';
        } else {
          result[key] = null;
        }
      } else if (value is DateTime) {
        result[key] = value.toUtc().toIso8601String();
      } else if (forForm) {
        result[key] = value.toString();
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
