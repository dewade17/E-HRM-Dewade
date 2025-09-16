import 'dart:io';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/header_absensi_checkin.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/recipient_absensi_checkin.dart';
import 'package:e_hrm/screens/users/absensi/widget/geofence_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:e_hrm/providers/absensi/absensi_provider.dart';
import 'package:e_hrm/dto/location/location.dart' as dto_loc;

class AbsensiCheckinScreen extends StatefulWidget {
  final String userId;
  const AbsensiCheckinScreen({super.key, required this.userId});

  @override
  State<AbsensiCheckinScreen> createState() => _AbsensiCheckinScreenState();
}

class _AbsensiCheckinScreenState extends State<AbsensiCheckinScreen> {
  dto_loc.Location? _nearest;
  Position? _position;
  File? _image;

  bool _inside = false;
  double? _distanceM;

  @override
  void initState() {
    super.initState();
    // GeofenceMap akan auto-fetch daftar lokasi & handle GPS.
  }

  Future<void> _takeImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (!mounted) return;
    if (file != null) setState(() => _image = File(file.path));
  }

  Future<void> _submit() async {
    if (!_inside) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Di luar geofence — tidak bisa Check-in')),
      );
      return;
    }
    if (_nearest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi kantor belum terdeteksi')),
      );
      return;
    }
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum tersedia (tap ikon target di peta).'),
        ),
      );
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ambil foto dulu')));
      return;
    }

    final abs = context.read<AbsensiProvider>();
    final ok = await abs.checkin(
      userId: widget.userId,
      locationId: _nearest!.idLocation,
      lat: _position!.latitude,
      lng: _position!.longitude,
      imageFile: _image!,
    );

    if (!mounted) return;
    if (ok != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-in ${ok.match ? "BERHASIL" : "GAGAL"} '
            '(score: ${ok.score.toStringAsFixed(3)}, thr: ${ok.threshold})',
          ),
        ),
      );
      if (ok.match) Navigator.pop(context, ok);
    } else {
      final err = abs.error ?? 'Gagal check-in';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final abs = context.watch<AbsensiProvider>();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: 30),
          HeaderAbsensiCheckin(),
          SizedBox(height: 30),
          // === MAP: auto-fetch lokasi + tombol mark my location ===
          AspectRatio(
            aspectRatio: 1,
            child: GeofenceMap(
              onStatus: (inside, distanceM, nearest) async {
                if (!mounted) return;
                setState(() {
                  _inside = inside;
                  _distanceM = distanceM;
                  _nearest = nearest;
                });
                // simpan posisi terbaru dari GPS untuk submit
                try {
                  final p = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  if (mounted) setState(() => _position = p);
                } catch (_) {
                  // biarkan null; submit akan menolak jika posisi belum ada
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Info jarak & status geofence
          Row(
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
          const SizedBox(height: 12),

          RecipientAbsensiCheckin(),
        ],
      ),
    );
  }
}
