// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/calendar/calendar_data.dart';
import 'package:e_hrm/providers/calendar/calendar_provider.dart';
import 'package:e_hrm/utils/mention_parser.dart';
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
      // Fetch awal
      provider.fetchCalendarData(DateTime.now(), context: context);
    });
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'cuti':
        return Colors.orange;
      case 'izin_sakit':
        return Colors.red;
      case 'izin_jam':
        return Colors.purple;
      case 'shift_kerja':
        return Colors.blue;
      case 'story_planner':
        return Colors.teal;
      default:
        return AppColors.secondaryColor;
    }
  }

  // Fungsi Refresh
  Future<void> _onRefresh() async {
    await context.read<CalendarProvider>().refreshCurrentMonth(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kalender Kegiatan',
          style: GoogleFonts.poppins(
            fontSize: 18,
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
              const Divider(thickness: 1, height: 1, color: Color(0xFFEEEEEE)),

              // Bungkus list event dengan RefreshIndicator
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _buildEventList(provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableCalendar(CalendarProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
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
          eventLoader: (day) => provider.getEventsForDay(day),
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
            defaultTextStyle: GoogleFonts.poppins(),
            todayDecoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            todayTextStyle: GoogleFonts.poppins(
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;
              final itemsToShow = events.take(4).toList();

              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: itemsToShow.map((event) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getEventColor(event.type),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            provider.onDaySelected(selectedDay, focusedDay);
          },
          onPageChanged: (focusedDay) {
            provider.onPageChanged(focusedDay);
            // Fetch data saat bulan berubah
            provider.fetchCalendarData(focusedDay, context: context);
          },
        ),
      ),
    );
  }

  // Mengubah widget ini agar selalu mengembalikan ListView (agar bisa ditarik refresh)
  Widget _buildEventList(CalendarProvider provider) {
    // Selalu gunakan ListView dengan physics always scrollable
    // agar gesture pull-to-refresh bekerja meskipun list kosong/error/loading
    const scrollPhysics = AlwaysScrollableScrollPhysics();

    if (provider.loading) {
      return ListView(
        physics: scrollPhysics,
        children: const [
          SizedBox(height: 100),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (provider.error != null) {
      return ListView(
        physics: scrollPhysics,
        children: [
          const SizedBox(height: 100),
          Center(
            child: Text(
              'Gagal memuat data\n(Tarik untuk coba lagi)',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      );
    }

    final targetDay = provider.selectedDay ?? DateTime.now();
    final selectedEvents = provider.getEventsForDay(targetDay);

    if (selectedEvents.isEmpty) {
      return ListView(
        physics: scrollPhysics,
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 60,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  "Tidak ada kegiatan pada\n${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(targetDay)}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: scrollPhysics,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: selectedEvents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildEventCard(selectedEvents[index]);
      },
    );
  }

  Widget _buildEventCard(CalendarItem item) {
    Color typeColor = _getEventColor(item.type);
    IconData typeIcon = Icons.event;

    final String typeKey = item.type.toLowerCase();
    switch (typeKey) {
      case 'cuti':
        typeIcon = Icons.beach_access;
        break;
      case 'izin_sakit':
        typeIcon = Icons.medical_services;
        break;
      case 'izin_jam':
        typeIcon = Icons.timer;
        break;
      case 'shift_kerja':
        typeIcon = Icons.work;
        break;
      case 'story_planner':
        typeIcon = Icons.assignment;
        break;
    }

    final parsedDescription = item.description != null
        ? MentionParser.convertMarkupToDisplay(item.description!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: typeColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(typeIcon, color: typeColor, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textDefaultColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.status != null)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                item.status!.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (parsedDescription != null &&
                          parsedDescription.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            parsedDescription,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                            maxLines: null,
                          ),
                        ),
                      if (typeKey != 'shift_kerja')
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatTimeRange(item.start, item.end),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    if (start.hour == 0 &&
        start.minute == 0 &&
        end.hour == 0 &&
        end.minute == 0) {
      return "Sepanjang Hari";
    }
    if (start.day != end.day) {
      final fmt = DateFormat('dd MMM HH:mm', 'id_ID');
      return "${fmt.format(start)} - ${fmt.format(end)}";
    }
    final fmtTime = DateFormat('HH:mm', 'id_ID');
    return "${fmtTime.format(start)} - ${fmtTime.format(end)}";
  }
}
