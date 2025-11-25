import 'package:flutter/foundation.dart';
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

  List<CalendarItem> _allItems = [];

  Map<DateTime, List<CalendarItem>> _events = {};
  Map<DateTime, List<CalendarItem>> get events => _events;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(_selectedDay, selected)) {
      _selectedDay = selected;
      _focusedDay = focused;
      notifyListeners();
    }
  }

  void onPageChanged(DateTime focused) {
    _focusedDay = focused;
    fetchCalendarData(focused);
  }

  List<CalendarItem> getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _events[normalized] ?? [];
  }

  Future<void> fetchCalendarData(
    DateTime targetMonth, {
    BuildContext? context,
  }) async {
    String? userId;
    if (context != null) {
      final auth = context.read<AuthProvider>();
      userId = await resolveUserId(auth, context: context);
    } else {
      userId = await loadUserIdFromPrefs();
    }

    if (userId == null) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final startDate = DateTime(targetMonth.year, targetMonth.month, 1);
      final endDate = DateTime(targetMonth.year, targetMonth.month + 1, 0);

      final params = {
        'user_id': userId,
        'from': startDate.toIso8601String(),
        'to': endDate.toIso8601String(),
        'page': '1',
        'perPage': '100',
      };

      final uri = Uri.parse(
        Endpoints.mobileCalendar,
      ).replace(queryParameters: params);
      final response = await _api.fetchDataPrivate(uri.toString());

      final calendarResponse = CalendarResponse.fromJson(response);

      _allItems = calendarResponse.data;
      _groupEventsByDate(_allItems);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _groupEventsByDate(List<CalendarItem> items) {
    _events = {};
    for (var item in items) {
      // Menggunakan tanggal mulai sebagai key
      final dateKey = DateTime(
        item.start.year,
        item.start.month,
        item.start.day,
      );

      if (_events[dateKey] == null) {
        _events[dateKey] = [];
      }
      _events[dateKey]!.add(item);

      // Jika event lebih dari 1 hari, tambahkan ke hari-hari berikutnya (opsional, tergantung logika UI)
      // Logika di sini sederhana, hanya map berdasarkan start date untuk marker
    }
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
