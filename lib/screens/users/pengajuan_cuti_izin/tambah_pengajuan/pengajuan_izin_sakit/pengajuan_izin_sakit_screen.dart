// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:e_hrm/dto/pengajuan_sakit/pengajuan_sakit.dart' as sakit;
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_sakit/widget/form_pengajuan_sakit.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_sakit/widget/half_oval_pengajuan_sakit.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_sakit/widget/header_pengajuan_sakit.dart';
import 'package:flutter/material.dart';

class PengajuanIzinSakitScreen extends StatefulWidget {
  const PengajuanIzinSakitScreen({super.key, this.initialPengajuan});

  final sakit.Data? initialPengajuan;

  @override
  State<PengajuanIzinSakitScreen> createState() =>
      _PengajuanIzinSakitScreenState();
}

class _PengajuanIzinSakitScreenState extends State<PengajuanIzinSakitScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final iconMax = (math.min(size.width, size.height) * 0.4)
        .clamp(320.0, 360.0)
        .toDouble();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // BG ikon samar di tengah
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    'lib/assets/image/icon_bg.png',
                    width: iconMax,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Image.asset(
                'lib/assets/image/Pattern.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: const HalfOvalPengajuanSakit(height: 40, sigma: 0),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              child: SingleChildScrollView(
                // full width secara horizontal
                padding: const EdgeInsets.fromLTRB(10, 120, 10, 24),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          // height: 700,
                          decoration: BoxDecoration(
                            color: AppColors.textColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.secondaryColor),
                          ),
                          child: FormPengajuanSakit(
                            initialPengajuan: widget.initialPengajuan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 40, left: 10, child: HeaderPengajuanSakit()),
        ],
      ),
    );
  }
}
