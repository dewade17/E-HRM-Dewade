// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_reimburse/pengajuan_reimburse.dart' as dto;
import 'package:e_hrm/providers/pengajuan_reimburse/pengajuan_reimburse_provider.dart';
import 'package:e_hrm/screens/users/finance/reimburse/detail_reimburse/widget/content_detail_reimburse.dart';
import 'package:e_hrm/screens/users/finance/reimburse/detail_reimburse/widget/header_detail_reimburse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailReimburseScreen extends StatefulWidget {
  final String idReimburse;
  final dto.Data? initialData;

  const DetailReimburseScreen({
    super.key,
    required this.idReimburse,
    this.initialData,
  });

  @override
  State<DetailReimburseScreen> createState() => _DetailReimburseScreenState();
}

class _DetailReimburseScreenState extends State<DetailReimburseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengajuanReimburseProvider>().fetchDetail(
        widget.idReimburse,
      );
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
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(15, 80, 15, 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.secondaryColor),
                  ),
                  child: ContentDetailReimburse(
                    idReimburse: widget.idReimburse,
                    initialData: widget.initialData,
                  ),
                ),
              ),
            ),
          ),

          const Positioned(top: 40, left: 10, child: HeaderDetailReimburse()),
        ],
      ),
    );
  }
}
