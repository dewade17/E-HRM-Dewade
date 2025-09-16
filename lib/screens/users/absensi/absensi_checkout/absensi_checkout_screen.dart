import 'dart:io';
import 'package:e_hrm/screens/users/absensi/widget/geofence_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:e_hrm/providers/location/location_provider.dart';
import 'package:e_hrm/providers/absensi/absensi_provider.dart';
import 'package:e_hrm/dto/location/location.dart' as dto_loc;

class AbsensiCheckoutScreen extends StatefulWidget {
  final String userId;
  const AbsensiCheckoutScreen({super.key, required this.userId});

  @override
  State<AbsensiCheckoutScreen> createState() => _AbsensiCheckoutScreenState();
}

class _AbsensiCheckoutScreenState extends State<AbsensiCheckoutScreen> {
  dto_loc.Location? _nearest;
  Position? _position;
  File? _image;

  bool _inside = false;
  double? _distanceM;

  @override
  void initState() {
    super.initState();
    // Pastikan lokasi kantor tersedia (GeofenceMap juga auto-fetch)
    final lp = context.read<LocationProvider>();
    if (lp.items.isEmpty) lp.fetch();
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
        const SnackBar(
          content: Text('Di luar geofence — tidak bisa Check-out'),
        ),
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
    final ok = await abs.checkout(
      userId: widget.userId,
      locationId: _nearest?.idLocation,
      lat: _position!.latitude,
      lng: _position!.longitude,
      imageFile: _image!,
    );

    if (!mounted) return;
    if (ok != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-out ${ok.match ? "BERHASIL" : "GAGAL"} '
            '(score: ${ok.score.toStringAsFixed(3)}, thr: ${ok.threshold})',
          ),
        ),
      );
      if (ok.match) Navigator.pop(context, ok);
    } else {
      final err = abs.error ?? 'Gagal check-out';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final abs = context.watch<AbsensiProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Check-out')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // === MAP (auto-fetch lokasi + tombol mark my location) ===
            AspectRatio(
              aspectRatio: 1,
              child: GeofenceMap(
                // radiusFallback opsional; default 100m
                onStatus: (inside, distanceM, nearest) async {
                  // Update status dari peta
                  if (!mounted) return;
                  setState(() {
                    _inside = inside;
                    _distanceM = distanceM;
                    _nearest = nearest;
                  });
                  // Ambil posisi terbaru untuk submit
                  try {
                    final p = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );
                    if (mounted) setState(() => _position = p);
                  } catch (_) {
                    // biarkan null; tombol submit akan menolak jika posisi belum ada
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Status kantor terdekat + jarak
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

            // Preview foto
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: _image == null
                    ? const Text('Belum ada foto')
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: abs.saving ? null : _takeImage,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Ambil Foto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (abs.saving || !_inside) ? null : _submit,
                    icon: abs.saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: const Text('Check-out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
