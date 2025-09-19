import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/shift_kerja/shift_kerja_realtime.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // --- normalisasi user id ---
    String? effectiveUserId;
    final trimmedUser = idUser?.trim();
    if (trimmedUser != null && trimmedUser.isNotEmpty) {
      effectiveUserId = trimmedUser;
    } else if (selectedUserId != null && selectedUserId!.trim().isNotEmpty) {
      effectiveUserId = selectedUserId!.trim();
    } else {
      // fallback: coba ambil dari SharedPreferences
      effectiveUserId = await _loadUserIdFromPrefs();
    }

    if (effectiveUserId == null || effectiveUserId.isEmpty) {
      loading = false;
      error = 'id_user tidak ditemukan. Pastikan user sudah login/tersimpan.';
      notifyListeners();
      return false;
    }

    // --- normalisasi pola kerja id ---
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
      // id_user dipakai di PATH (bukan query) => tidak perlu duplikasi di query
      final queryParameters = <String, String>{
        'date': _dateFormatter.format(requestedDate),
        'limit': safeLimit.toString(),
        'sort': direction,
        if (shouldIncludeDeleted) 'includeDeleted': '1',
        if (effectivePolaKerjaId != null) 'id_pola_kerja': effectivePolaKerjaId,
      };

      final url = Endpoints.shiftKerjaRealtime(effectiveUserId);
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);

      final response = await _api.fetchDataPrivate(uri.toString());
      result = ShiftKerjaRealTime.fromJson(response);

      // simpan state terakhir
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

  Future<String?> _loadUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('id_user');
      if (stored != null && stored.isNotEmpty) return stored;
    } catch (_) {
      // abaikan error storage
    }
    return null;
  }
}
