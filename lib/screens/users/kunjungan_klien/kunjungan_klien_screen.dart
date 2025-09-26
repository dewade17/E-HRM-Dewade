import 'dart:math' as math;

import 'package:e_hrm/screens/users/kunjungan_klien/widget/calendar_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget/content_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget/header_kunjungan.dart';
import 'package:flutter/material.dart';

class KunjunganKlienScreen extends StatefulWidget {
  const KunjunganKlienScreen({super.key});

  @override
  State<KunjunganKlienScreen> createState() => _KunjunganKlienScreenState();
}

class _KunjunganKlienScreenState extends State<KunjunganKlienScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final iconMax = (math.min(size.width, size.height) * 0.4).clamp(
      320.0,
      360.0,
    );

    return Scaffold(
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

          // === Konten utama (scrollable) ===
          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              child: SingleChildScrollView(
                // full width secara horizontal
                padding: const EdgeInsets.fromLTRB(0, 80, 0, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      // Beri jarak 16 pixel di kiri dan kanan
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const CalendarKunjungan(),
                    ),

                    ContentKunjungan(),
                  ],
                ),
              ),
            ),
          ),

          const Positioned(top: 40, left: 10, child: HeaderKunjungan()),
        ],
      ),
    );
  }
}
