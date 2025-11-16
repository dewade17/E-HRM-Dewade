import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pengajuan_sakit/Kategori_pengajuan_sakit.dart'
    as kategori_dto;
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';

/// Provider untuk mengambil data kategori izin sakit.
///
/// Backend saat ini masih menggunakan endpoint `/admin/kategori-izin-jam`
/// untuk resource kategori izin, sehingga provider ini melakukan normalisasi
/// payload agar tetap sesuai dengan DTO pengajuan sakit.
class KategoriIzinSakitProvider extends ChangeNotifier {
  KategoriIzinSakitProvider({ApiService? api, String? endpoint})
    : assert(
        (endpoint ?? Endpoints.kategoriIzinJam).trim().isNotEmpty,
        'Endpoint kategori izin tidak boleh kosong.',
      ),
      _api = api ?? ApiService(),
      _endpoint = (endpoint ?? Endpoints.kategoriIzinJam).trim();

  final ApiService _api;
  final String _endpoint;

  static const Set<String> _allowedOrderBy = {
    'created_at',
    'updated_at',
    'nama_kategori',
  };

  final List<kategori_dto.Data> _items = <kategori_dto.Data>[];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  int _page = 1;
  int _pageSize = 10;
  int _total = 0;
  int _totalPages = 0;

  String _search = '';
  bool _includeDeleted = false;
  bool _deletedOnly = false;
  String _orderBy = 'created_at';
  String _sort = 'desc';

  List<kategori_dto.Data> get items => List.unmodifiable(_items);
  bool get loading => _isLoading;
  bool get loadingMore => _isLoadingMore;
  String? get error => _error;
  int get page => _page;
  int get pageSize => _pageSize;
  int get total => _total;
  int get totalPages => _totalPages;
  String get search => _search;
  bool get includeDeleted => _includeDeleted;
  bool get deletedOnly => _deletedOnly;
  String get orderBy => _orderBy;
  String get sort => _sort;
  bool get canLoadMore =>
      !_isLoading && !_isLoadingMore && _page < _totalPages && _totalPages > 0;

  Future<void> ensureLoaded() async {
    if (_items.isEmpty && !_isLoading && !_isLoadingMore) {
      await fetch(page: 1, append: false);
    }
  }

  Future<bool> fetch({
    int? page,
    int? pageSize,
    String? search,
    bool? includeDeleted,
    bool? deletedOnly,
    String? orderBy,
    String? sort,
    bool append = false,
  }) async {
    if (_isLoading || _isLoadingMore) {
      return false;
    }
    if (append && !canLoadMore && _items.isNotEmpty) {
      return false;
    }

    final resolvedPage = _normalizePage(page ?? (append ? _page + 1 : _page));
    final resolvedPageSize = _normalizePageSize(pageSize ?? _pageSize);
    final resolvedSearch = (search ?? _search).trim();
    final resolvedDeletedOnly = deletedOnly ?? _deletedOnly;
    final resolvedIncludeDeleted = resolvedDeletedOnly
        ? true
        : (includeDeleted ?? _includeDeleted);
    final resolvedOrderBy = _normalizeOrderBy(orderBy ?? _orderBy);
    final resolvedSort = _normalizeSort(sort ?? _sort);

    _setLoading(true, append: append);
    try {
      final queryParameters = _buildQueryParameters(
        page: resolvedPage,
        pageSize: resolvedPageSize,
        search: resolvedSearch,
        includeDeleted: resolvedIncludeDeleted,
        deletedOnly: resolvedDeletedOnly,
        orderBy: resolvedOrderBy,
        sort: resolvedSort,
      );

      final uri = Uri.parse(
        _endpoint,
      ).replace(queryParameters: queryParameters);
      final response = await _api.fetchDataPrivate(uri.toString());

      final fetchedItems = _parseItems(response['data']);
      final pagination = _parsePagination(response['pagination']);

      if (!append) {
        _items
          ..clear()
          ..addAll(fetchedItems);
      } else {
        _items.addAll(fetchedItems);
      }

      _applyPagination(
        pagination,
        fallbackPage: resolvedPage,
        fallbackPageSize: resolvedPageSize,
        fetchedCount: fetchedItems.length,
        append: append,
      );

      _search = resolvedSearch;
      _includeDeleted = resolvedIncludeDeleted;
      _deletedOnly = resolvedDeletedOnly;
      _orderBy = resolvedOrderBy;
      _sort = resolvedSort;
      _error = null;

      return true;
    } catch (e) {
      _error = e.toString();
      if (!append) {
        _items.clear();
        _total = 0;
        _totalPages = 0;
      }
      return false;
    } finally {
      _setLoading(false, append: append);
    }
  }

