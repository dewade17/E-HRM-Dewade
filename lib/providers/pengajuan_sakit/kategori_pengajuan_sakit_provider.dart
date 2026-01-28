import 'package:flutter/foundation.dart';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pengajuan_sakit/kategori_pengajuan_sakit.dart' as dto;
import 'package:e_hrm/services/api_services.dart';

class KategoriPengajuanSakitProvider extends ChangeNotifier {
  KategoriPengajuanSakitProvider();

  final ApiService _api = ApiService();

  bool loading = false;
  String? error;

  List<dto.Data> items = <dto.Data>[];

  dto.Data? _selectedKategori;
  dto.Data? get selectedKategori => _selectedKategori;

  int page = 1;
  int pageSize = 10;
  int total = 0;
  int totalPages = 0;

  String search = '';
  bool includeDeleted = false;
  bool deletedOnly = false;
  String orderBy = 'created_at';
  String sort = 'desc';

  void selectKategori(dto.Data? kategori) {
    _selectedKategori = kategori;
    notifyListeners();
  }

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
      final currentOrderBy = orderBy ?? this.orderBy;
      final currentSort = (sort ?? this.sort).toLowerCase() == 'asc'
          ? 'asc'
          : 'desc';

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
        Endpoints.kategoriPengajuanSakit,
      ).replace(queryParameters: queryParameters).toString();

      final response = await _api.fetchDataPrivate(url);

      final List<dynamic> rawList = response['data'] is List
          ? List<dynamic>.from(response['data'])
          : const <dynamic>[];
      final List<dto.Data> mapped = rawList
          .whereType<Map<String, dynamic>>()
          .map(dto.Data.fromJson)
          .toList();

      mapped.sort(
        (a, b) => a.namaKategori.toLowerCase().compareTo(
          b.namaKategori.toLowerCase(),
        ),
      );

      final dynamic paginationMap = response['pagination'];
      final dto.Pagination? pagination = paginationMap is Map
          ? dto.Pagination.fromJson(Map<String, dynamic>.from(paginationMap))
          : null;

      this.page = pagination?.page ?? currentPage;
      this.pageSize = pagination?.pageSize ?? currentPageSize;
      total = pagination?.total ?? mapped.length;
      totalPages = pagination?.totalPages ?? 1;

      if (!append) {
        items = mapped;
      } else {
        items = <dto.Data>[...items, ...mapped];
      }

      this.search = currentSearch;
      this.includeDeleted = currentIncludeDeleted;
      this.deletedOnly = currentDeletedOnly;
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
    if (loading || page >= totalPages) return Future<bool>.value(false);
    return fetch(page: page + 1, append: true);
  }

  Future<bool> applySearch(String value) {
    search = value;
    return fetch(page: 1, append: false);
  }

  Future<bool> setIncludeDeleted(bool value) {
    includeDeleted = value;
    if (value) {
      deletedOnly = false;
    }
    return fetch(page: 1, append: false);
  }

  Future<bool> setDeletedOnly(bool value) {
    deletedOnly = value;
    if (value) {
      includeDeleted = true;
    }
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
    items = <dto.Data>[];
    _selectedKategori = null;
    page = 1;
    pageSize = 10;
    total = 0;
    totalPages = 0;
    search = '';
    includeDeleted = false;
    deletedOnly = false;
    orderBy = 'created_at';
    sort = 'desc';
    notifyListeners();
  }
}
