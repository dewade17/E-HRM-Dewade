// lib/screens/users/kunjungan_klien/create_kunjungan_klien/widget/mark_me_map.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MarkMeMap extends StatefulWidget {
  /// Opsional: controller untuk auto-isi latitude
  final TextEditingController? latitudeController;

  /// Opsional: controller untuk auto-isi longitude
  final TextEditingController? longitudeController;

  /// Dipanggil setiap lokasi berhasil diambil
  final void Function(double lat, double lng)? onPicked;

  /// Jika parent tidak memberi tinggi yang jelas, pakai fallback ini
  final double fallbackHeight;

  /// Zoom saat pertama kali dibuka
  final double initialZoom;

  /// Center default saat belum ada lokasi (Bali sebagai fallback)
  final LatLng initialCenter;

  /// Jika true, langsung coba ambil lokasi saat build pertama
  final bool autoFetchOnInit;

  const MarkMeMap({
    super.key,
    this.latitudeController,
    this.longitudeController,
    this.onPicked,
    this.fallbackHeight = 220,
    this.initialZoom = 15,
    this.initialCenter = const LatLng(-8.409518, 115.188919),
    this.autoFetchOnInit = false,
  });

  @override
  State<MarkMeMap> createState() => _MarkMeMapState();
}

class _MarkMeMapState extends State<MarkMeMap> {
  final MapController _map = MapController();
  LatLng? _me;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoFetchOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _markMe());
    }
  }

  Future<void> _markMe() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location Services mati. Aktifkan terlebih dulu.'),
            ),
          );
        }
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
        }
        return;
      }

      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      final pos = LatLng(p.latitude, p.longitude);
      setState(() => _me = pos);

      _map.move(pos, 17);

      widget.latitudeController?.text = p.latitude.toStringAsFixed(6);
      widget.longitudeController?.text = p.longitude.toStringAsFixed(6);
      widget.onPicked?.call(p.latitude, p.longitude);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lokasi diambil: ${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal ambil lokasi: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (_me != null)
        Marker(
          point: _me!,
          width: 28,
          height: 28,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
    ];

    final map = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        mapController: _map,
        options: MapOptions(
          initialCenter: widget.initialCenter,
          initialZoom: widget.initialZoom,
          maxZoom: 20,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            keepBuffer: 2,
            userAgentPackageName: 'com.example.e_hrm',
          ),
          if (markers.isNotEmpty) MarkerLayer(markers: markers),
        ],
      ),
    );

    final overlayButtons = Positioned(
      right: 8,
      bottom: 8,
      child: FloatingActionButton.small(
        heroTag: 'markMeOnly',
        onPressed: _busy ? null : _markMe,
        child: _busy
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
      ),
    );

    final latlngBadge = _me != null
        ? Positioned(
            left: 8,
            bottom: 8,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Text(
                  '${_me!.latitude.toStringAsFixed(6)}, ${_me!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          )
        : null;

    final content = Stack(
      children: [map, overlayButtons, if (latlngBadge != null) latlngBadge],
    );

    return LayoutBuilder(
      builder: (context, c) {
        final finite =
            c.hasBoundedHeight && c.maxHeight.isFinite && c.maxHeight > 0;
        if (finite) return content;
        return SizedBox(height: widget.fallbackHeight, child: content);
      },
    );
  }
}
