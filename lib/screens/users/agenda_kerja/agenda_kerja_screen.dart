// screens/users/agenda_kerja/agenda_kerja_screen.dart
import 'dart:math' as math;

import 'package:e_hrm/screens/users/agenda_kerja/edit_agenda/widget/half_oval_painter_agenda_edit.dart';
import 'package:e_hrm/screens/users/agenda_kerja/widget/calendar_agenda_kerja.dart';
import 'package:e_hrm/screens/users/agenda_kerja/widget/content_agenda_kerja.dart';
import 'package:flutter/material.dart';

class AgendaKerjaScreen extends StatefulWidget {
  const AgendaKerjaScreen({super.key});

  @override
  State<AgendaKerjaScreen> createState() => _AgendaKerjaScreenState();
}

class _AgendaKerjaScreenState extends State<AgendaKerjaScreen> {
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

          // === Konten utama (scrollable) ===
          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              child: SingleChildScrollView(
                // full width secara horizontal
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    CalendarAgendaKerja(),
                    SizedBox(height: 24),
                    ContentAgendaKerja(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
