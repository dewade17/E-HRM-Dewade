import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/pengajuan_reimburse/pengajuan_reimburse_provider.dart';
import 'package:e_hrm/screens/users/finance/reimburse/riwayat_reimburse/widget/content_riwayat_reimburse.dart';
import 'package:e_hrm/screens/users/finance/reimburse/riwayat_reimburse/widget/header_riwayat_reimburse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RiwayatReimburseScreen extends StatefulWidget {
  const RiwayatReimburseScreen({super.key});

  @override
  State<RiwayatReimburseScreen> createState() => _RiwayatReimburseScreenState();
}

class _RiwayatReimburseScreenState extends State<RiwayatReimburseScreen> {
  static const int _perPage = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<PengajuanReimburseProvider>();
      p.refresh(perPage: _perPage);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<PengajuanReimburseProvider>().refresh(perPage: _perPage);
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

          // Pattern background
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
                color: AppColors.primaryColor,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(15, 80, 15, 24),
                  child: const ContentRiwayatReimburse(),
                ),
              ),
            ),
          ),

          const Positioned(top: 40, left: 10, child: HeaderRiwayatReimburse()),
        ],
      ),
    );
  }
}
