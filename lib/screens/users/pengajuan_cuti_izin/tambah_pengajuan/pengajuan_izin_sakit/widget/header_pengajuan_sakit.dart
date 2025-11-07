import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderPengajuanSakit extends StatelessWidget {
  const HeaderPengajuanSakit({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textDefaultColor,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Text(
              "Pengajuan Sakit",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textDefaultColor,
              ),
            ),
            Text(
              "Silahkan mengisi form pengajuan kamu",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDefaultColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
