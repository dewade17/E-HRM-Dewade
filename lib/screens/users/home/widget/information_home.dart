// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationHome extends StatelessWidget {
  const InformationHome({super.key});

  @override
  Widget build(BuildContext context) {
    // LANGKAH 1: Dapatkan ukuran layar perangkat
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    // Definisikan beberapa variabel untuk memudahkan pengaturan
    final double cardHorizontalPadding =
        screenWidth * 0.05; // 5% padding di kiri & kanan
    final double mainCardWidth = screenWidth - (2 * cardHorizontalPadding);

    return Container(
      // DIHAPUS: SizedBox dengan tinggi tetap (height: 320)
      // BIARKAN: Container ini menyesuaikan tingginya dengan konten di dalamnya
      margin: const EdgeInsets.only(
        bottom: 30,
      ), // Memberi sedikit jarak di bawah
      height: 300, // Memberi tinggi yang cukup untuk semua elemen
      child: Stack(
        clipBehavior: Clip.none, // biar tidak terpotong saat keluar batas
        alignment: Alignment.center, // Pusatkan semua elemen dalam Stack
        children: [
          // Kartu header (bagian biru)
          Positioned(
            top: 0,
            left: cardHorizontalPadding,
            right: cardHorizontalPadding,
            child: SizedBox(
              height: 180,
              child: Card(
                elevation: 5,
                color: AppColors.primaryColor.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'lib/assets/image/icon_home.png',
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 20),
                      // Gunakan Expanded agar teks tidak overflow di layar kecil
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "One Step Solution (OSS) Bali",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Semangat terus, karena tiap keringet dan usaha lo hari ini bakal bawa hasil manis buat besok. 🚀🔥",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Kartu “Jadwal Kamu Hari Ini” (yang menumpuk di tengah)
          Positioned(
            top:
                140, // Posisi ini masih bisa statis karena tumpukannya vertikal
            width: mainCardWidth * 0.95, // Lebarnya 95% dari kartu utama
            child: Card(
              elevation: 5,
              color: AppColors.accentColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Jadwal Kamu Hari Ini",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Gunakan FittedBox agar tulisan jam mengecil jika tidak muat
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Group login
                          Row(
                            children: [
                              const Icon(Icons.login, size: 30),
                              const SizedBox(width: 4),
                              Text(
                                "09:00",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24), // Jarak antara group
                          // Group logout
                          Row(
                            children: [
                              const Icon(Icons.logout, size: 30),
                              const SizedBox(width: 4),
                              Text(
                                "18:00",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.coffee_outlined),
                        const SizedBox(width: 10),
                        Text(
                          "12.00 - 15.00 (60 menit)",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textDefaultColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bar “Presensi Masuk …”
          Positioned(
            bottom: -25, // Posisi di paling bawah stack
            width: mainCardWidth * 0.9, // Lebar 90% dari kartu utama
            child: Card(
              elevation: 5,
              color: AppColors.primaryColor.withOpacity(0.7),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, color: AppColors.accentColor),
                    const SizedBox(width: 8),
                    Text(
                      "Presensi Masuk, 25 Agt 2025 (08.45)",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
