// ignore_for_file: unnecessary_cast, deprecated_member_use

import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as dto;
import 'package:e_hrm/providers/pengajuan_cuti/kategori_cuti_provider.dart';
import 'package:e_hrm/providers/pengajuan_cuti/pengajuan_cuti_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/widget/form_pengajuan_cuti.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/widget/half_oval_pengajuan_cuti.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/widget/header_pengajuan_cuti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_hrm/providers/tag_hand_over/tag_hand_over_provider.dart';

class PengajuanCutiScreen extends StatefulWidget {
  const PengajuanCutiScreen({super.key, this.initialPengajuan});

  final dto.Data? initialPengajuan;

  @override
  State<PengajuanCutiScreen> createState() => _PengajuanCutiScreenState();
}

class _PengajuanCutiScreenState extends State<PengajuanCutiScreen> {
  bool _historyRequested = false;
  bool _detailRequested = false;
  bool _detailLoading = false;
  String? _detailError;
  dto.Data? _pengajuan;
  String? _pengajuanId;

  @override
  void initState() {
    super.initState();
    _pengajuan = widget.initialPengajuan;
    _pengajuanId = widget.initialPengajuan?.idPengajuanCuti;
  }

  @override
  void didUpdateWidget(covariant PengajuanCutiScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPengajuan != oldWidget.initialPengajuan) {
      _pengajuan = widget.initialPengajuan;
      _pengajuanId = widget.initialPengajuan?.idPengajuanCuti ?? _pengajuanId;
    }
  }

  void _ensureHistoryLoaded(BuildContext context) {
    if (_historyRequested) return;
    _historyRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PengajuanCutiProvider>().fetch();
    });
  }

  void _ensureDetailLoaded(BuildContext context) {
    // Cek jika data sudah ada, sedang loading, atau sudah diminta
    if (_pengajuan != null || _detailLoading || _detailRequested) return;

    final id = _extractPengajuanId(context);
    if (id == null || id.isEmpty) return;

    // Tandai sudah diminta agar tidak loop, tapi JANGAN setState di sini
    _detailRequested = true;

    // Pindahkan semua logika state change ke post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Set loading state (aman dilakukan di sini karena build sudah selesai)
      setState(() {
        _detailLoading = true;
        _detailError = null;
      });

      try {
        final provider = context.read<PengajuanCutiProvider>();
        final dto.Data? detail = await provider.fetchDetail(
          id,
          useCache: false,
        );

        if (!mounted) return;
        setState(() {
          if (detail != null) {
            _pengajuan = detail;
          }
          _detailLoading = false;
          if (detail == null && _pengajuan == null) {
            _detailError = 'Data pengajuan cuti tidak ditemukan.';
          } else {
            _detailError = null;
          }
          // Reset flag request agar bisa dicoba lagi jika gagal/perlu refresh
          _detailRequested = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _detailLoading = false;
          if (_pengajuan == null) {
            _detailError = e.toString();
          }
          _detailRequested = false;
        });
      }
    });
  }

  String? _extractPengajuanId(BuildContext context) {
    if (_pengajuanId != null && _pengajuanId!.isNotEmpty) {
      return _pengajuanId;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _pengajuanId = args;
      return _pengajuanId;
    }

    if (args is Map) {
      final map = args as Map<dynamic, dynamic>;
      final dynamic candidate =
          map['pengajuanId'] ?? map['id_pengajuan_cuti'] ?? map['id'];
      if (candidate is String && candidate.isNotEmpty) {
        _pengajuanId = candidate;
        return _pengajuanId;
      }
    }

    return _pengajuanId;
  }

  void _retryFetchDetail(BuildContext context) {
    if (_pengajuanId == null || _pengajuanId!.isEmpty) return;
    _detailRequested = false;
    _ensureDetailLoaded(context);
  }

  Widget _buildFormArea(BuildContext context) {
    if (_detailLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_detailError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat detail pengajuan cuti.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textDefaultColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (_detailError!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _detailError!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.errorColor),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _retryFetchDetail(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: AppColors.textColor,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return FormPengajuanCuti(initialData: _pengajuan);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KategoriCutiProvider()),
        ChangeNotifierProvider(create: (_) => TagHandOverProvider()),
      ],
      child: Builder(
        builder: (context) {
          _ensureHistoryLoaded(context);
          _ensureDetailLoaded(context);
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
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: const HalfOvalPengajuanCuti(height: 40, sigma: 0),
                  ),
                ),
                Positioned.fill(
                  child: SafeArea(
                    left: false,
                    right: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(10, 120, 10, 24),
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
                                child: _buildFormArea(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 40,
                  left: 10,
                  child: HeaderPengajuanCuti(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
