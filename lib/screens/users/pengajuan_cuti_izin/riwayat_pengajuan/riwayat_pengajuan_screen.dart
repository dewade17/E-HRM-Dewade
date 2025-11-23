import 'dart:math' as math;

import 'package:e_hrm/providers/riwayat_pengajuan/riwayat_pengajuan_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/widget/content_riwayat_pengajuan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RiwayatPengajuanScreen extends StatefulWidget {
  const RiwayatPengajuanScreen({super.key});

  @override
  State<RiwayatPengajuanScreen> createState() => _RiwayatPengajuanScreenState();
}

class _RiwayatPengajuanScreenState extends State<RiwayatPengajuanScreen> {
  // Fungsi ini dipanggil saat user menarik layar (pull-to-refresh)
  Future<void> _onRefresh() async {
    // Memanggil fetch ulang dari provider.
    // Parameter kosong artinya menggunakan filter yang terakhir aktif di provider.
    await context.read<RiwayatPengajuanProvider>().fetch();
  }

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
          // --- Background Image ---
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

          // --- Konten Utama ---
          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              // RefreshIndicator ditempatkan di sini sebagai parent dari ScrollView
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  // AlwaysScrollableScrollPhysics PENTING agar bisa di-refresh
                  // meskipun kontennya sedikit (tidak memenuhi layar)
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  // full width secara horizontal
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 24),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [ContentRiwayatPengajuan()],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
