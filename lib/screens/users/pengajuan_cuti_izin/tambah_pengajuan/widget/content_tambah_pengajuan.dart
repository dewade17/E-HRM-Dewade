// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
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
    final latestData = konfigurasi.items.isNotEmpty
        ? konfigurasi.items.last
        : null;
    final bool hasData = latestData != null;
    final String sisaCutiText = hasData
        ? _formatValue(latestData!.koutaCuti)
        : (konfigurasi.loading ? '...' : '--');
    final String cutiTabungText = hasData
        ? _formatValue(latestData!.cutiTabung)
        : (konfigurasi.loading ? '...' : '--');
    final String rawStatus = konfigurasi.statusCuti?.trim() ?? '';
    final bool statusActive =
        rawStatus.isNotEmpty && rawStatus.toLowerCase() == 'aktif';
    final Color cutiTabungBackground = statusActive
        ? AppColors.primaryColor.withOpacity(0.6)
        : AppColors.hintColor.withOpacity(0.45);

    final cardChildren = <Widget>[
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: 160,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.errorColor.withOpacity(0.6),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sisa Cuti Bulan",
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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: 160,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
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
        SizedBox(height: 20),
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

        SizedBox(height: 20),

        PengajuanCard(
          title: "Pengajuan Cuti",
          subtitle: "Silahkan ajukan cutimu disini!",
          buttonText: "Ajukan",
          backgroundColor: AppColors.textColor,
          onPressed: () {
            // Menggunakan Navigator untuk pindah ke halaman baru
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PengajuanCutiScreen()),
            );
          },
        ),
        SizedBox(height: 10),
        PengajuanCard(
          title: "Pengajuan Izin Sakit",
          subtitle: "Silahkan ajukan cutimu disini!",
          buttonText: "Ajukan",
          backgroundColor: AppColors.textColor,
          onPressed: () {
            // Menggunakan Navigator untuk pindah ke halaman baru
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PengajuanIzinSakitScreen(),
              ),
            );
          },
        ),
        SizedBox(height: 10),
        PengajuanCard(
          title: "Pengajuan Izin Tukar Hari",
          subtitle: "Silahkan ajukan cutimu disini!",
          buttonText: "Ajukan",
          backgroundColor: AppColors.textColor,
          onPressed: () {
            // Menggunakan Navigator untuk pindah ke halaman baru
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PengajuanIzinTukarHari()),
            );
          },
        ),
        SizedBox(height: 10),
        PengajuanCard(
          title: "Pengajuan Izin Jam",
          subtitle: "Silahkan ajukan cutimu disini!",
          buttonText: "Ajukan",
          backgroundColor: AppColors.textColor,
          onPressed: () {
            // Menggunakan Navigator untuk pindah ke halaman baru
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PengajuanIzinJamScreen()),
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
    // Ini adalah kode Container yang Anda minta untuk dipisahkan
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: 350,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor, // <- Menggunakan parameter
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Menambahkan ini agar teks rata tengah secara vertikal
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title, // <- Menggunakan parameter
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
              Text(
                subtitle, // <- Menggunakan parameter
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onPressed, // <- Menggunakan parameter
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              buttonText, // <- Menggunakan parameter
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
