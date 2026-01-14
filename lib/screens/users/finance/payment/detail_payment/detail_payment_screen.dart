import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/payment/payment.dart' as dto;
import 'package:e_hrm/providers/payment/payment_provider.dart';
import 'package:e_hrm/screens/users/finance/payment/detail_payment/widget/content_detail_payment.dart';
import 'package:e_hrm/screens/users/finance/payment/detail_payment/widget/header_detail_payment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPaymentScreen extends StatefulWidget {
  final String idPayment;
  final dto.Data? initialData;

  const DetailPaymentScreen({
    super.key,
    required this.idPayment,
    this.initialData,
  });

  @override
  State<DetailPaymentScreen> createState() => _DetailPaymentScreenState();
}

class _DetailPaymentScreenState extends State<DetailPaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchDetail(widget.idPayment);
    });
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
                  child: ContentDetailPayment(
                    idPayment: widget.idPayment,
                    initialData: widget.initialData,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(top: 40, left: 10, child: HeaderDetailPayment()),
        ],
      ),
    );
  }
}
