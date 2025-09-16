// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationHome extends StatelessWidget {
  const InformationHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 320, // ruang untuk kartu utama + 2 kartu yang “menumpuk”
      child: Stack(
        clipBehavior: Clip.none, // biar tidak terpotong saat keluar batas
        children: [
          // Kartu header (bagian biru)
          Positioned(
            left: 16,
            right: 16,
            top: 0,
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
                      Column(
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
                            "Semangat terus, karena tiap keringet \ndan usaha lo hari ini bakal bawa hasil \nmanis buat besok. 🚀🔥",
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
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bar “Presensi Masuk …”
          Positioned(
            left: 38,
            width: 340,
            top: 237,
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

          // Kartu “Jadwal Kamu Hari Ini” (yang menumpuk di tengah)
          Positioned(
            top: 110,
            left: 27,
            width: 360,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Group login
                        Row(
                          children: [
                            Icon(Icons.login, size: 30),
                            SizedBox(width: 4),
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

                        SizedBox(width: 24), // Jarak antara group
                        // Group logout
                        Row(
                          children: [
                            Icon(Icons.logout, size: 30),
                            SizedBox(width: 4),
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.coffee_outlined),
                        SizedBox(width: 10),
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
        ],
      ),
    );
  }
}
