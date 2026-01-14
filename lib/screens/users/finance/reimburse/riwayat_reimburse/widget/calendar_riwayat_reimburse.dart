// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarRiwayatReimburse extends StatefulWidget {
  final DateTime? selectedDay;
  final ValueChanged<DateTime?>? onDaySelected;
  final List<DateTime> markerDates;

  const CalendarRiwayatReimburse({
    super.key,
    this.selectedDay,
    this.onDaySelected,
    this.markerDates = const [],
  });

  @override
  State<CalendarRiwayatReimburse> createState() =>
      _CalendarRiwayatReimburseState();
}

class _CalendarRiwayatReimburseState extends State<CalendarRiwayatReimburse>
    with TickerProviderStateMixin {
  static final DateTime _firstDay = DateTime.utc(2000, 1, 1);
  static final DateTime _lastDay = DateTime.utc(2100, 12, 31);

  late DateTime _focused;
  bool _expanded = false;
  DateTime? _selected;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _focused = DateTime.now();
    _selected = widget.selectedDay;
  }

  @override
  void didUpdateWidget(CalendarRiwayatReimburse oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newSelected = widget.selectedDay;
    if (!isSameDay(oldWidget.selectedDay, newSelected)) {
      setState(() {
        _selected = newSelected;
        if (newSelected != null) {
          _focused = DateTime(
            newSelected.year,
            newSelected.month,
            newSelected.day,
          );
        }
      });
    }
  }

  String get _bulanTahun => DateFormat.yMMMM('id_ID').format(_focused);

  List<DateTime> _getEventsForDay(DateTime day) {
    return widget.markerDates
        .where((eventDate) => isSameDay(eventDate, day))
        .toList();
  }

  void _goPrev() {
    final previousMonth = DateTime(_focused.year, _focused.month - 1, 1);
    setState(() {
      _focused = previousMonth;
    });
    _pageController?.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _goNext() {
    final nextMonth = DateTime(_focused.year, _focused.month + 1, 1);
    setState(() {
      _focused = nextMonth;
    });
    _pageController?.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goPrev,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 8),
                        Text(
                          _bulanTahun,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _goNext,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: TableCalendar<DateTime>(
                        firstDay: _firstDay,
                        lastDay: _lastDay,
                        focusedDay: _focused,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selected, day),
                        locale: 'id_ID',
                        eventLoader: _getEventsForDay,
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Bulan',
                        },
                        availableGestures: AvailableGestures.none,
                        headerVisible: false,
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(fontWeight: FontWeight.w600),
                          weekendStyle: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          isTodayHighlighted: true,
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 1,
                        ),
                        onCalendarCreated: (controller) {
                          _pageController = controller;
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            if (isSameDay(_selected, selectedDay)) {
                              _selected = null;
                            } else {
                              _selected = selectedDay;
                            }
                            _focused = focusedDay;
                          });
                          widget.onDaySelected?.call(_selected);
                        },
                        onPageChanged: (day) {
                          setState(() => _focused = day);
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
