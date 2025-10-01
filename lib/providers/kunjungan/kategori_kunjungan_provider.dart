import 'dart:async';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/kunjungan/kategori_kunjungan.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';

class KategoriKunjunganProvider extends ChangeNotifier {
  KategoriKunjunganProvider({this.defaultPageSize = 20});

  final ApiService _api = ApiService();
  final int defaultPageSize;

  final List<KategoriKunjunganItem> _items = <KategoriKunjunganItem>[];
  Pagination? _pagination;
  String _search = '';
  bool _includeDeleted = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _selectedId;
  int _requestSeq = 0;
  Timer? _debounce;

  List<KategoriKunjunganItem> get items => List.unmodifiable(_items);
  Pagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get search => _search;
  bool get includeDeleted => _includeDeleted;
  bool get isEmpty => _items.isEmpty && !_isLoading;
  bool get canLoadMore =>
      _pagination != null && _pagination!.page < _pagination!.totalPages;

  String? get selectedId => _selectedId;
  KategoriKunjunganItem? get selectedItem =>
      _selectedId == null ? null : itemById(_selectedId!);

  KategoriKunjunganItem? itemById(String id) {
    try {
      // DIPERBARUI: Menggunakan field ID yang benar
      return _items.firstWhere((item) => item.idKategoriKunjungan == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> ensureLoaded() async {
    if (_items.isEmpty && !_isLoading) {
      await refresh();
    }
  }

  Future<void> refresh({
    String? search,
    bool? includeDeleted,
    int? pageSize,
  }) async {
    if (search != null) _search = search.trim();
    if (includeDeleted != null) _includeDeleted = includeDeleted;
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

  void setSelectedId(String? id) {
    if (_selectedId == id) return;
    _selectedId = id;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedId == null) return;
    _selectedId = null;
    notifyListeners();
  }

  Future<void> setIncludeDeleted(bool value) async {
    if (_includeDeleted == value) return;
    _includeDeleted = value;
    await refresh(includeDeleted: value);
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
      refresh(search: _search);
    } else {
      _debounce = Timer(debounce, () {
        refresh(search: _search);
      });
    }
  }

  Future<KategoriKunjunganItem?> fetchDetail(String id) async {
    try {
      // DIPERBARUI: Menggunakan endpoint yang benar
      final res = await _api.fetchDataPrivate(
        Endpoints.kategoriKunjunganDetail(id),
      );
      final dataJson = res['data'];
      if (dataJson is Map) {
        final item = KategoriKunjunganItem.fromJson(
          Map<String, dynamic>.from(dataJson),
        );
        final index = _items.indexWhere(
          // DIPERBARUI: Menggunakan field ID yang benar
          (existing) =>
              existing.idKategoriKunjungan == item.idKategoriKunjungan,
        );
        if (index >= 0) {
          _items[index] = item;
        } else {
          _items.add(item);
        }
        // DIPERBARUI: Menggunakan field ID yang benar
        _selectedId ??= item.idKategoriKunjungan;
        notifyListeners();
        return item;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return null;
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
        'includeDeleted': _includeDeleted ? '1' : '0',
        if (_search.isNotEmpty) 'search': _search,
      };
      // DIPERBARUI: Menggunakan endpoint yang benar
      final uri = Uri.parse(
        Endpoints.kategoriKunjungan,
      ).replace(queryParameters: params);

      final res = await _api.fetchDataPrivate(uri.toString());
      if (seq != _requestSeq) return;

      final parsed = KategoriKunjunganList.fromJson(
        Map<String, dynamic>.from(res),
      );

      if (!append) {
        _items
          ..clear()
          ..addAll(parsed.data);
      } else {
        _items.addAll(parsed.data);
      }

      _pagination =
          parsed.pagination ??
          Pagination(
            page: page,
            pageSize: pageSize,
            total: _items.length,
            totalPages: page,
          );

      if (_selectedId != null && itemById(_selectedId!) == null) {
        // DIPERBARUI: Menggunakan field ID yang benar
        _selectedId = _items.isEmpty ? null : _items.first.idKategoriKunjungan;
      } else if (_selectedId == null && _items.isNotEmpty) {
        // DIPERBARUI: Menggunakan field ID yang benar
        _selectedId = _items.first.idKategoriKunjungan;
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
