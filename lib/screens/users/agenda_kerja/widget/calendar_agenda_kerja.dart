import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarAgendaKerja extends StatefulWidget {
  const CalendarAgendaKerja({super.key});

  @override
  State<CalendarAgendaKerja> createState() => _CalendarAgendaKerjaState();
}

class _CalendarAgendaKerjaState extends State<CalendarAgendaKerja> {
  // Batas kalender (sesuaikan kalau perlu)
  final DateTime _firstDay = DateTime.utc(2000, 1, 1);
  final DateTime _lastDay = DateTime.utc(2100, 12, 31);

  // Tanggal yang sedang difokuskan (bulan yang tampil)
  DateTime _focusedDay = DateTime.now();

  // Format tampilan (hanya month; tombol ubah format disembunyikan)
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: TableCalendar(
        // —— Data utama ——
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _focusedDay,

        // —— Format tampilan ——
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},

        // —— Locale (opsional): aktifkan jika app Anda sudah setup 'id_ID'
        // Hapus baris di bawah jika belum pakai lokal Indonesia.
        locale: 'id_ID',

        // —— Header ——
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false, // sembunyikan tombol ganti format
          leftChevronVisible: true,
          rightChevronVisible: true,
        ),

        // —— Hilangkan efek "selected" (hanya tampilkan kalender) ——
        selectedDayPredicate: (day) => false,

        // —— Navigasi bulan (tanpa setState untuk selected) ——
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },

        // —— Sedikit styling ringan (opsional) ——
        daysOfWeekHeight: 24,
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
      ),
    );
  }
}
