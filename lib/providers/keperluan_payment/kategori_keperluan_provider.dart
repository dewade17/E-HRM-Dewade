import 'package:flutter/foundation.dart';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/kategori_keperluan/kategori_keperluan.dart';
import 'package:e_hrm/services/api_services.dart';

class KategoriKeperluanProvider extends ChangeNotifier {
  KategoriKeperluanProvider();

  final ApiService _api = ApiService();

  bool loading = false;
  String? error;

  List<Data> items = [];

  int page = 1;
  int pageSize = 10;
  int total = 0;
  int totalPages = 1;

  String search = '';
  bool includeDeleted = false;
  bool deletedOnly = false;

  String orderBy = 'created_at'; // created_at | updated_at | nama_keperluan
  String sort = 'desc'; // asc | desc

  static const Set<String> _allowedOrderBy = <String>{
    'created_at',
    'updated_at',
    'nama_keperluan',
  };

  static const Set<String> _allowedSort = <String>{'asc', 'desc'};

  String get _endpointBase => Endpoints.kategoriKeperluan;

  void _setLoading(bool value) {
    if (loading == value) return;
    loading = value;
    notifyListeners();
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
    _setLoading(true);

    try {
      final currentPage = page ?? this.page;
      final currentPageSize = pageSize ?? this.pageSize;
      final currentSearch = (search ?? this.search).trim();
      final currentIncludeDeleted = includeDeleted ?? this.includeDeleted;
      final currentDeletedOnly = deletedOnly ?? this.deletedOnly;

      final ob = (orderBy ?? this.orderBy).trim();
      final currentOrderBy = _allowedOrderBy.contains(ob) ? ob : 'created_at';

      final so = (sort ?? this.sort).trim().toLowerCase();
      final currentSort = _allowedSort.contains(so) ? so : 'desc';

      final queryParameters = <String, String>{
        'page': currentPage.toString(),
        'pageSize': currentPageSize.toString(),
        if (currentSearch.isNotEmpty) 'search': currentSearch,
        'includeDeleted': currentIncludeDeleted ? '1' : '0',
        'deletedOnly': currentDeletedOnly ? '1' : '0',
        'orderBy': currentOrderBy,
        'sort': currentSort,
      };

      final url = Uri.parse(
        _endpointBase,
      ).replace(queryParameters: queryParameters).toString();

      final response = await _api.fetchDataPrivate(url);

      final List<dynamic> rawList = response['data'] is List
          ? List<dynamic>.from(response['data'])
          : const <dynamic>[];

      final List<Data> mapped = rawList
          .whereType<Map<String, dynamic>>()
          .map(Data.fromJson)
          .toList();

      final dynamic paginationMap = response['pagination'];
      final Pagination? pagination = paginationMap is Map
          ? Pagination.fromJson(Map<String, dynamic>.from(paginationMap))
          : null;

      this.page = pagination?.page ?? currentPage;
      this.pageSize = pagination?.pageSize ?? currentPageSize;
      total = pagination?.total ?? mapped.length;
      totalPages = pagination?.totalPages ?? 1;

      if (!append) {
        items = mapped;
      } else {
        items = [...items, ...mapped];
      }

      this.search = currentSearch;
      this.includeDeleted = currentIncludeDeleted;
      this.deletedOnly = currentDeletedOnly;
      this.orderBy = currentOrderBy;
      this.sort = currentSort;

      error = null;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> refresh() => fetch(page: 1, append: false);

  Future<bool> loadMore() {
    if (loading) return Future.value(false);
    if (page >= totalPages) return Future.value(false);
    return fetch(page: page + 1, append: true);
  }

  Future<bool> applySearch(String value) =>
      fetch(page: 1, search: value, append: false);

  Future<bool> setIncludeDeleted(bool value) =>
      fetch(page: 1, includeDeleted: value, append: false);

  Future<bool> setDeletedOnly(bool value) =>
      fetch(page: 1, deletedOnly: value, append: false);

  Future<bool> setSort({required String orderBy, required String sort}) =>
      fetch(page: 1, orderBy: orderBy, sort: sort, append: false);

  void clear() {
    loading = false;
    error = null;
    items = [];
    page = 1;
    pageSize = 10;
    total = 0;
    totalPages = 1;
    search = '';
    includeDeleted = false;
    deletedOnly = false;
    orderBy = 'created_at';
    sort = 'desc';
    notifyListeners();
  }
}
