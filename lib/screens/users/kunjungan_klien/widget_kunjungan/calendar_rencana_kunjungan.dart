import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan_klien.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarRencanaKunjungan extends StatefulWidget {
  const CalendarRencanaKunjungan({super.key, this.items = const <Data>[]});

  final List<Data> items;

  @override
  State<CalendarRencanaKunjungan> createState() =>
      _CalendarRencanaKunjunganState();
}

class _CalendarRencanaKunjunganState extends State<CalendarRencanaKunjungan>
    with TickerProviderStateMixin {
  static final DateTime _firstDay = DateTime.utc(2000, 1, 1);
  static final DateTime _lastDay = DateTime.utc(2100, 12, 31);

  late DateTime _focused;
  bool _expanded = false;
  Map<DateTime, List<Data>> _eventsByDay = <DateTime, List<Data>>{};
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _focused = DateTime.now();
    _rebuildEventsMap();
  }

  @override
  void didUpdateWidget(covariant CalendarRencanaKunjungan oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuildEventsMap();
  }

  String get _bulanTahun => DateFormat.yMMMM('id_ID').format(_focused);

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

  void _rebuildEventsMap() {
    final map = <DateTime, List<Data>>{};
    for (final item in widget.items) {
      final tanggal = item.tanggal;
      if (tanggal == null) continue;
      final key = DateTime(tanggal.year, tanggal.month, tanggal.day);
      map.putIfAbsent(key, () => <Data>[]).add(item);
    }
    _eventsByDay = map;
  }

  List<Data> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventsByDay[key] ?? const <Data>[];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.textColor,
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Card
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Bagian Kiri: Tombol "Previous"
                  IconButton(
                    onPressed: _goPrev,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Bulan sebelumnya',
                  ),

                  // Bagian Tengah (CENTER): Mengambil sisa ruang dan menempatkan isinya di tengah
                  Expanded(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Ini kuncinya!
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 8),
                        Text(
                          _bulanTahun, // contoh: "September 2025"
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Bagian Kanan: Tombol "Next" dan Indikator Expand
                  Row(
                    mainAxisSize:
                        MainAxisSize.min, // Agar tidak memakan ruang ekstra
                    children: [
                      IconButton(
                        onPressed: _goNext,
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Bulan berikutnya',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Konten Calendar (hide/show)
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
                      child: TableCalendar<Data>(
                        firstDay: _firstDay,
                        lastDay: _lastDay,
                        focusedDay: _focused,
                        locale: 'id_ID',
                        eventLoader: (day) => _getEventsForDay(day),
                        onCalendarCreated: (controller) {
                          _pageController = controller;
                        },
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Bulan',
                        },
                        // non-interaktif geser/swipe; pindah bulan via tombol ‹ ›
                        availableGestures: AvailableGestures.none,
                        headerVisible: false,
                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          leftChevronVisible: false,
                          rightChevronVisible: false,
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(fontWeight: FontWeight.w600),
                          weekendStyle: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: false,
                          isTodayHighlighted: true,
                          todayDecoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 1,
                          markersAlignment: Alignment.bottomCenter,
                          markerDecoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Tidak pakai onDaySelected / marker / eventLoader: UI saja
                        onPageChanged: (day) {
                          // Aman kalau nanti AvailableGestures diubah; sinkronkan header
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
