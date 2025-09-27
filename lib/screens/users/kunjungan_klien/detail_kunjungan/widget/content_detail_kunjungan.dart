import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/visit_timeline_easy_full.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/edit_kunjungan_klien/edit_kunjungan_klien_screen.dart';
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
    return SizedBox(
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 100,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditKunjunganKlienScreen(),
                      ),
                    );
                  },
                  child: Card(
                    color: AppColors.primaryColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 9,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.create,
                            size: 15,
                            color: AppColors.textColor,
                          ),
                          SizedBox(width: 10),
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

          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.backgroundColor, AppColors.textColor],
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            width: 350,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Kategori: Sosialisasi",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDefaultColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.textColor,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Center(
                      child: Text(
                        "Berlangsung ",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDefaultColor,
                        ),
                      ),
                    ), //jika sudah selesai maka duration yang muncul
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            // === PERUBAHAN DIMULAI DI SINI ===
            // 1. Tambahkan satu Padding di sini untuk semua konten di dalamnya
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Atur rata kiri untuk semua anak Column
                children: [
                  // Bagian Keterangan
                  Text(
                    "Keterangan : ",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                  Text(
                    "Melakukan sosialisasi di SMA 1 Denpasar dengan lima belas kelas XII, program English Course",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                  const VisitTimelineEasyFull(
                    startDateText: '7 September 2025',
                    startTimeText: '09:30 AM',
                    startAddress:
                        'Jl. Hayam Wuruk No.66b, Panjer, Denpasar Selatan, Kota Denpasar, Bali 80239',
                    endDateText: '7 September 2025',
                    endTimeText: '11.32 AM',
                    labelGap: 20,
                    endAddress:
                        'Jl. Hayam Wuruk No.66b, Panjer, Denpasar Selatan, Kota Denpasar, Bali 80239',
                  ),

                  SizedBox(height: 20), // Beri jarak antara dua bagian
                  // Bagian Bukti Kunjungan
                  Text(
                    "Bukti Kunjungan :",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDefaultColor,
                    ),
                  ),

                  //imagetAseet
                  // Anda bisa tambahkan widget gambar di sini
                  SizedBox(height: 30),
                  Text(
                    "Status Persetujuan :",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                  Card(
                    color: AppColors.succesColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 20),
                          Text(
                            "Ayu HR",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDefaultColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: AppColors.succesColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 20),
                          Text(
                            "Mesy",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDefaultColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
            // === PERUBAHAN SELESAI DI SINI ===
          ),
        ],
      ),
    );
  }
}
