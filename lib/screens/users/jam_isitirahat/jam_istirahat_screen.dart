import 'dart:math' as math;

import 'package:e_hrm/screens/users/jam_isitirahat/widget/content_jam_istirahat.dart';
import 'package:e_hrm/screens/users/jam_isitirahat/widget/header_jam_istirahat.dart';
import 'package:flutter/material.dart';

class JamIstirahatScreen extends StatefulWidget {
  const JamIstirahatScreen({super.key});

  @override
  State<JamIstirahatScreen> createState() => _JamIstirahatScreenState();
}

class _JamIstirahatScreenState extends State<JamIstirahatScreen> {
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
                      children: [ContentJamIstirahat()],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 40, left: 10, child: HeaderJamIstirahat()),
        ],
      ),
    );
  }
}
