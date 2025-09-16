import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/agenda/agenda.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';

class AgendaProvider extends ChangeNotifier {
  AgendaProvider();

  final ApiService _api = ApiService();

  bool loading = false;
  String? error;

  List<Data> items = <Data>[];
  Meta? meta;

  int page = 1;
  int perPage = 20;
  String query = '';

  /// Aman terhadap nilai null pada [page] dan [totalPages]
  bool get hasMore {
    final m = meta;
    if (m == null) return false;
    final p = m.page;
    final t = m.totalPages;
    if (p == null || t == null) return false;
    return p < t;
  }

  Future<bool> fetch({
    int? page,
    int? perPage,
    String? search,
    bool append = false,
  }) async {
    final trimmedSearch = (search ?? query).trim();

    var requestedPage =
        page ?? (append ? ((meta?.page ?? this.page) + 1) : this.page);
    if (requestedPage < 1) requestedPage = 1;

    var requestedPerPage = perPage ?? this.perPage;
    if (requestedPerPage < 1) {
      requestedPerPage = 1;
    } else if (requestedPerPage > 100) {
      requestedPerPage = 100;
    }

    loading = true;
    error = null;
    query = trimmedSearch;
    notifyListeners();

    var success = true;
    try {
      final queryParameters = <String, String>{
        'page': requestedPage.toString(),
        'perPage': requestedPerPage.toString(),
        if (trimmedSearch.isNotEmpty) 'q': trimmedSearch,
      };

      final uri = Uri.parse(
        Endpoints.agenda,
      ).replace(queryParameters: queryParameters);

      final res = await _api.fetchDataPrivate(uri.toString());

      final rawItems = res['data'];
      final List<Data> mapped = rawItems is List
          ? rawItems.map<Data>((dynamic e) => _parseAgendaItem(e)).toList()
          : <Data>[];

      Meta? metaValue;
      final metaRaw = res['meta'];
      if (metaRaw is Map<String, dynamic>) {
        metaValue = Meta.fromJson(metaRaw);
      } else if (metaRaw is Map) {
        metaValue = Meta.fromJson(Map<String, dynamic>.from(metaRaw));
      }

      if (append) {
        // Gunakan idAgendaKerja sebagai kunci unik
        final combined = <String, Data>{
          for (final item in items) item.idAgendaKerja: item,
        };
        for (final item in mapped) {
          combined[item.idAgendaKerja] = item;
        }
        items = combined.values.toList();
      } else {
        items = mapped;
      }

      meta = metaValue;
      this.page = metaValue?.page ?? requestedPage;
      this.perPage = metaValue?.perPage ?? requestedPerPage;
    } catch (e) {
      success = false;
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }

    return success;
  }

  Future<bool> refresh() {
    return fetch(page: 1, perPage: perPage, search: query, append: false);
  }

  Future<bool> loadMore() {
    if (loading) return Future<bool>.value(false);

    final m = meta;
    if (m != null) {
      final p = m.page;
      final t = m.totalPages;
      if (p != null && t != null && p >= t) {
        return Future<bool>.value(false);
      }
    }

    final nextPage = m?.page != null ? (m!.page! + 1) : (page + 1);
    return fetch(page: nextPage, perPage: perPage, search: query, append: true);
  }

  Future<bool> applySearch(String value) {
    return fetch(page: 1, perPage: perPage, search: value, append: false);
  }

  void reset() {
    loading = false;
    error = null;
    items = <Data>[];
    meta = null;
    page = 1;
    perPage = 20;
    query = '';
    notifyListeners();
  }

  Data _parseAgendaItem(dynamic raw) {
    if (raw is Data) return raw;
    if (raw is Map<String, dynamic>) {
      return Data.fromJson(raw);
    }
    if (raw is Map) {
      return Data.fromJson(Map<String, dynamic>.from(raw));
    }
    throw Exception('Bentuk data agenda tidak dikenali');
  }
}
