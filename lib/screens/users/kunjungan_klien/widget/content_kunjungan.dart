import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/create_kunjungan_klien/create_kunjungan_klien_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/detail_kunjungan_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/edit_kunjungan_klien/edit_kunjungan_klien_screen.dart';
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
        // Ganti widget Stack Anda dengan kode ini
        Stack(
          // clipBehavior.none memungkinkan widget di dalam Stack untuk "keluar" dari batas Stack
          clipBehavior: Clip.none,
          children: [
            // Ini adalah kartu konten utama Anda, tidak ada perubahan di sini
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textColor,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: const Border(
                    top: BorderSide(color: AppColors.primaryColor, width: 1),
                    left: BorderSide(color: AppColors.primaryColor, width: 5),
                    right: BorderSide(color: AppColors.primaryColor, width: 1),
                    // Kita tidak butuh border bawah jika mau ditimpa ikon
                    bottom: BorderSide(color: AppColors.primaryColor, width: 1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'lib/assets/image/icon_bg.png', // Pastikan path gambar benar
                        fit: BoxFit.cover,
                        width: 100, // Sedikit lebih kecil agar lebih seimbang
                        height: 120,
                        // Tambahkan ClipRRect agar gambar memiliki sudut melengkung
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: child,
                              );
                            },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Konsultasi", // Mengganti teks dari gambar
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
                                const Icon(Icons.calendar_month, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "01 September 2025",
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
                                const Icon(Icons.access_time_rounded, size: 18),
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
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DetailKunjunganScreen(),
                                  ),
                                );
                              },
                              child: Align(
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- INI BAGIAN SOLUSINYA ---
            // Widget untuk menempatkan ikon check di tengah border kanan
            Positioned(
              top: 0,
              bottom: 0,
              right:
                  25.0, // Sesuaikan dengan padding horizontal container utama
              child: Transform.translate(
                // Geser ikon ke kanan sebesar setengah dari lebarnya (40 / 2 = 20)
                offset: const Offset(20, 0),
                child: GestureDetector(
                  onTap: () {
                    print("submit di-tap!");
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.green, // Warna hijau seperti di gambar
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
