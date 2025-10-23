import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Memberi sedikit warna latar belakang agar tidak terlalu polos
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gambar maintenance
              Image.asset(
                'lib/assets/image/Maintenance.png',
                width: 250, // Perbesar gambar agar lebih terlihat
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),

              // Judul
              Text(
                "Segera Hadir!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),

              // Deskripsi
              Text(
                "Fitur ini sedang dalam pengembangan. Kami bekerja keras untuk menyiapkannya untuk Anda.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.secondTextColor,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
