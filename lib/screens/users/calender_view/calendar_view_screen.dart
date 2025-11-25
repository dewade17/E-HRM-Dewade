import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/calendar/calendar_data.dart';
import 'package:e_hrm/providers/calendar/calendar_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CalendarProvider>();
      provider.fetchCalendarData(DateTime.now(), context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Kalender Kegiatan',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDefaultColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildTableCalendar(provider),
              const SizedBox(height: 10),
              Expanded(child: _buildEventList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableCalendar(CalendarProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TableCalendar<CalendarItem>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: provider.focusedDay,
        selectedDayPredicate: (day) =>
            provider.isSameDay(provider.selectedDay, day),
        locale: 'id_ID',
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: GoogleFonts.poppins(color: Colors.red),
          todayDecoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.secondaryColor,
            shape: BoxShape.circle,
          ),
        ),
        eventLoader: (day) => provider.getEventsForDay(day),
        onDaySelected: (selectedDay, focusedDay) {
          provider.onDaySelected(selectedDay, focusedDay);
        },
        onPageChanged: (focusedDay) {
          provider.onPageChanged(focusedDay);
          provider.fetchCalendarData(focusedDay, context: context);
        },
      ),
    );
  }

  Widget _buildEventList(CalendarProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          'Gagal memuat data',
          style: GoogleFonts.poppins(color: Colors.red),
        ),
      );
    }

    final selectedEvents = provider.getEventsForDay(
      provider.selectedDay ?? provider.focusedDay,
    );

    if (selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              "Tidak ada kegiatan",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final item = selectedEvents[index];
        return _buildEventCard(item);
      },
    );
  }

  Widget _buildEventCard(CalendarItem item) {
    Color typeColor = AppColors.secondaryColor;
    IconData typeIcon = Icons.event;

    switch (item.type) {
      case 'cuti':
        typeColor = Colors.orange;
        typeIcon = Icons.beach_access;
        break;
      case 'izin_sakit':
        typeColor = Colors.red;
        typeIcon = Icons.medical_services;
        break;
      case 'izin_jam':
        typeColor = Colors.purple;
        typeIcon = Icons.timer;
        break;
      case 'shift_kerja':
        typeColor = Colors.blue;
        typeIcon = Icons.work;
        break;
      case 'story_planner':
        typeColor = Colors.teal;
        typeIcon = Icons.assignment;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textDefaultColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null && item.description!.isNotEmpty)
              Text(
                item.description!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  "${DateFormat('HH:mm').format(item.start)} - ${DateFormat('HH:mm').format(item.end)}",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
