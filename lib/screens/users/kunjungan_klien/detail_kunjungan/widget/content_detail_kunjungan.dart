import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/visit_timeline_easy_full.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentDetailKunjungan extends StatefulWidget {
  const ContentDetailKunjungan({super.key});

  @override
  State<ContentDetailKunjungan> createState() => _ContentDetailKunjunganState();
}

class _ContentDetailKunjunganState extends State<ContentDetailKunjungan> {
  @override
  Widget build(BuildContext context) {
    // Tidak ada lagi variabel untuk teks, semua langsung ditulis di dalam widget.
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
                  "Kategori: Kunjungan Rutin",
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
                    'Selesai',
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
                  "Ini adalah contoh deskripsi untuk kunjungan klien. Membahas mengenai progres project dan rencana selanjutnya.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDefaultColor,
                  ),
                ),
                const SizedBox(height: 20),
                const VisitTimelineEasyFull(
                  startDateText: '01 Oktober 2025',
                  startTimeText: '09.00',
                  startAddress:
                      'Lat: -6.200000, Lng: 106.816666', //reverse opentsreetmap menjadi alamat
                  endDateText: '01 Oktober 2025',
                  endTimeText: '11.30',
                  labelGap: 20,
                  endAddress:
                      'Lat: -6.201234, Lng: 106.823456', //reverse opentsreetmap menjadi alamat
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
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
                SizedBox(height: 10),
                //image.asset lampiran_kunjungan_url
                SizedBox(height: 20),
                Card(
                  //kondisi jika belum disetujui
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 10),
                        Text("Approver"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  //kondisi sudah disetujui
                  color: AppColors.succesColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 10),
                        Text("Approver"),
                      ],
                    ),
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
