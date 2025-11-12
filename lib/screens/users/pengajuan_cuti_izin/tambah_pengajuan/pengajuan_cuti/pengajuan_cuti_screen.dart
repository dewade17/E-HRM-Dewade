// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/pengajuan_cuti/kategori_cuti_provider.dart';
import 'package:e_hrm/providers/pengajuan_cuti/pengajuan_cuti_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/widget/form_pengajuan_cuti.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/widget/half_oval_pengajuan_cuti.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/widget/header_pengajuan_cuti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PengajuanCutiScreen extends StatefulWidget {
  const PengajuanCutiScreen({super.key});

  @override
  State<PengajuanCutiScreen> createState() => _PengajuanCutiScreenState();
}

class _PengajuanCutiScreenState extends State<PengajuanCutiScreen> {
  bool _historyRequested = false;

  void _ensureHistoryLoaded(BuildContext context) {
    if (_historyRequested) return;
    _historyRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PengajuanCutiProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KategoriCutiProvider()),
        ChangeNotifierProvider(create: (_) => PengajuanCutiProvider()),
      ],
      child: Builder(
        builder: (context) {
          _ensureHistoryLoaded(context);
          final size = MediaQuery.sizeOf(context);
          final iconMax = (math.min(size.width, size.height) * 0.4).clamp(
            320.0,
            360.0,
          );

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
                    child: const HalfOvalPengajuanCuti(height: 40, sigma: 0),
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
                                  border: Border.all(
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                child: const FormPengajuanCuti(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(top: 40, left: 10, child: HeaderPengajuanCuti()),
              ],
            ),
          );
        },
      ),
    );
  }
}
