import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan.dart' as dto;
import 'package:e_hrm/providers/kunjungan/kunjungan_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/create_kunjungan_klien/create_kunjungan_klien_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/detail_kunjungan_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentKunjungan extends StatefulWidget {
  const ContentKunjungan({super.key});

  @override
  State<ContentKunjungan> createState() => _ContentKunjunganState();
}

class _ContentKunjunganState extends State<ContentKunjungan> {
  Future<Position> _getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location Services mati. Aktifkan terlebih dulu.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _handleSubmit(BuildContext context, dto.Data item) async {
    final provider = context.read<KunjunganProvider>();
    if (provider.isMutating(item.idKunjungan)) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final position = await _getCurrentPosition();
      final now = DateTime.now();
      final result = await provider.submitKunjungan(item.idKunjungan, {
        'jam_selesai': now,
        'end_latitude': position.latitude,
        'end_longitude': position.longitude,
      });

      if (!context.mounted) return;

      if (result != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Kunjungan berhasil disubmit.')),
        );
      } else {
        final message = provider.lastMessage ?? provider.error;
        messenger.showSnackBar(
          SnackBar(content: Text(message ?? 'Gagal submit kunjungan.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal mengambil lokasi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEEE, dd MMMM yyyy');
    final timeFormatter = DateFormat('HH.mm');

    return Consumer<KunjunganProvider>(
      builder: (context, provider, child) {
        final items = provider.items;
        final isLoading = provider.isLoading && items.isEmpty;
        final error = provider.error;

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (error != null && items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                Text(
                  'Gagal memuat daftar kunjungan.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Belum ada kunjungan yang tercatat.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDefaultColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            for (final item in items) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 30,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dateFormatter.format(item.tanggal),
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              _VisitCard(
                item: item,
                isSubmitting: provider.isMutating(item.idKunjungan),
                onSubmit: () => _handleSubmit(context, item),
                timeFormatter: timeFormatter,
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateKunjunganKlienScreen(),
                  ),
                );
              },
              child: SizedBox(
                width: 200,
                child: Card(
                  color: AppColors.textColor,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle),
                        const SizedBox(width: 10),
                        Text(
                          "Tambah Kunjungan",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDefaultColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.item,
    required this.isSubmitting,
    required this.onSubmit,
    required this.timeFormatter,
  });

  final dto.Data item;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final DateFormat timeFormatter;

  DateTime? _parseOptionalDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final endTime = _parseOptionalDate(item.jamSelesai);
    final timeRange =
        '${timeFormatter.format(item.jamMulai)} - ${endTime == null ? '--:--' : timeFormatter.format(endTime)}';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.textColor,
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border: const Border(
                top: BorderSide(color: AppColors.primaryColor, width: 1),
                left: BorderSide(color: AppColors.primaryColor, width: 5),
                right: BorderSide(color: AppColors.primaryColor, width: 1),
                bottom: BorderSide(color: AppColors.primaryColor, width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'lib/assets/image/icon_bg.png',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 120,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: child,
                          );
                        },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.kategori.kategoriKunjungan,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd MMM yyyy').format(item.tanggal),
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textDefaultColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '$timeRange WITA',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textDefaultColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailKunjunganScreen(
                                  kunjunganId: item.idKunjungan,
                                ),
                              ),
                            );
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Detail Kunjungan",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textDefaultColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (endTime == null)
          Positioned(
            top: 0,
            bottom: 0,
            right: 25.0,
            child: Transform.translate(
              offset: const Offset(20, 0),
              child: GestureDetector(
                onTap: isSubmitting ? null : onSubmit,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: isSubmitting
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.check, color: Colors.white, size: 24),
                ),
              ),
            ),
          )
        else
          Positioned(
            top: 12,
            right: 0,
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade400,
              size: 28,
            ),
          ),
      ],
    );
  }
}
