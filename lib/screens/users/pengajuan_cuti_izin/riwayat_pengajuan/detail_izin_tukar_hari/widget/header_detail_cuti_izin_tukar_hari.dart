import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderDetailCutiIzinTukarHari extends StatelessWidget {
  const HeaderDetailCutiIzinTukarHari({super.key});

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
            Text(
              "Detail Pengajuan Izin Tukar Hari",
              style: GoogleFonts.poppins(
                fontSize: 17,
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
