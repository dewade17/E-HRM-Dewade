import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/finance/pocket_money/add_pocket_money/widget/content_pocket_money.dart';
import 'package:e_hrm/screens/users/finance/pocket_money/add_pocket_money/widget/header_pocket_money.dart';
import 'package:flutter/material.dart';

class PocketMoneyScreen extends StatefulWidget {
  const PocketMoneyScreen({super.key});

  @override
  State<PocketMoneyScreen> createState() => _PocketMoneyScreenState();
}

class _PocketMoneyScreenState extends State<PocketMoneyScreen> {
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
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.secondaryColor),
                  ),
                  child: ContentPocketMoney(),
                ),
              ),
            ),
          ),
          const Positioned(top: 40, left: 10, child: HeaderPocketMoney()),
        ],
      ),
    );
  }
}
