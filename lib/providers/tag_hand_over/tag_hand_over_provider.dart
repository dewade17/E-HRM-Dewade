import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/tag_hand_over/tag_hand_over.dart' as dto;
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';

class TagHandOverProvider extends ChangeNotifier {
  TagHandOverProvider({int initialPageSize = 20})
    : _defaultPageSize = initialPageSize.clamp(1, 100),
      _pageSize = initialPageSize.clamp(1, 100);

  final ApiService _api = ApiService();

  bool _loading = false;
  String? _error;

  final List<dto.Data> _items = <dto.Data>[];
  dto.Pagination? _pagination;

  int _page = 1;
  int _pageSize;
  String _query = '';
  int _requestId = 0;

  final int _defaultPageSize;

  final Set<String> _selectedIds = <String>{};
  final Map<String, dto.Data> _selectedCache = <String, dto.Data>{};

  bool get loading => _loading;
  String? get error => _error;
  List<dto.Data> get items => List<dto.Data>.unmodifiable(_items);
  dto.Pagination? get pagination => _pagination;
  int get page => _pagination?.page ?? _page;
  int get pageSize => _pagination?.pageSize ?? _pageSize;
  int get total => _pagination?.total ?? _items.length;
  int get totalPages => _pagination?.totalPages ?? 1;
  String get query => _query;

  bool get hasMore {
    final pg = _pagination;
    if (pg == null) return false;
    return pg.page < pg.totalPages;
  }

  List<dto.Data> get selectedUsers => _selectedIds
      .map((id) => _selectedCache[id] ?? _findUserById(id))
      .whereType<dto.Data>()
      .toList(growable: false);

  Set<String> get selectedUserIds => Set<String>.unmodifiable(_selectedIds);

  Future<bool> refresh({String? query, int? pageSize}) {
    return _fetch(
      page: 1,
      pageSize: pageSize ?? _pageSize,
      query: query ?? _query,
      append: false,
    );
  }

  Future<bool> search(String value) {
    final trimmed = value.trim();
    return refresh(query: trimmed);
  }

  Future<bool> loadMore() {
    if (_loading || !hasMore) {
      return Future<bool>.value(false);
    }
    final nextPage = page + 1;
    return _fetch(
      page: nextPage,
      pageSize: pageSize,
      query: _query,
      append: true,
    );
  }

  void toggleSelect(String userId) {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) return;

    if (_selectedIds.remove(trimmed)) {
      _selectedCache.remove(trimmed);
    } else {
      _selectedIds.add(trimmed);
      final user = _findUserById(trimmed);
      if (user != null) {
        _selectedCache[trimmed] = user;
      }
    }
    notifyListeners();
  }

  void replaceSelection(Iterable<String> userIds, {Iterable<dto.Data>? users}) {
    _selectedIds
      ..clear()
      ..addAll(userIds.map((id) => id.trim()).where((id) => id.isNotEmpty));

    if (users != null) {
      for (final user in users) {
        _selectedCache[user.idUser] = user;
      }
    }
    notifyListeners();
  }

  void hydrateSelectedUsers(Iterable<dto.Data> users) {
    for (final user in users) {
      if (_selectedIds.contains(user.idUser)) {
        _selectedCache[user.idUser] = user;
      }
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    _selectedCache.clear();
    notifyListeners();
  }

  void reset({bool keepSelection = false}) {
    _items.clear();
    _pagination = null;
    _page = 1;
    _pageSize = _defaultPageSize;
    _query = '';
    _error = null;
    _loading = false;
    if (!keepSelection) {
      _selectedIds.clear();
      _selectedCache.clear();
    }
    notifyListeners();
  }

  Future<bool> _fetch({
    required int page,
    required int pageSize,
    required String query,
    required bool append,
  }) async {
    final int requestId = ++_requestId;

    _loading = true;
    _error = null;
    notifyListeners();

    final sanitizedPage = page < 1 ? 1 : page;
    final sanitizedSize = pageSize.clamp(1, 100);
    final sanitizedQuery = query.trim();

    try {
      final params = <String, String>{
        'page': sanitizedPage.toString(),
        'pageSize': sanitizedSize.toString(),
        if (sanitizedQuery.isNotEmpty) 'q': sanitizedQuery,
      };

      final uri = Uri.parse(
        Endpoints.tagHandOverUsers,
      ).replace(queryParameters: params);

      final response = await _api.fetchDataPrivate(uri.toString());
      if (requestId != _requestId) {
        return false;
      }

      final parsed = dto.TagHandOver.fromJson(
        Map<String, dynamic>.from(response),
      );

      if (!append) {
        _items
          ..clear()
          ..addAll(parsed.data);
      } else {
        final existingIds = _items.map((user) => user.idUser).toList();
        for (final user in parsed.data) {
          final index = existingIds.indexOf(user.idUser);
          if (index >= 0) {
            _items[index] = user;
          } else {
            _items.add(user);
          }
        }
      }

      for (final user in parsed.data) {
        if (_selectedIds.contains(user.idUser)) {
          _selectedCache[user.idUser] = user;
        }
      }

      _pagination = parsed.pagination;
      _page = _pagination?.page ?? sanitizedPage;
      _pageSize = _pagination?.pageSize ?? sanitizedSize;
      _query = sanitizedQuery;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      if (requestId != _requestId) {
        return false;
      }
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      if (requestId == _requestId) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  dto.Data? _findUserById(String id) {
    for (final user in _items) {
      if (user.idUser == id) return user;
    }
    return _selectedCache[id];
  }
}
