import 'dart:math' as math;
import 'package:e_hrm/dto/pengajuan_izin_jam/pengajuan_izin_jam.dart' as dto;
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_pengajuan_izin_jam/widget/content_detail_izin_jam.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_pengajuan_izin_jam/widget/header_detail_izin_jam.dart';
import 'package:flutter/material.dart';

class DetailPengajuanIzinJam extends StatefulWidget {
  const DetailPengajuanIzinJam({super.key, this.pengajuan});

  final dto.Data? pengajuan;

  @override
  State<DetailPengajuanIzinJam> createState() => _DetailPengajuanIzinJamState();
}

class _DetailPengajuanIzinJamState extends State<DetailPengajuanIzinJam> {
  @override
  Widget build(BuildContext context) {
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

          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              child: SingleChildScrollView(
                // full width secara horizontal
                padding: const EdgeInsets.fromLTRB(10, 80, 10, 24),
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
                          child: (widget.pengajuan != null)
                              ? ContentDetailIzinJam(
                                  data: widget.pengajuan!,
                                ) // <-- KIRIM DATA DI SINI
                              : const Center(
                                  child: Text("Data tidak ditemukan"),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 40, left: 10, child: HeaderDetailIzinJam()),
        ],
      ),
    );
  }
}
