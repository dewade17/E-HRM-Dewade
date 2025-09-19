import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/shift_kerja/shift_kerja_realtime.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ShiftKerjaRealtimeProvider extends ChangeNotifier {
  ShiftKerjaRealtimeProvider();

  final ApiService _api = ApiService();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  bool loading = false;
  String? error;
  ShiftKerjaRealTime? result;

  DateTime? selectedDate;
  bool includeDeleted = false;
  String? selectedUserId;
  String? selectedPolaKerjaId;
  int limit = 50;
  String sortDirection = 'asc';

  List<Data> get items =>
      List<Data>.unmodifiable(result?.data ?? const <Data>[]);

  int get total => result?.total ?? 0;

  DateTime? get responseDate => result?.date ?? selectedDate;

  Future<bool> fetch({
    DateTime? date,
    bool? includeDeleted,
    String? idUser,
    String? idPolaKerja,
    int? limit,
    String? sort,
  }) async {
    final requestedDate = date ?? selectedDate ?? DateTime.now();
    final shouldIncludeDeleted = includeDeleted ?? this.includeDeleted;

    final trimmedUser = idUser?.trim();
    final effectiveUserId = (trimmedUser != null && trimmedUser.isNotEmpty)
        ? trimmedUser
        : (selectedUserId != null && selectedUserId!.trim().isNotEmpty
              ? selectedUserId!.trim()
              : null);

    final trimmedPola = idPolaKerja?.trim();
    final effectivePolaKerjaId = (trimmedPola != null && trimmedPola.isNotEmpty)
        ? trimmedPola
        : (selectedPolaKerjaId != null && selectedPolaKerjaId!.trim().isNotEmpty
              ? selectedPolaKerjaId!.trim()
              : null);

    final requestedLimit = limit ?? this.limit;
    final safeLimit = _normalizeLimit(requestedLimit);
    final direction = (sort ?? sortDirection).toLowerCase() == 'desc'
        ? 'desc'
        : 'asc';

    loading = true;
    error = null;
    notifyListeners();

    var success = true;
    try {
      final queryParameters = <String, String>{
        'date': _dateFormatter.format(requestedDate),
        'limit': safeLimit.toString(),
        'sort': direction,
        if (shouldIncludeDeleted) 'includeDeleted': '1',
        if (effectiveUserId != null) 'id_user': effectiveUserId,
      };

      if (effectivePolaKerjaId != null) {
        queryParameters['id_pola_kerja'] = effectivePolaKerjaId;
      }

      final uri = Uri.parse(
        Endpoints.shiftKerjaRealtime,
      ).replace(queryParameters: queryParameters);

      final response = await _api.fetchDataPrivate(uri.toString());
      result = ShiftKerjaRealTime.fromJson(response);

      selectedDate = result?.date ?? requestedDate;
      this.includeDeleted = shouldIncludeDeleted;
      selectedUserId = effectiveUserId;
      selectedPolaKerjaId = effectivePolaKerjaId;
      this.limit = safeLimit;
      sortDirection = direction;
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
    return fetch(
      date: selectedDate,
      includeDeleted: includeDeleted,
      idUser: selectedUserId,
      idPolaKerja: selectedPolaKerjaId,
      limit: limit,
      sort: sortDirection,
    );
  }

  void reset() {
    loading = false;
    error = null;
    result = null;
    selectedDate = null;
    includeDeleted = false;
    selectedUserId = null;
    selectedPolaKerjaId = null;
    limit = 50;
    sortDirection = 'asc';
    notifyListeners();
  }

  int _normalizeLimit(int value) {
    if (value < 1) return 1;
    if (value > 200) return 200;
    return value;
  }
}
