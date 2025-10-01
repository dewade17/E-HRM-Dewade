import 'dart:math' as math;
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/rencana_kunjungan/widget/content_rencana_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RencanaKunjunganScreen extends StatefulWidget {
  const RencanaKunjunganScreen({super.key});

  @override
  State<RencanaKunjunganScreen> createState() => _RencanaKunjunganScreenState();
}

class _RencanaKunjunganScreenState extends State<RencanaKunjunganScreen> {
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
                onRefresh: () => context
                    .read<KunjunganKlienProvider>()
                    .refreshStatusDiproses(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  // full width secara horizontal
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
                  child: Stack(
                    //saya ingin
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [ContentRencanaKunjungan()],
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
