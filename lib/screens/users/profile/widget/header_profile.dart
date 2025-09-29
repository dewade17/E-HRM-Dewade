import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderProfile extends StatelessWidget {
  const HeaderProfile({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Text(
              "Form Edit Kunjungan",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
            Text(
              "Silahkan mengedit form data kunjungan",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
