import 'dart:math' as math;

import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/daftar_kunjungan/widget/content_daftar_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DaftarKunjunganScreen extends StatefulWidget {
  const DaftarKunjunganScreen({super.key});

  @override
  State<DaftarKunjunganScreen> createState() => _DaftarKunjunganScreenState();
}

class _DaftarKunjunganScreenState extends State<DaftarKunjunganScreen> {
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
              child: RefreshIndicator(
                onRefresh: () async {
                  final provider = context.read<KunjunganKlienProvider>();
                  await Future.wait([
                    provider.refreshStatusBerlangsung(),
                    provider.refreshStatusSelesai(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  // full width secara horizontal
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 24),
                  child: Stack(
                    //saya ingin
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [ContentDaftarKunjungan()],
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
