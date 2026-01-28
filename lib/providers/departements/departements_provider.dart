// lib/providers/departements/departements_provider.dart
import 'package:e_hrm/dto/departements/departements.dart';
import 'package:flutter/foundation.dart';
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/services/api_services.dart';

class DepartementProvider extends ChangeNotifier {
  // Tidak pakai injeksi: bikin instance sendiri
  final ApiService _api = ApiService();

  // UI state
  bool loading = false;
  String? error;

  // data
  List<Departements> items = [];

  // pagination & query state
  int page = 1;
  int pageSize = 10;
  int total = 0;
  int totalPages = 0;

  String search = '';
  bool includeDeleted = false;
  String orderBy = 'created_at';
  String sort = 'desc'; // 'asc' | 'desc'

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    error = msg;
    notifyListeners();
  }

  /// Fetch list departement.
  /// Gunakan `append: true` untuk infinite scroll.
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
      final p = page ?? this.page;
      final ps = pageSize ?? this.pageSize;
      final s = (search ?? this.search).trim();
      final inc = includeDeleted ?? this.includeDeleted;
      final ob = orderBy ?? this.orderBy;
      final so = (sort ?? this.sort).toLowerCase() == 'asc' ? 'asc' : 'desc';

      final qp = <String, String>{
        'page': p.toString(),
        'pageSize': ps.toString(),
        if (s.isNotEmpty) 'search': s,
        'includeDeleted': inc ? '1' : '0',
        'orderBy': ob,
        'sort': so,
      };

      // Bangun endpoint path + query (TANPA baseURL)
      final endpoint =
          '${Endpoints.departements}?${Uri(queryParameters: qp).query}';

      final res = await _api.fetchDataPrivate(endpoint);

      // --- Data list -> DTO ---
      final List rawList = (res['data'] as List?) ?? const [];
      final mapped = rawList
          .map(
            (e) => Departements.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      mapped.sort(
        (a, b) => a.namaDepartement.toLowerCase().compareTo(
          b.namaDepartement.toLowerCase(),
        ),
      );

      // --- Pagination -> DTO ---
      final pgMap = (res['pagination'] is Map)
          ? Map<String, dynamic>.from(res['pagination'] as Map)
          : <String, dynamic>{};
      final pg = pgMap.isNotEmpty ? Pagination.fromJson(pgMap) : null;

      // sinkronkan state pagination (fallback ke nilai request)
      this.page = pg?.page ?? p;
      this.pageSize = pg?.pageSize ?? ps;
      total = pg?.total ?? mapped.length;
      totalPages = pg?.totalPages ?? 1;

      // set items
      if (append) {
        items = [...items, ...mapped];
      } else {
        items = mapped;
      }

      _setError(null);
      notifyListeners();
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
