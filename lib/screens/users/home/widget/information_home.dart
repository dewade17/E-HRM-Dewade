// lib/screens/users/home/widget/information_home.dart

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/absensi/absensi_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/providers/shift_kerja/shift_kerja_realtime_provider.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InformationHome extends StatefulWidget {
  const InformationHome({super.key});

  @override
  State<InformationHome> createState() => _InformationHomeState();
}

class _InformationHomeState extends State<InformationHome> {
  @override
  void initState() {
    super.initState();
    // Memuat data setelah frame pertama selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;

    // 1. Dapatkan ID pengguna
    final auth = context.read<AuthProvider>();
    final userId = await resolveUserId(auth, context: context);
    if (userId == null || userId.isEmpty) {
      return; // Tidak melakukan apa-apa jika user ID tidak ada
    }

    // 2. Panggil provider untuk mengambil data jadwal kerja
    // Provider absensi sudah dipanggil oleh AbsensiButton, jadi kita tidak perlu panggil lagi.
    final shiftProvider = context.read<ShiftKerjaRealtimeProvider>();
    await shiftProvider.fetch(idUser: userId, date: DateTime.now());
  }

  /// Helper untuk memformat waktu dari string ISO 8601 atau format jam saja
  String _formatShiftTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return '--:--';
    try {
      // Coba parse sebagai DateTime penuh (ISO 8601)
      final dt = DateTime.parse(rawTime).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      // Jika gagal, coba parse sebagai "HH:mm:ss"
      try {
        final parts = rawTime.split(':');
        if (parts.length >= 2) {
          final hh = parts[0].padLeft(2, '0');
          final mm = parts[1].padLeft(2, '0');
          return '$hh:$mm';
        }
      } catch (_) {}
    }
    return '--:--'; // Fallback jika semua parsing gagal
  }

  /// Helper untuk membangun teks status presensi terakhir
  Widget _buildPresensiWidget(AbsensiProvider absProvider) {
    if (absProvider.loadingStatus) {
      return const SizedBox(
        height: 14,
        width: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    final status = absProvider.todayStatus;
    final formatter = DateFormat('dd MMM yyyy (HH:mm)', 'id_ID');
    String text = "Belum ada presensi hari ini";
    IconData icon = Icons.info_outline;

    if (status?.jamPulang != null) {
      text =
          "Presensi Pulang, ${formatter.format(status!.jamPulang!.toLocal())}";
      icon = Icons.logout;
    } else if (status?.jamMasuk != null) {
      text = "Presensi Masuk, ${formatter.format(status!.jamMasuk!.toLocal())}";
      icon = Icons.login;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.accentColor, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.accentColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final cardHorizontalPadding = screenWidth * 0.05;
    final mainCardWidth = screenWidth - (2 * cardHorizontalPadding);

    // Dapatkan data dari provider
    final shiftProvider = context.watch<ShiftKerjaRealtimeProvider>();
    final absensiProvider = context.watch<AbsensiProvider>();

    // Ekstrak data jadwal
    final isLoadingJadwal = shiftProvider.loading;
    final jadwal = shiftProvider.items.isNotEmpty
        ? shiftProvider.items.first
        : null;
    final jamMulai = _formatShiftTime(jadwal?.polaKerja?.jamMulai);
    final jamSelesai = _formatShiftTime(jadwal?.polaKerja?.jamSelesai);
    final jamIstirahatMulai = _formatShiftTime(
      jadwal?.polaKerja?.jamIstirahatMulai,
    );
    final jamIstirahatSelesai = _formatShiftTime(
      jadwal?.polaKerja?.jamIstirahatSelesai,
    );
    final maksIstirahat = jadwal?.polaKerja?.maksJamIstirahat;

    // --- LOGIKA BARU UNTUK PENGECEKAN LIBUR ---
    final isLibur =
        (jadwal?.status.toUpperCase() == 'LIBUR') ||
        (jadwal?.polaKerja?.jamMulai == null &&
            jadwal?.polaKerja?.jamSelesai == null &&
            jadwal?.polaKerja?.jamIstirahatMulai == null &&
            jadwal?.polaKerja?.jamIstirahatSelesai == null);

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Kartu header (biru)
          Positioned(
            top: 0,
            left: cardHorizontalPadding,
            right: cardHorizontalPadding,
            child: SizedBox(
              height: 180,
              child: Card(
                elevation: 5,
                color: AppColors.primaryColor.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'lib/assets/image/icon_home.png',
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "One Step Solution (OSS) Bali",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Semangat terus, karena tiap keringet dan usaha lo hari ini bakal bawa hasil manis buat besok. 🚀🔥",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.accentColor,
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
          ),

          // Kartu "Jadwal Kamu Hari Ini"
          Positioned(
            top: 140,
            width: mainCardWidth * 0.95,
            child: Card(
              elevation: 5,
              color: AppColors.accentColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isLoadingJadwal
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!isLibur) ...[
                            Text(
                              "Jadwal Kamu Hari Ini",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.login, size: 30),
                                      const SizedBox(width: 4),
                                      Text(
                                        jamMulai,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  Row(
                                    children: [
                                      const Icon(Icons.logout, size: 30),
                                      const SizedBox(width: 4),
                                      Text(
                                        jamSelesai,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.coffee_outlined),
                                const SizedBox(width: 10),
                                Text(
                                  "$jamIstirahatMulai - $jamIstirahatSelesai (${maksIstirahat ?? '-'} menit)",
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textDefaultColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // --- KONTEN BARU SAAT LIBUR ---
                            Text(
                              "Anda Libur Hari Ini",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.beach_access,
                              size: 48,
                              color: AppColors.primaryColor.withOpacity(0.8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Nikmati waktu istirahat Anda!",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),

          // Bar "Presensi Masuk ..."
          Positioned(
            bottom: -25,
            width: mainCardWidth * 0.9,
            child: Card(
              elevation: 5,
              color: AppColors.primaryColor.withOpacity(0.7),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: _buildPresensiWidget(absensiProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
