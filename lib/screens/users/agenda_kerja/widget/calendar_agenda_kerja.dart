import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/agenda_kerja/agenda_kerja.dart' show Data;
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarAgendaKerja extends StatefulWidget {
  const CalendarAgendaKerja({super.key});

  @override
  State<CalendarAgendaKerja> createState() => _CalendarAgendaKerjaState();
}

class _CalendarAgendaKerjaState extends State<CalendarAgendaKerja> {
  final DateTime _firstDay = DateTime.utc(2000, 1, 1);
  final DateTime _lastDay = DateTime.utc(2100, 12, 31);

  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AgendaKerjaProvider>();
    final initial = provider.currentDate ?? DateTime.now();
    final normalized = _stripTime(initial);
    _focusedDay = normalized;
    _selectedDay = normalized;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final agendaProvider = context.read<AgendaKerjaProvider>();
      if (!agendaProvider.loading && agendaProvider.items.isEmpty) {
        _loadForDate(normalized);
      }
    });
  }

  Future<void> _loadForDate(DateTime date) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<AgendaKerjaProvider>();
    final userId = await resolveUserId(auth, context: context);
    if (userId == null || userId.isEmpty) return;

    final normalized = _stripTime(date);
    await provider.fetchAgendaKerja(
      userId: userId,
      date: normalized,
      status: provider.currentStatus,
      append: false,
    );
  }

  void _syncWithProvider(DateTime? providerDate) {
    if (providerDate == null) return;
    final normalized = _stripTime(providerDate);
    if (_selectedDay == null || !isSameDay(_selectedDay, normalized)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedDay = normalized;
          _focusedDay = normalized;
        });
      });
    }
  }

  Map<DateTime, List<Data>> _groupEvents(List<Data> items) {
    final map = <DateTime, List<Data>>{};
    for (final item in items) {
      final date = item.startDate ?? item.endDate;
      if (date == null) continue;
      final key = _stripTime(date);
      map.putIfAbsent(key, () => <Data>[]).add(item);
    }
    return map;
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgendaKerjaProvider>(
      builder: (context, provider, _) {
        _syncWithProvider(provider.currentDate);
        final events = _groupEvents(provider.items);
        final selected = _selectedDay;

        return Material(
          color: Colors.transparent,
          child: TableCalendar<Data>(
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
            locale: 'id_ID',
            selectedDayPredicate: (day) =>
                selected != null && isSameDay(day, selected),
            eventLoader: (day) => events[_stripTime(day)] ?? const <Data>[],
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronVisible: true,
              rightChevronVisible: true,
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 3),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              final normalized = _stripTime(selectedDay);
              if (_selectedDay == null ||
                  !isSameDay(_selectedDay, normalized)) {
                setState(() {
                  _selectedDay = normalized;
                  _focusedDay = focusedDay;
                });
                _loadForDate(normalized);
              }
            },
            onPageChanged: (focusedDay) {
              final normalized = _stripTime(focusedDay);
              setState(() {
                _focusedDay = normalized;
                _selectedDay = normalized;
              });
              _loadForDate(normalized);
            },
          ),
        );
      },
    );
  }
}