  Future<bool> refresh() => fetch(page: 1, append: false);

  Future<bool> loadMore() {
    if (!canLoadMore) {
      return Future<bool>.value(false);
    }
    return fetch(page: _page + 1, append: true);
  }

  Future<bool> applySearch(String value) {
    _search = value.trim();
    return fetch(page: 1, append: false);
  }

  Future<bool> setIncludeDeleted(bool value) {
    _includeDeleted = value;
    if (!value && _deletedOnly) {
      _deletedOnly = false;
    }
    return fetch(page: 1, append: false);
  }

  Future<bool> setDeletedOnly(bool value) {
    _deletedOnly = value;
    if (value) {
      _includeDeleted = true;
    }
    return fetch(page: 1, append: false);
  }

  Future<bool> setSort({required String orderBy, required String sort}) {
    _orderBy = _normalizeOrderBy(orderBy);
    _sort = _normalizeSort(sort);
    return fetch(page: 1, append: false);
  }

  void reset() {
    _items.clear();
    _page = 1;
    _pageSize = 10;
    _total = 0;
    _totalPages = 0;
    _search = '';
    _includeDeleted = false;
    _deletedOnly = false;
    _orderBy = 'created_at';
    _sort = 'desc';
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  void _setLoading(bool value, {required bool append}) {
    if (append) {
      if (_isLoadingMore == value) return;
      _isLoadingMore = value;
    } else {
      if (_isLoading == value) return;
      _isLoading = value;
    }
    notifyListeners();
  }

  Map<String, String> _buildQueryParameters({
    required int page,
    required int pageSize,
    required String search,
    required bool includeDeleted,
    required bool deletedOnly,
    required String orderBy,
    required String sort,
  }) {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'includeDeleted': includeDeleted ? '1' : '0',
      'deletedOnly': deletedOnly ? '1' : '0',
      'orderBy': orderBy,
      'sort': sort,
    };
    if (search.isNotEmpty) {
      params['search'] = search;
    }
    return params;
  }

  List<kategori_dto.Data> _parseItems(dynamic rawData) {
    if (rawData is! List) return <kategori_dto.Data>[];

    return rawData
        .map(_normalizeJsonMap)
        .whereType<Map<String, dynamic>>()
        .map(_normalizeDataKeys)
        .map(kategori_dto.Data.fromJson)
        .toList();
  }

  kategori_dto.Pagination? _parsePagination(dynamic rawPagination) {
    final map = _normalizeJsonMap(rawPagination);
    if (map == null) return null;
    try {
      return kategori_dto.Pagination.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  void _applyPagination(
    kategori_dto.Pagination? pagination, {
    required int fallbackPage,
    required int fallbackPageSize,
    required int fetchedCount,
    required bool append,
  }) {
    if (pagination != null) {
      _page = pagination.page;
      _pageSize = pagination.pageSize;
      _total = pagination.total;
      _totalPages = pagination.totalPages;
      return;
    }

    _page = fallbackPage;
    _pageSize = fallbackPageSize;
    _total = append ? _total + fetchedCount : fetchedCount;
    _totalPages = _pageSize == 0 ? 0 : (_total / _pageSize).ceil();
  }

  int _normalizePage(int value) => value < 1 ? 1 : value;

  int _normalizePageSize(int value) {
    if (value < 1) return 1;
    if (value > 100) return 100;
    return value;
  }

  String _normalizeOrderBy(String value) {
    final normalized = value.trim().toLowerCase();
    return _allowedOrderBy.contains(normalized) ? normalized : 'created_at';
  }

  String _normalizeSort(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'asc' ? 'asc' : 'desc';
  }

  Map<String, dynamic>? _normalizeJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  Map<String, dynamic> _normalizeDataKeys(Map<String, dynamic> source) {
    if (source.containsKey('id_kategori_sakit') ||
        !source.containsKey('id_kategori_izin_jam')) {
      return source;
    }
    final normalized = Map<String, dynamic>.from(source);
    normalized['id_kategori_sakit'] = source['id_kategori_izin_jam'];
    return normalized;
  }
}
