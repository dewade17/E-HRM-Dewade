import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderJamIstirahat extends StatelessWidget {
  const HeaderJamIstirahat({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.secondaryColor,
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
              "Jam Istirahat",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.secondTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
