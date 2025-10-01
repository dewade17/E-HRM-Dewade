import 'dart:math' as math;

import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/content_detail_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/header_detail_kunjungan.dart';
import 'package:flutter/material.dart';

class DetailKunjunganScreen extends StatefulWidget {
  const DetailKunjunganScreen({super.key});

  @override
  State<DetailKunjunganScreen> createState() => _DetailKunjunganScreenState();
}

class _DetailKunjunganScreenState extends State<DetailKunjunganScreen> {
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
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 50),
                        ContentDetailKunjungan(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 40, left: 10, child: HeaderDetailKunjungan()),
        ],
      ),
    );
  }
}
