// lib/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/content_tambah_pengajuan.dart

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/konfigurasi_cuti/konfigurasi_cuti.dart'; // Import DTO
import 'package:e_hrm/providers/konfigurasi_cuti/provider_konfigurasi_cuti.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/pengajuan_cuti_screen.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_jam/pengajuan_izin_jam_screen.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_sakit/pengajuan_izin_sakit_screen.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_tukar_hari/pengajuan_izin_tukar_hari.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ContentTambahPengajuan extends StatefulWidget {
  const ContentTambahPengajuan({super.key});

  @override
  State<ContentTambahPengajuan> createState() => _ContentTambahPengajuanState();
}

class _ContentTambahPengajuanState extends State<ContentTambahPengajuan> {
  bool _konfigurasiRequested = false;

  // List nama bulan agar sesuai dengan format API (Uppercase Indonesia)
  static const List<String> _monthNames = [
    'JANUARI',
    'FEBRUARI',
    'MARET',
    'APRIL',
    'MEI',
    'JUNI',
    'JULI',
    'AGUSTUS',
    'SEPTEMBER',
    'OKTOBER',
    'NOVEMBER',
    'DESEMBER',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_konfigurasiRequested) return;
    _konfigurasiRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<KonfigurasiCutiProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final konfigurasi = context.watch<KonfigurasiCutiProvider>();

    // --- LOGIKA PERBAIKAN DIMULAI ---

    // 1. Ambil bulan saat ini (1-12) dan konversi ke Index (0-11)
    final int currentMonthIndex = DateTime.now().month - 1;
    final String currentMonthName = _monthNames[currentMonthIndex];

    // 2. Cari data yang bulannya COCOK dengan bulan ini
    Data? currentData;
    if (konfigurasi.items.isNotEmpty) {
      try {
        currentData = konfigurasi.items.firstWhere(
          (item) => item.bulan.trim().toUpperCase() == currentMonthName,
          // Jika tidak ketemu (misal data bulan ini belum ada), bisa fallback ke null atau last
          orElse: () => konfigurasi.items.last,
        );
      } catch (_) {
        currentData = null;
      }
    }

    // --- LOGIKA PERBAIKAN SELESAI ---

    final bool hasData = currentData != null;

    final String sisaCutiText = hasData
        ? _formatValue(
            currentData!.koutaCuti,
          ) // Gunakan currentData, bukan latestData
        : (konfigurasi.loading ? '...' : '--');

    final String cutiTabungText = hasData
        ? _formatValue(currentData!.cutiTabung) // Gunakan currentData
        : (konfigurasi.loading ? '...' : '--');

    final String rawStatus = konfigurasi.statusCuti?.trim() ?? '';
    final bool statusActive =
        rawStatus.isNotEmpty && rawStatus.toLowerCase() == 'aktif';

    final Color cutiTabungBackground = statusActive
        ? AppColors.primaryColor.withOpacity(0.6)
        : AppColors.hintColor.withOpacity(0.45);

    final cardChildren = <Widget>[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: 160,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.errorColor.withOpacity(0.6),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sisa Cuti Bulan", // Label diperjelas
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.textDefaultColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sisaCutiText,
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: AppColors.textDefaultColor,
              ),
            ),
          ],
        ),
      ),
    ];

    if (statusActive) {
      cardChildren.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: 160,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: cutiTabungBackground,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Cuti Tabung",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cutiTabungText,
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: cardChildren,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(width: 30, height: 2, color: AppColors.hintColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Pilih Pengajuan",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ),
            Expanded(child: Container(height: 2, color: AppColors.hintColor)),
          ],
        ),
        const SizedBox(height: 20),
        PengajuanCard(
          title: "Pengajuan Cuti",
          subtitle: "Silahkan ajukan cutimu disini!",
          buttonText: "Ajukan",
          backgroundColor: AppColors.textColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PengajuanCutiScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        PengajuanCard(
          title: "Pengajuan Izin Sakit",
          subtitle: "Silahkan ajukan cutimu disini!",
          buttonText: "Ajukan",
          backgroundColor: AppColors.textColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PengajuanIzinSakitScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        PengajuanCard(
          title: "Pengajuan Izin Tukar Hari",
          subtitle: "Silahkan ajukan cutimu disini!",
          buttonText: "Ajukan",
          backgroundColor: AppColors.textColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PengajuanIzinTukarHari(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        PengajuanCard(
          title: "Pengajuan Izin Jam",
          subtitle: "Silahkan ajukan cutimu disini!",
          buttonText: "Ajukan",
          backgroundColor: AppColors.textColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PengajuanIzinJamScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatValue(int value) => value.toString().padLeft(2, '0');
}

class PengajuanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const PengajuanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: 350,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              buttonText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
