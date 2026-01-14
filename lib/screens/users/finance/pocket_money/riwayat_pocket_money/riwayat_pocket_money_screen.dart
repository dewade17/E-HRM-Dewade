import 'dart:math' as math;

import 'package:e_hrm/providers/pocket_money/pocket_money_provider.dart';
import 'package:e_hrm/screens/users/finance/pocket_money/riwayat_pocket_money/widget/content_riwayat_pocket_money.dart';
import 'package:e_hrm/screens/users/finance/pocket_money/riwayat_pocket_money/widget/header_riwayat_pocket_money.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RiwayatPocketMoneyScreen extends StatefulWidget {
  const RiwayatPocketMoneyScreen({super.key});

  @override
  State<RiwayatPocketMoneyScreen> createState() =>
      _RiwayatPocketMoneyScreenState();
}

class _RiwayatPocketMoneyScreenState extends State<RiwayatPocketMoneyScreen> {
  static const int _perPage = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PocketMoneyProvider>().refresh(perPage: _perPage);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<PocketMoneyProvider>().refresh(perPage: _perPage);
  }

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
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(15, 80, 15, 24),
                  child: const ContentRiwayatPocketMoney(),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 40,
            left: 10,
            child: HeaderRiwayatPocketMoney(),
          ),
        ],
      ),
    );
  }
}
