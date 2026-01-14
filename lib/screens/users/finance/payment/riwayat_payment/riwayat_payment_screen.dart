import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/payment/payment_provider.dart';
import 'package:e_hrm/screens/users/finance/payment/riwayat_payment/widget/content_riwayat_payment.dart';
import 'package:e_hrm/screens/users/finance/payment/riwayat_payment/widget/header_riwayat_payment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RiwayatPaymentScreen extends StatefulWidget {
  const RiwayatPaymentScreen({super.key});

  @override
  State<RiwayatPaymentScreen> createState() => _RiwayatPaymentScreenState();
}

class _RiwayatPaymentScreenState extends State<RiwayatPaymentScreen> {
  static const int _perPage = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().refresh(perPage: _perPage);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<PaymentProvider>().refresh(perPage: _perPage);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final iconMax = (math.min(width, height) * 0.4).clamp(320.0, 360.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    'lib/assets/image/icon_bg.png',
                    width: iconMax,
                    fit: BoxFit.contain,
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
                color: AppColors.primaryColor,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(15, 80, 15, 24),
                  child: const ContentRiwayatPayment(),
                ),
              ),
            ),
          ),
          const Positioned(top: 40, left: 10, child: HeaderRiwayatPayment()),
        ],
      ),
    );
  }
}
