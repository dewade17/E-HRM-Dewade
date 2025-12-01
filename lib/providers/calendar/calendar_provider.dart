import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/calendar/calendar_data.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';

class CalendarProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  // Cache raw items
  final List<CalendarItem> _allItems = [];

  // Map Event: Key = Tanggal (tanpa jam), Value = List Event
  final Map<DateTime, List<CalendarItem>> _events = {};
  Map<DateTime, List<CalendarItem>> get events => _events;

  // Cache untuk melacak bulan apa saja yang sudah di-fetch (format: "2023-10")
  final Set<String> _fetchedMonths = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(_selectedDay, selected)) {
      _selectedDay = _normalizeDate(selected);
      _focusedDay = focused;
      notifyListeners();
    }
  }

  void onPageChanged(DateTime focused) {
    _focusedDay = focused;
    // Ambil data bulan baru (jika belum ada di cache)
    fetchCalendarData(focused);
  }

  List<CalendarItem> getEventsForDay(DateTime day) {
    final normalized = _normalizeDate(day);
    return _events[normalized] ?? [];
  }

  /// Refresh manual (dipanggil dari UI Pull-to-Refresh)
  Future<void> refreshCurrentMonth(BuildContext context) async {
    // Hapus cache bulan yang sedang dilihat agar bisa di-fetch ulang
    final monthKey = "${_focusedDay.year}-${_focusedDay.month}";
    _fetchedMonths.remove(monthKey);

    // Panggil fetch dengan forceRefresh: true
    await fetchCalendarData(_focusedDay, context: context, forceRefresh: true);
  }

  Future<void> fetchCalendarData(
    DateTime targetMonth, {
    BuildContext? context,
    bool forceRefresh = false,
  }) async {
    String? userId;
    if (context != null) {
      final auth = context.read<AuthProvider>();
      userId = await resolveUserId(auth, context: context);
    } else {
      userId = await loadUserIdFromPrefs();
    }

    if (userId == null) return;

    // Cek cache: Jika bulan ini sudah diambil & bukan paksaan refresh, skip.
    final monthKey = "${targetMonth.year}-${targetMonth.month}";
    if (!forceRefresh && _fetchedMonths.contains(monthKey)) {
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final startDate = DateTime(targetMonth.year, targetMonth.month, 1);
      final endDate = DateTime(
        targetMonth.year,
        targetMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      // List sementara untuk menampung semua data dari semua halaman
      List<CalendarItem> allFetchedItems = [];
      int currentPage = 1;
      int totalPages = 1;

      // --- LOGIKA LOOPING (RECURSIVE FETCHING) ---
      // Terus minta data selama masih ada halaman selanjutnya
      do {
        final params = {
          'user_id': userId,
          'from': startDate.toIso8601String(),
          'to': endDate.toIso8601String(),
          'page': currentPage.toString(),
          'perPage': '100', // Kita minta 100 per request agar ringan
        };

        final uri = Uri.parse(
          Endpoints.mobileCalendar,
        ).replace(queryParameters: params);

        // Panggil API
        final response = await _api.fetchDataPrivate(uri.toString());
        final calendarResponse = CalendarResponse.fromJson(response);

        // Tambahkan data halaman ini ke list penampung
        allFetchedItems.addAll(calendarResponse.data);

        // Update info halaman dari meta response
        totalPages = calendarResponse.meta.totalPages;
        currentPage++;
      } while (currentPage <= totalPages);
      // ^ Ulangi jika 'currentPage' (yang baru diincrement) masih <= 'totalPages'

      // --- Selesai Looping, baru proses datanya ke memori ---

      // Tambahkan ke list utama
      _allItems.addAll(allFetchedItems);

      // Grouping ulang (HANYA menambah, tidak mereset total)
      _groupEventsByDate(allFetchedItems);

      // Tandai bulan ini sudah selesai di-fetch
      _fetchedMonths.add(monthKey);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _groupEventsByDate(List<CalendarItem> newItems) {
    // PENTING: Jangan lakukan _events = {}; di sini agar data bulan lain tidak hilang.

    for (var item in newItems) {
      DateTime current = _normalizeDate(item.start);
      final DateTime end = _normalizeDate(item.end);

      // Loop setiap hari dari start sampai end event
      // (Penting untuk cuti/sakit berhari-hari agar titik muncul di setiap tanggal)
      while (current.isBefore(end) || isSameDay(current, end)) {
        if (_events[current] == null) {
          _events[current] = [];
        }

        // Cek duplikasi ID agar aman saat refresh
        final exists = _events[current]!.any(
          (e) => e.id == item.id && e.type == item.type,
        );
        if (!exists) {
          _events[current]!.add(item);
        }

        current = current.add(const Duration(days: 1));
      }
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
