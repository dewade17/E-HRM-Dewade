import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';

class HeaderContentPassword extends StatefulWidget {
  const HeaderContentPassword({super.key});

  @override
  State<HeaderContentPassword> createState() => _HeaderContentPasswordState();
}

class _HeaderContentPasswordState extends State<HeaderContentPassword> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Ubah Kata Sandi",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: AppColors.textDefaultColor,
          ),
        ),
        SizedBox(height: 20),
        Image.asset(
          'lib/assets/image/reset_password/icon_password.png',
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}
