// lib/screens/users/kunjungan_klien/detail_kunjungan/widget/content_detail_kunjungan.dart

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan_klien.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/visit_timeline_easy_full.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentDetailKunjungan extends StatelessWidget {
  const ContentDetailKunjungan({
    super.key,
    required this.kategori,
    required this.durationText,
    required this.deskripsi,
    required this.startDateText,
    required this.startTimeText,
    required this.startAddress,
    required this.endDateText,
    required this.endTimeText,
    required this.endAddress,
    this.lampiranUrl,
    this.reports = const <KunjunganReportRecipient>[],
  });

  final String kategori;
  final String durationText;
  final String deskripsi;
  final String startDateText;
  final String startTimeText;
  final String startAddress;
  final String endDateText;
  final String endTimeText;
  final String endAddress;
  final String? lampiranUrl;
  final List<KunjunganReportRecipient> reports;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  "Kategori: $kategori",
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
                    durationText,
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
                  "Keterangan",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDefaultColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  deskripsi,
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
                  startAddress: startAddress,
                  endDateText: endDateText,
                  endTimeText: endTimeText,
                  labelGap: 20,
                  endAddress: endAddress,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text(
                      "Bukti Kunjungan",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (lampiranUrl != null && lampiranUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      lampiranUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: AppColors.backgroundColor,
                        alignment: Alignment.center,
                        child: Text(
                          'Gagal memuat gambar',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textDefaultColor,
                          ),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          alignment: Alignment.center,
                          color: AppColors.backgroundColor,
                          child: const CircularProgressIndicator(),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tidak ada bukti kunjungan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ..._buildReportWidgets(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildReportWidgets() {
    if (reports.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 10),
                Text("Belum ada approver", style: GoogleFonts.poppins()),
              ],
            ),
          ),
        ),
      ];
    }

    return reports.map((report) {
      final status = report.status?.toLowerCase() ?? '';
      final isApproved = status == 'approved' || status == 'disetujui';
      final backgroundColor = isApproved ? AppColors.succesColor : null;
      final textColor = isApproved ? Colors.white : AppColors.textDefaultColor;
      final name = report.recipientNamaSnapshot;
      final role = report.recipientRoleSnapshot;
      final label = () {
        if (name != null && name.isNotEmpty) {
          if (role != null && role.isNotEmpty) {
            return '$name ($role)';
          }
          return name;
        }
        if (role != null && role.isNotEmpty) {
          return role;
        }
        return 'Approver';
      }();

      return Card(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Icon(Icons.person, color: isApproved ? Colors.white : null),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(color: textColor),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
