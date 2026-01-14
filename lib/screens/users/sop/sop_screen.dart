// lib/screens/users/sop/sop_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'widget/header_sop.dart';
import 'widget/content_sop.dart';

class SopScreen extends StatelessWidget {
  const SopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
                child: const ContentSop(),
              ),
            ),
          ),

          const Positioned(top: 50, left: 10, right: 10, child: HeaderSop()),
        ],
      ),
    );
  }
}
