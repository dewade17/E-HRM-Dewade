import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarDaftarKunjungan extends StatefulWidget {
  final DateTime? selectedDay;
  final ValueChanged<DateTime?>? onDaySelected;

  const CalendarDaftarKunjungan({
    super.key,
    this.selectedDay,
    this.onDaySelected,
  });

  @override
  State<CalendarDaftarKunjungan> createState() =>
      _CalendarDaftarKunjunganState();
}

class _CalendarDaftarKunjunganState extends State<CalendarDaftarKunjungan>
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
  }

  @override
  void didUpdateWidget(CalendarDaftarKunjungan oldWidget) {
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
  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

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
    final kunjunganProvider = context.watch<KunjunganKlienProvider?>();
    final eventMap = <DateTime, List<Object?>>{};
    if (kunjunganProvider != null) {
      final items = [
        ...kunjunganProvider.berlangsungItems,
        ...kunjunganProvider.selesaiItems,
      ];
      for (final item in items) {
        final tanggal = item.tanggal;
        if (tanggal == null) continue;
        final key = _normalize(tanggal);
        eventMap.putIfAbsent(key, () => <Object?>[]).add(item);
      }
    }

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
                      child: TableCalendar<void>(
                        firstDay: _firstDay,
                        lastDay: _lastDay,
                        focusedDay: _focused,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selected, day),
                        locale: 'id_ID',
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
                          markerDecoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          markersAlignment: Alignment.bottomCenter,
                          markersMaxCount: 3,
                        ),
                        onCalendarCreated: (controller) {
                          _pageController = controller;
                        },
                        eventLoader: (day) =>
                            eventMap[_normalize(day)] ?? const <Object?>[],
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
