import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/calendar/calendar_data.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';

enum CalendarViewScope { personal, global }

class CalendarProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  final List<CalendarItem> _allItems = [];

  final Map<DateTime, List<CalendarItem>> _events = {};
  Map<DateTime, List<CalendarItem>> get events => _events;

  final Set<String> _fetchedMonths = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;

  CalendarViewScope _viewScope = CalendarViewScope.personal;
  CalendarViewScope get viewScope => _viewScope;

  bool get isGlobalView => _viewScope == CalendarViewScope.global;

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(_selectedDay, selected)) {
      _selectedDay = _normalizeDate(selected);
      _focusedDay = focused;
      notifyListeners();
    }
  }

  Future<void> onPageChanged(DateTime focused, {BuildContext? context}) async {
    _focusedDay = focused;
    await fetchCalendarData(focused, context: context);
  }

  List<CalendarItem> getEventsForDay(DateTime day) {
    final normalized = _normalizeDate(day);
    return _events[normalized] ?? [];
  }

  Future<void> toggleViewScope({required BuildContext context}) async {
    _viewScope = _viewScope == CalendarViewScope.global
        ? CalendarViewScope.personal
        : CalendarViewScope.global;
    _clearAllCache();
    await fetchCalendarData(_focusedDay, context: context, forceRefresh: true);
    notifyListeners();
  }

  Future<void> refreshCurrentMonth(BuildContext context) async {
    final key = _monthKey(_focusedDay);
    _fetchedMonths.remove(key);
    _removeMonthFromCache(_focusedDay);
    await fetchCalendarData(_focusedDay, context: context, forceRefresh: true);
  }

  Future<void> fetchCalendarData(
    DateTime targetMonth, {
    BuildContext? context,
    bool forceRefresh = false,
  }) async {
    String? userId;

    if (!isGlobalView) {
      if (context != null) {
        final auth = context.read<AuthProvider>();
        userId = await resolveUserId(auth, context: context);
      } else {
        userId = await loadUserIdFromPrefs();
      }
      if (userId == null) return;
    }

    final monthKey = _monthKey(targetMonth);
    if (!forceRefresh && _fetchedMonths.contains(monthKey)) {
      return;
    }

    if (forceRefresh) {
      _removeMonthFromCache(targetMonth);
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

      final List<CalendarItem> allFetchedItems = [];
      int currentPage = 1;
      int totalPages = 1;

      do {
        final params = <String, String>{
          'from': startDate.toIso8601String(),
          'to': endDate.toIso8601String(),
          'page': currentPage.toString(),
          'perPage': '100',
        };

        if (!isGlobalView) {
          params['user_id'] = userId!;
        }

        final uri = Uri.parse(
          Endpoints.mobileCalendar,
        ).replace(queryParameters: params);

        final response = await _api.fetchDataPrivate(uri.toString());
        final calendarResponse = CalendarResponse.fromJson(response);

        allFetchedItems.addAll(calendarResponse.data);

        totalPages = calendarResponse.meta.totalPages;
        currentPage++;
      } while (currentPage <= totalPages);

      _allItems.addAll(allFetchedItems);
      _groupEventsByDate(allFetchedItems);

      _fetchedMonths.add(monthKey);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _groupEventsByDate(List<CalendarItem> newItems) {
    for (final item in newItems) {
      DateTime current = _normalizeDate(item.start);
      final DateTime end = _normalizeDate(item.end);

      while (current.isBefore(end) || isSameDay(current, end)) {
        final list = _events.putIfAbsent(current, () => <CalendarItem>[]);

        final exists = list.any((e) => e.id == item.id && e.type == item.type);
        if (!exists) {
          list.add(item);
        }

        current = current.add(const Duration(days: 1));
      }
    }
  }

  void _removeMonthFromCache(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final keysToRemove = <DateTime>[];
    for (final key in _events.keys) {
      if (!key.isBefore(start) && !key.isAfter(end)) {
        keysToRemove.add(key);
      }
    }
    for (final k in keysToRemove) {
      _events.remove(k);
    }

    _allItems.removeWhere((item) {
      final s = _normalizeDate(item.start);
      return (!s.isBefore(start) && !s.isAfter(end));
    });
  }

  void _clearAllCache() {
    _events.clear();
    _allItems.clear();
    _fetchedMonths.clear();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthKey(DateTime d) {
    final scope = isGlobalView ? 'global' : 'personal';
    final mm = d.month.toString().padLeft(2, '0');
    return '$scope-${d.year}-$mm';
  }
}
