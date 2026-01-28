import 'package:flutter/foundation.dart';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pengajuan_cuti/kategori_pengajuan_cuti.dart';
import 'package:e_hrm/services/api_services.dart';

class KategoriCutiProvider extends ChangeNotifier {
  KategoriCutiProvider();

  final ApiService _api = ApiService();

  bool loading = false;
  String? error;

  List<Data> items = [];

  int page = 1;
  int pageSize = 10;
  int total = 0;
  int totalPages = 0;

  String search = '';
  bool includeDeleted = false;
  String orderBy = 'created_at';
  String sort = 'desc';

  void _setLoading(bool value) {
    if (loading == value) return;
    loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    error = message;
    notifyListeners();
  }

  Future<bool> fetch({
    int? page,
    int? pageSize,
    String? search,
    bool? includeDeleted,
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
      final currentOrderBy = orderBy ?? this.orderBy;
      final currentSort = (sort ?? this.sort).toLowerCase() == 'asc'
          ? 'asc'
          : 'desc';

      final queryParameters = <String, String>{
        'page': currentPage.toString(),
        'pageSize': currentPageSize.toString(),
        if (currentSearch.isNotEmpty) 'search': currentSearch,
        'includeDeleted': currentIncludeDeleted ? '1' : '0',
        'orderBy': currentOrderBy,
        'sort': currentSort,
      };

      final url = Uri.parse(
        Endpoints.kategoriCuti,
      ).replace(queryParameters: queryParameters).toString();

      final response = await _api.fetchDataPrivate(url);

      final List<dynamic> rawList = response['data'] is List
          ? List<dynamic>.from(response['data'])
          : [];
      final List<Data> mapped = rawList
          .whereType<Map<String, dynamic>>()
          .map(Data.fromJson)
          .toList();

      mapped.sort(
        (a, b) => a.namaKategori.toLowerCase().compareTo(
          b.namaKategori.toLowerCase(),
        ),
      );

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
      this.orderBy = currentOrderBy;
      this.sort = currentSort;
      error = null;

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> refresh() => fetch(page: 1, append: false);

  Future<bool> loadMore() {
    if (loading || page >= totalPages) return Future.value(false);
    return fetch(page: page + 1, append: true);
  }

  Future<bool> applySearch(String value) {
    search = value;
    return fetch(page: 1, append: false);
  }

  Future<bool> setIncludeDeleted(bool value) {
    includeDeleted = value;
    return fetch(page: 1, append: false);
  }

  Future<bool> setSort({required String orderBy, required String sort}) {
    this.orderBy = orderBy;
    this.sort = sort;
    return fetch(page: 1, append: false);
  }

  void reset() {
    loading = false;
    error = null;
    items = [];
    page = 1;
    pageSize = 10;
    total = 0;
    totalPages = 0;
    search = '';
    includeDeleted = false;
    orderBy = 'created_at';
    sort = 'desc';
    notifyListeners();
  }
}
