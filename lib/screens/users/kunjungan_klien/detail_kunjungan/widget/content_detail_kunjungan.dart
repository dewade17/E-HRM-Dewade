import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan.dart' as dto;
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/visit_timeline_easy_full.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/edit_kunjungan_klien/edit_kunjungan_klien_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ContentDetailKunjungan extends StatelessWidget {
  const ContentDetailKunjungan({super.key, required this.item});

  final dto.Data item;

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String _formatCoordinate(dynamic lat, dynamic lng) {
    if (lat == null || lng == null) return 'Belum tersedia';
    return 'Lat: ${lat.toString()}, Lng: ${lng.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final endTime = _parseDate(item.jamSelesai);
    final dateFormatter = DateFormat('dd MMMM yyyy');
    final timeFormatter = DateFormat('HH.mm');
    final statusText = endTime == null ? 'Berlangsung' : 'Selesai';
    final startDateText = dateFormatter.format(item.jamMulai);
    final startTimeText = timeFormatter.format(item.jamMulai);
    final endDateText = endTime == null ? '-' : dateFormatter.format(endTime);
    final endTimeText = endTime == null
        ? '--:--'
        : timeFormatter.format(endTime);

    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 120,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditKunjunganKlienScreen(
                        kunjunganId: item.idKunjungan,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: AppColors.primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.create,
                          size: 16,
                          color: AppColors.textColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Edit",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.backgroundColor, AppColors.textColor],
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          width: 350,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kategori: ${item.kategori.kategoriKunjungan}",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDefaultColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 350,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Deskripsi",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDefaultColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.deskripsi,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDefaultColor,
                  ),
                ),
                const SizedBox(height: 20),
                VisitTimelineEasyFull(
                  startDateText: startDateText,
                  startTimeText: startTimeText,
                  startAddress: _formatCoordinate(
                    item.startLatitude,
                    item.startLongitude,
                  ),
                  endDateText: endDateText,
                  endTimeText: endTimeText,
                  labelGap: 20,
                  endAddress: _formatCoordinate(
                    item.endLatitude,
                    item.endLongitude,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
