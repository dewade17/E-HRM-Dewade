import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:e_hrm/dto/approvers/approvers.dart';
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/services/api_services.dart';

class ApproversProvider extends ChangeNotifier {
  ApproversProvider({
    List<String>? initialRoles,
    this.defaultPageSize = 20,
    bool? initialIncludeDeleted,
  }) : roles = (initialRoles?.isNotEmpty ?? false)
           ? initialRoles!
           : <String>['HR', 'DIREKTUR', 'OPERASIONAL', 'SUPERADMIN'],
       includeDeleted = initialIncludeDeleted ?? false;

  // ===== config =====
  final int defaultPageSize;
  final ApiService _api = ApiService();

  // ===== state =====
  final List<User> _users = <User>[];
  Pagination? _pagination;
  String _search = '';
  List<String> roles; // ['HR','DIREKTUR','OPERASIONAL']
  bool includeDeleted;

  bool _isLoading = false;
  String? _error;

  // chip terpilih
  final Set<String> selectedRecipientIds = <String>{};

  // debounce & race guard
  Timer? _debounce;
  int _requestSeq = 0;

  // ===== getters =====
  List<User> get users => List<User>.unmodifiable(_users);
  Pagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  bool get canLoadMore =>
      _pagination != null && _pagination!.page < _pagination!.totalPages;

  // ===== public API =====
  Future<void> refresh({
    String? search,
    List<String>? newRoles,
    bool? newIncludeDeleted,
    int? pageSize,
  }) async {
    _error = null;
    _users.clear();
    if (search != null) _search = search;
    if (newRoles != null && newRoles.isNotEmpty) roles = newRoles;
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
    if (selectedRecipientIds.contains(userId)) {
      selectedRecipientIds.remove(userId);
    } else {
      selectedRecipientIds.add(userId);
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedRecipientIds.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ===== internal =====
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

      // ApiService.fetchDataPrivate mengharapkan URL absolut (sudah OK)
      final jsonMap = await _api.fetchDataPrivate(uri.toString());

      // drop respons lama jika ada request lebih baru
      if (seq != _requestSeq) return;

      final parsed = Approvers.fromJson(jsonMap);
      if (!append) _users.clear();
      _users.addAll(parsed.users);
      _pagination = parsed.pagination;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (seq != _requestSeq) return;
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
