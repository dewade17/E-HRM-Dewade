// blur_half_oval_header.dart
import 'dart:ui'; // ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:e_hrm/contraints/colors.dart';

/// Header setengah-oval yang MEMBURAMKAN konten di belakangnya.
/// - [height] tinggi area blur
/// - [sigma] intensitas blur (Gaussian)
/// - [tintColor] opsional, warna tipis di atas blur agar “berglow”
class HalfOvalPainterKunjungan extends StatelessWidget {
  const HalfOvalPainterKunjungan({
    super.key,
    this.height = 220,
    this.sigma = 16,
    this.tintColor,
  });

  final double height;
  final double sigma;
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipPath(
        clipper: _HalfOvalClipper(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            // Lapisan tipis warna supaya efeknya lebih “kaca beku”
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (tintColor ?? AppColors.primaryColor).withOpacity(0.35),
                  (tintColor ?? AppColors.primaryColor).withOpacity(0.10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Memotong area menjadi kurva setengah-oval seperti di contohmu.
/// Ini menyalin bentuk dari CustomPainter jadi Clipper.
class _HalfOvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 1.2,
        size.width,
        size.height * 0.7,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
