// screens/users/absensi/absensi_checkin/widget/content_absensi_checkin.dart

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/location/location.dart' as dto_loc;
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/recipient_absensi_checkin.dart';
import 'package:e_hrm/screens/users/absensi/widget/geofence_map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentAbsensiCheckin extends StatefulWidget {
  final String userId;
  const ContentAbsensiCheckin({super.key, required this.userId});

  @override
  State<ContentAbsensiCheckin> createState() => _ContentAbsensiCheckinState();
}

class _ContentAbsensiCheckinState extends State<ContentAbsensiCheckin> {
  dto_loc.Location? _nearest;
  Position? _position;

  bool _inside = false;
  double? _distanceM;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PENTING: beri tinggi finite agar flutter_map tidak menerima constraints tak terbatas
        SizedBox(
          height: 280,
          child: GeofenceMap(
            onStatus: (inside, distanceM, nearest) async {
              if (!mounted) return;

              // Normalisasi: buang NaN/Infinity dari sumber manapun
              final double? safeDistance =
                  (distanceM != null && distanceM.isFinite) ? distanceM : null;

              setState(() {
                _inside = inside;
                _distanceM = safeDistance;
                _nearest = nearest;
              });

              // Simpan posisi GPS terakhir (aman gagal)
              try {
                final p = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                if (mounted) setState(() => _position = p);
              } catch (_) {
                // Biarkan null; proses submit bisa memvalidasi lagi.
              }
            },
          ),
        ),
        const SizedBox(height: 12),

        // Info jarak & status geofence
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _inside ? Icons.verified_user : Icons.error_outline,
              color: _inside ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _nearest == null
                    ? 'Menunggu lokasi & daftar kantor...'
                    : '${_nearest!.namaKantor} • '
                          '${_inside ? "Di dalam radius" : "Di luar radius"}'
                          '${_distanceM != null ? " • ${_distanceM!.toStringAsFixed(1)} m" : ""}',
              ),
            ),
          ],
        ),
        RecipientAbsensiCheckin(),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                color: AppColors.primaryColor,
                width: 5, // lebih tebal di kiri
              ),
              top: BorderSide(color: AppColors.primaryColor, width: 1),
              right: BorderSide(color: AppColors.primaryColor, width: 1),
              bottom: BorderSide(color: AppColors.primaryColor, width: 1),
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Kolom utama konten
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rail kiri (jam mulai, titik vertikal, jam selesai)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Jam mulai
                      Container(
                        width: 78,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.textDefaultColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "09:00",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Titik-titik vertikal (ikon)
                      const Icon(Icons.more_vert, size: 22),
                      const SizedBox(height: 10),
                      // Jam selesai
                      Container(
                        width: 78,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.textDefaultColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "11:00",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Konten kanan (status, judul, tanggal)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip status "Diproses" + chevron
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xfff6f6f6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Diproses",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Judul
                        Text(
                          "Membuat Design Project Mobile E-HRM OSS Bali",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tanggal
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "02 September 2025",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),

              // Tombol aksi di kanan (hapus & edit)
              Positioned(
                right: -30,
                top: 25,
                child: Column(
                  children: [
                    // Hapus
                    Material(
                      color: const Color(0xffffe1e8),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {},
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.delete_outline, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10), // Edit
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
