// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as dto;
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/pengajuan_cuti/pengajuan_cuti_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_pengajuan_cuti/widget/content_detail_cuti.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_pengajuan_cuti/widget/header_detail_cuti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPengajuanCuti extends StatefulWidget {
  const DetailPengajuanCuti({super.key, this.pengajuan});

  final dto.Data? pengajuan;

  @override
  State<DetailPengajuanCuti> createState() => _DetailPengajuanCutiState();
}

class _DetailPengajuanCutiState extends State<DetailPengajuanCuti> {
  dto.Data? _data;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _data = widget.pengajuan;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLatestDetail();
    });
  }

  Future<void> _fetchLatestDetail() async {
    final id = widget.pengajuan?.idPengajuanCuti;
    if (id == null) return;

    setState(() => _isLoading = true);

    try {
      final latestData = await context
          .read<PengajuanCutiProvider>()
          .fetchDetail(id, useCache: false);

      if (mounted) {
        setState(() {
          if (latestData != null) {
            _data = latestData;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
                onRefresh: _fetchLatestDetail,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 80, 10, 24),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.textColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.secondaryColor,
                              ),
                            ),
                            child: _isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : (_data != null)
                                ? ContentDetailCuti(data: _data!)
                                : const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: Text("Data tidak ditemukan"),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(top: 40, left: 10, child: HeaderDetailCuti()),
        ],
      ),
    );
  }
}
