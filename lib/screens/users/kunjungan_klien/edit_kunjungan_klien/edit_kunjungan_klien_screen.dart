import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/edit_kunjungan_klien/widget/form_edit_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/edit_kunjungan_klien/widget/header_edit_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget/half_oval_pointer_kunjungan.dart';
import 'package:flutter/material.dart';

class EditKunjunganKlienScreen extends StatefulWidget {
  const EditKunjunganKlienScreen({super.key});

  @override
  State<EditKunjunganKlienScreen> createState() =>
      _EditKunjunganKlienScreenState();
}

class _EditKunjunganKlienScreenState extends State<EditKunjunganKlienScreen> {
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
              child: CustomPaint(painter: HalfOvalPainterkunjungan()),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              child: SingleChildScrollView(
                // full width secara horizontal
                padding: const EdgeInsets.fromLTRB(15, 120, 15, 24),
                child: Stack(
                  //saya ingin
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
                          child: FormEditKunjungan(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 30, left: 10, child: HeaderEditKunjungan()),
        ],
      ),
    );
  }
}
