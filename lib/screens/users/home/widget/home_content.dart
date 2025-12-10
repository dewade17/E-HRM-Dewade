// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,

      children: [
        HomeMenuItem(
          imagePath: 'lib/assets/image/menu_home/kunjungan.png',
          label: "Kunjungan",
          onTap: () {
            Navigator.pushNamed(context, '/kunjungan-klien');
          },
        ),
        HomeMenuItem(
          imagePath: 'lib/assets/image/menu_home/agendakerja.png',
          label: "Agenda Kerja",
          onTap: () {
            Navigator.pushNamed(context, '/agenda-kerja');
          },
        ),
        HomeMenuItem(
          imagePath: 'lib/assets/image/menu_home/cuti.png',
          label: "Cuti/Izin",
          onTap: () {
            Navigator.pushNamed(context, '/pengajuan-cuti');
          },
        ),
        HomeMenuItem(
          imagePath: 'lib/assets/image/menu_home/istirahat.png',
          label: "Jam Istirahat",
          onTap: () {
            Navigator.pushNamed(context, '/jam-istirahat');
          },
        ),
        HomeMenuItem(
          imagePath: 'lib/assets/image/menu_home/lembur.png',
          label: "Lembur",
          onTap: () {},
        ),
        HomeMenuItem(
          imagePath: 'lib/assets/image/menu_home/finance.png',
          label: "Finance",
          onTap: () {
            Navigator.pushNamed(context, '/finance-karyawan');
          },
        ),
      ],
    );
  }
}

class HomeMenuItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const HomeMenuItem({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        // KITA UBAH UKURANNYA AGAR MUAT 3 DALAM SATU BARIS
        height: 100,
        width: 100, // <-- LEBAR DIKURANGI
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.hintColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath, // <-- Menggunakan parameter
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8),
            Text(
              label, // <-- Menggunakan parameter
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textDefaultColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
