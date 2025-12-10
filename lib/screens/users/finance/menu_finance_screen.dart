import 'dart:math' as math;

import 'package:e_hrm/screens/users/finance/widget/content_finance.dart';
import 'package:e_hrm/screens/users/finance/widget/header_finance.dart';
import 'package:flutter/material.dart';

class MenuFinanceScreen extends StatefulWidget {
  const MenuFinanceScreen({super.key});

  @override
  State<MenuFinanceScreen> createState() => _MenuFinanceScreenState();
}

class _MenuFinanceScreenState extends State<MenuFinanceScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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

          Positioned.fill(
            child: SafeArea(
              left: false,
              right: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(15, 80, 15, 24),
                child: const ContentFinance(),
              ),
            ),
          ),
          const Positioned(top: 40, left: 10, child: HeaderFinance()),
        ],
      ),
    );
  }
}
