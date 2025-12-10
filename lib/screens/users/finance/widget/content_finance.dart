import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentFinance extends StatefulWidget {
  const ContentFinance({super.key});

  @override
  State<ContentFinance> createState() => _ContentFinanceState();
}

class _ContentFinanceState extends State<ContentFinance> {
  @override
  Widget build(BuildContext context) {
    // Menggunakan ListView agar jika konten melebihi layar, bisa di-scroll
    // Tambahkan padding di atas agar gambar kartu pertama tidak terpotong
    return SingleChildScrollView(
      child: Column(
        children: [
          // Komponen 1: Reimburse
          FinanceCard(
            title: "Reimburse !",
            subtitle:
                "Semua pengeluaran kerja bisa balik, \ncukup ajukan reimburse disini!",
            imagePath: 'lib/assets/image/finance/reimbursex4.png',
            button1Text: "Ajukan",
            onButton1Pressed: () {
              print("Ajukan Reimburse ditekan");
            },
            button2Text: "Riwayat",
            onButton2Pressed: () {
              print("Riwayat Reimburse ditekan");
            },
          ),

          const SizedBox(height: 20), // Jarak antar kartu
          // Komponen 2: Cash Advance
          FinanceCard(
            title: "Pocket Money !",
            subtitle:
                "Butuh tambahan buat jalanin \nkerjaan? Klaim pocket money easy banget, tinggal klik! ",
            imagePath: 'lib/assets/image/finance/trypocketx4.png',
            button1Text: "Klaim",
            onButton1Pressed: () {},
            button2Text: "Riwayat",
            onButton2Pressed: () {},
          ),

          const SizedBox(height: 30),

          // Komponen 3: Lembur
          FinanceCard(
            title: "Payment !",
            subtitle:
                "Semua pengeluaran kerja bisa balik, cukup ajukan reimburse disini!",
            imagePath: 'lib/assets/image/finance/trypaymentx4.png',
            button1Text: "Request",
            onButton1Pressed: () {},
            button2Text: "Riwayat",
            onButton2Pressed: () {},
          ),
        ],
      ),
    );
  }
}

// ==========================================
// REUSABLE COMPONENT (FinanceCard)
// ==========================================

class FinanceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String button1Text;
  final VoidCallback onButton1Pressed;
  final String button2Text;
  final VoidCallback onButton2Pressed;

  const FinanceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.button1Text,
    required this.onButton1Pressed,
    required this.button2Text,
    required this.onButton2Pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      // PENTING: Clip.none agar gambar bisa 'keluar'
      clipBehavior: Clip.none,
      children: [
        // Lapis 1: Kartu Biru (Container Utama)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(13)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.menuColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.menuColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: onButton1Pressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        foregroundColor: AppColors.menuColor,
                      ),
                      child: Text(button1Text),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: onButton2Pressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        foregroundColor: AppColors.menuColor,
                      ),
                      child: Text(button2Text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Lapis 2: Gambar 3D (Positioned)
        Positioned(
          top: -25.6, // Gambar menonjol ke atas
          right: -3.8,
          child: Image.asset(imagePath, height: 140, fit: BoxFit.contain),
        ),
      ],
    );
  }
}
