import 'dart:async';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/approvers/approvers.dart' as dto;
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';

class ApproversPengajuanProvider extends ChangeNotifier {
  ApproversPengajuanProvider({
    List<String>? initialRoles,
    this.defaultPageSize = 20,
    bool? initialIncludeDeleted,
  }) : roles = (initialRoles?.isNotEmpty ?? false)
           ? List<String>.from(initialRoles!)
           : <String>['HR', 'DIREKTUR', 'OPERASIONAL', 'SUPERADMIN'],
       includeDeleted = initialIncludeDeleted ?? false;

  final int defaultPageSize;
  final ApiService _api = ApiService();

  final List<dto.User> _users = <dto.User>[];
  final Map<String, dto.User> _selectedUserCache = <String, dto.User>{};
  dto.Pagination? _pagination;
  String _search = '';
  List<String> roles;
  bool includeDeleted;

  bool _isLoading = false;
  String? _error;

  final Set<String> selectedRecipientIds = <String>{};

  Timer? _debounce;
  int _requestSeq = 0;

  List<dto.User> get users => List<dto.User>.unmodifiable(_users);
  List<dto.User> get selectedUsers => selectedRecipientIds
      .map((id) => _selectedUserCache[id] ?? _findUserById(id))
      .whereType<dto.User>()
      .toList(growable: false);
  dto.Pagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  bool get canLoadMore =>
      _pagination != null && _pagination!.page < _pagination!.totalPages;

  Future<void> refresh({
    String? search,
    List<String>? newRoles,
    bool? newIncludeDeleted,
    int? pageSize,
  }) async {
    _error = null;
    _users.clear();
    if (search != null) _search = search;
    if (newRoles != null && newRoles.isNotEmpty) {
      roles = List<String>.from(newRoles);
    }
    if (newIncludeDeleted != null) includeDeleted = newIncludeDeleted;

    await _fetch(page: 1, pageSize: pageSize ?? defaultPageSize, append: false);
  }

  Future<void> loadMore() async {
    if (!canLoadMore || _isLoading) return;
    final next = (_pagination?.page ?? 1) + 1;
    await _fetch(
      page: next,
      pageSize: _pagination?.pageSize ?? defaultPageSize,
      append: true,
    );
  }

  void setSearch(
    String value, {
    Duration debounce = const Duration(milliseconds: 350),
  }) {
    _search = value;
    _debounce?.cancel();
    _debounce = Timer(debounce, () {
      refresh(search: _search);
    });
  }

  void toggleSelect(String userId) {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) return;

    if (selectedRecipientIds.remove(trimmed)) {
      _selectedUserCache.remove(trimmed);
    } else {
      selectedRecipientIds.add(trimmed);
      final user = _findUserById(trimmed);
      if (user != null) {
        _selectedUserCache[trimmed] = user;
      }
    }
    notifyListeners();
  }

  void replaceSelection(Iterable<String> userIds, {Iterable<dto.User>? users}) {
    selectedRecipientIds
      ..clear()
      ..addAll(userIds.map((id) => id.trim()).where((id) => id.isNotEmpty));

    if (users != null) {
      for (final user in users) {
        _selectedUserCache[user.idUser] = user;
      }
    }

    notifyListeners();
  }

  void hydrateSelectedUsers(Iterable<dto.User> users) {
    for (final user in users) {
      if (selectedRecipientIds.contains(user.idUser)) {
        _selectedUserCache[user.idUser] = user;
      }
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedRecipientIds.clear();
    _selectedUserCache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetch({
    required int page,
    required int pageSize,
    required bool append,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final seq = ++_requestSeq;

    try {
      final params = <String, String>{
        'roles': roles.join(','),
        if (_search.isNotEmpty) 'search': _search,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'includeDeleted': includeDeleted ? '1' : '0',
      };

      final uri = Uri.parse(
        Endpoints.getApprovers,
      ).replace(queryParameters: params);

      final Map<String, dynamic> jsonMap = await _api.fetchDataPrivate(
        uri.toString(),
      );

      if (seq != _requestSeq) return;

      final parsed = dto.Approvers.fromJson(jsonMap);
      if (!append) {
        _users
          ..clear()
          ..addAll(parsed.users);
      } else {
        _users.addAll(parsed.users);
      }
      _pagination = parsed.pagination;

      for (final user in parsed.users) {
        if (selectedRecipientIds.contains(user.idUser)) {
          _selectedUserCache[user.idUser] = user;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (seq != _requestSeq) return;
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  dto.User? _findUserById(String id) {
    for (final user in _users) {
      if (user.idUser == id) return user;
    }
    return _selectedUserCache[id];
  }
}
