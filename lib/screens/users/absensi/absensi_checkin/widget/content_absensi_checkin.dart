// screens/users/absensi/absensi_checkin/widget/content_absensi_checkin.dart

import 'dart:ui' as ui;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/location/location.dart' as dto_loc;
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/agenda_absensi_checkin.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/catatan_absensi_checkin.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/recipient_absensi_checkin.dart';
import 'package:e_hrm/screens/users/absensi/widget/geofence_map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';

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
    final textStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(fontSize: 13.5),
    );

    return Column(
      children: [
        // Beri tinggi finite agar flutter_map tidak error
        SizedBox(
          height: 280,
          child: GeofenceMap(
            onStatus: (inside, distanceM, nearest) async {
              if (!mounted) return;

              final double? safeDistance =
                  (distanceM != null && distanceM.isFinite) ? distanceM : null;

              setState(() {
                _inside = inside;
                _distanceM = safeDistance;
                _nearest = nearest;
              });

              try {
                final p = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                if (mounted) setState(() => _position = p);
              } catch (_) {}
            },
          ),
        ),
        const SizedBox(height: 12),

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
                style: textStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const RecipientAbsensiCheckin(),
        const SizedBox(height: 16),

        AgendaAbsensiCheckin(),
        CatatanAbsensiCheckin(),
        SizedBox(height: 20),
        GestureDetector(
          child: Card(
            color: AppColors.primaryColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 70),
              child: Text(
                "Verifikasi Wajah",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
