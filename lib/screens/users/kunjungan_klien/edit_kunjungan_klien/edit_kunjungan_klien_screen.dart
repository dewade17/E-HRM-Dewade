import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/edit_kunjungan_klien/widget/form_edit_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/edit_kunjungan_klien/widget/header_edit_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget/half_oval_pointer_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditKunjunganKlienScreen extends StatefulWidget {
  final String kunjunganId;
  const EditKunjunganKlienScreen({super.key, required this.kunjunganId});

  @override
  State<EditKunjunganKlienScreen> createState() =>
      _EditKunjunganKlienScreenState();
}

class _EditKunjunganKlienScreenState extends State<EditKunjunganKlienScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<KunjunganProvider>().fetchDetail(widget.kunjunganId);
    });
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
      body: Consumer<KunjunganProvider>(
        builder: (context, provider, child) {
          final item = provider.byId(widget.kunjunganId);
          final isLoading = provider.isLoading && item == null;
          final error = provider.error;

          Widget content;
          if (isLoading && item == null) {
            content = const Center(child: CircularProgressIndicator());
          } else if (item == null) {
            content = Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Data kunjungan tidak ditemukan.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (error != null)
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => provider.fetchDetail(
                        widget.kunjunganId,
                        forceRefresh: true,
                      ),
                      child: const Text('Muat ulang'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            content = SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(15, 120, 15, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.secondaryColor),
                    ),
                    child: FormEditKunjungan(item: item),
                  ),
                ],
              ),
            );
          }

          return Stack(
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
                  child: CustomPaint(painter: HalfOvalPainterkunjungan()),
                ),
              ),
              Positioned.fill(
                child: SafeArea(left: false, right: false, child: content),
              ),
              const Positioned(top: 30, left: 10, child: HeaderEditKunjungan()),
            ],
          );
        },
      ),
    );
  }
}
