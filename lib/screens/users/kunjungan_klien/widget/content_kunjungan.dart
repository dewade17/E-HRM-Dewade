import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/create_kunjungan_klien/create_kunjungan_klien_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentKunjungan extends StatefulWidget {
  const ContentKunjungan({super.key});

  @override
  State<ContentKunjungan> createState() => _ContentKunjunganState();
}

class _ContentKunjunganState extends State<ContentKunjungan> {
  @override
  Widget build(BuildContext context) {
    // 1. Tambahkan Padding di sini untuk memberi jarak dari tepi layar
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Senin, 22 September 2025",
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            // 2. Properti 'width' dihapus agar lebih responsif
            decoration: BoxDecoration(
              color: AppColors.textColor,
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border: const Border(
                top: BorderSide(color: AppColors.primaryColor, width: 1),
                left: BorderSide(color: AppColors.primaryColor, width: 5),
                right: BorderSide(color: AppColors.primaryColor, width: 1),
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(
                    12.0,
                  ), // Padding yang lebih konsisten
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Mulai dari kiri
                    children: [
                      Image.asset(
                        'lib/assets/image/icon_bg.png',
                        fit: BoxFit.cover,
                        width: 130,
                      ),
                      const SizedBox(
                        width: 12,
                      ), // Beri jarak antara gambar dan teks
                      // Gunakan Expanded agar Column mengisi sisa ruang
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sosialisasi SMAN 3 Denpasar", //deskrpisi.kunjungan_kerja
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(width: 8),
                                Text(
                                  "1 September 2025",
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textDefaultColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded),
                                const SizedBox(width: 8),
                                Text(
                                  "08.00 - 10.00 WITA",
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textDefaultColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 3. Gunakan Align untuk meratakan teks ke kanan secara dinamis
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Detail Kunjungan",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textDefaultColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateKunjunganKlienScreen(),
              ),
            );
          },
          child: Container(
            width: 200,
            decoration: BoxDecoration(),
            child: Card(
              color: AppColors.textColor,
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle),
                    SizedBox(width: 10),
                    Text("Tambah Kunjungan"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
