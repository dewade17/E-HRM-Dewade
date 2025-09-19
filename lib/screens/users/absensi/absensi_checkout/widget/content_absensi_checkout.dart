import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/location/location.dart' as dto_loc;
import 'package:e_hrm/screens/users/absensi/absensi_checkout/widget/agenda_absensi_checkout.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkout/widget/catatan_absensi_checkout.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkout/widget/recipient_absensi_checkout.dart';
import 'package:e_hrm/screens/users/absensi/take_face_absensi/take_face_absensi_screen.dart';
import 'package:e_hrm/screens/users/absensi/widget/geofence_map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentAbsensiCheckout extends StatefulWidget {
  const ContentAbsensiCheckout({super.key, required String userId});

  @override
  State<ContentAbsensiCheckout> createState() => _ContentAbsensiCheckoutState();
}

class _ContentAbsensiCheckoutState extends State<ContentAbsensiCheckout> {
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
        SizedBox(
          height: 80, // Anda bisa sesuaikan tinggi ini
          child: Row(
            // Agar semua konten berada di tengah secara vertikal
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "11",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDefaultColor,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Agar center
                children: [
                  Text(
                    "Senin",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                  Text(
                    "September 2025",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                ],
              ),

              // SEKARANG VERTICAL DIVIDER AKAN TERLIHAT
              const VerticalDivider(
                width: 25,
                thickness: 2, // Saya ubah agar lebih terlihat
                color: AppColors.primaryColor,
                indent: 10, // Memberi jarak dari atas
                endIndent: 10, // Memberi jarak dari bawah
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Agar center
                children: [
                  Row(
                    children: [
                      Text(
                        "08:00", // Contoh jam
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDefaultColor,
                          ),
                        ),
                      ),
                      Icon(Icons.more_horiz_outlined),
                      Text(
                        "08:00", // Contoh jam
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDefaultColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Piket", // nama_pola_kerja
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        const RecipientAbsensiCheckout(),
        const SizedBox(height: 16),

        AgendaAbsensiCheckout(),
        CatatanAbsensiCheckout(),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TakeFaceAbsensiScreen()),
            );
          },
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
