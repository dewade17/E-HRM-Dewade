import 'dart:math' as math;
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/half_oval_painter_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/end_kunjungan/widget/form_end_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/end_kunjungan/widget/header_end_kunjungan.dart';
import 'package:flutter/material.dart';

class EndKunjunganScreen extends StatefulWidget {
  const EndKunjunganScreen({super.key});

  @override
  State<EndKunjunganScreen> createState() => _EndKunjunganScreenState();
}

class _EndKunjunganScreenState extends State<EndKunjunganScreen> {
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
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: const HalfOvalPainterKunjungan(height: 40, sigma: 0),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              child: SingleChildScrollView(
                // full width secara horizontal
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [SizedBox(height: 80), FormEndKunjungan()],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 40, left: 10, child: HeaderEndKunjungan()),
        ],
      ),
    );
  }
}
