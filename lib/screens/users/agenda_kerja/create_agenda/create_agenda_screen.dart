//screens/users/agenda_kerja/create_agenda/create_agenda_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/agenda_kerja/create_agenda/widget/form_agenda.dart';
import 'package:e_hrm/screens/users/agenda_kerja/create_agenda/widget/half_oval_painter_agenda.dart';
import 'package:e_hrm/screens/users/agenda_kerja/create_agenda/widget/header_create_agenda.dart';
import 'package:flutter/material.dart';

class CreateAgendaScreen extends StatefulWidget {
  const CreateAgendaScreen({super.key});

  @override
  State<CreateAgendaScreen> createState() => _CreateAgendaScreenState();
}

class _CreateAgendaScreenState extends State<CreateAgendaScreen> {
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
              child: CustomPaint(painter: HalfOvalPainterAgenda()),
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
                          child: FormAgenda(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 30, left: 10, child: HeaderCreateAgenda()),
        ],
      ),
    );
  }
}
