//screens/users/agenda_kerja/edit_agenda/edit_agenda_screen.dart
import 'dart:math' as math;
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/agenda_kerja/edit_agenda/widget/form_agenda_edit.dart';
import 'package:e_hrm/screens/users/agenda_kerja/edit_agenda/widget/half_oval_painter_agenda_edit.dart';
import 'package:e_hrm/screens/users/agenda_kerja/edit_agenda/widget/header_edit_agenda.dart';
import 'package:flutter/material.dart';

class EditAgendaScreen extends StatefulWidget {
  const EditAgendaScreen({super.key, required this.agendaKerjaId});

  final String agendaKerjaId;
  @override
  State<EditAgendaScreen> createState() => _EditAgendaScreenState();
}

class _EditAgendaScreenState extends State<EditAgendaScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final iconMax = (math.min(size.width, size.height) * 0.4).clamp(
      320.0,
      360.0,
    );

    return Scaffold(
      body: Stack(
        children: [
          // BG ikon samar di tengah
          SafeArea(
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
          // Pattern full layar
          Positioned.fill(
            child: Image.asset(
              'lib/assets/image/Pattern.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 300,
            child: CustomPaint(painter: HalfOvalPainterAgendaEdit()),
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
                          child: FormAgendaEdit(
                            agendaKerjaId: widget.agendaKerjaId,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(top: 30, left: 10, child: HeaderEditAgenda()),
        ],
      ),
    );
  }
}
