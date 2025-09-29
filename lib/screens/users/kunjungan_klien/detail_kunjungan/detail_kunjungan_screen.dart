import 'dart:math' as math;

import 'package:e_hrm/providers/kunjungan/kunjungan_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/content_detail_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/header_detail_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailKunjunganScreen extends StatefulWidget {
  final String kunjunganId;

  const DetailKunjunganScreen({super.key, required this.kunjunganId});

  @override
  State<DetailKunjunganScreen> createState() => _DetailKunjunganScreenState();
}

class _DetailKunjunganScreenState extends State<DetailKunjunganScreen> {
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
      body: Consumer<KunjunganProvider>(
        builder: (context, provider, child) {
          final item = provider.byId(widget.kunjunganId);
          final isLoading = provider.isLoading && item == null;
          final error = provider.error;

          Widget bodyContent;
          if (isLoading && item == null) {
            bodyContent = const Center(child: CircularProgressIndicator());
          } else if (item == null) {
            bodyContent = Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Data kunjungan tidak ditemukan.'),
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
            bodyContent = SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 80, 0, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [ContentDetailKunjungan(item: item)],
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
              Positioned.fill(
                child: SafeArea(left: false, right: false, child: bodyContent),
              ),
              const Positioned(
                top: 40,
                left: 10,
                child: HeaderDetailKunjungan(),
              ),
            ],
          );
        },
      ),
    );
  }
}
