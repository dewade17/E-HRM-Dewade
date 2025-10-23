// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:e_hrm/providers/location/location_provider.dart';
import 'package:e_hrm/dto/location/location.dart' as dto_loc;

class GeofenceMap extends StatefulWidget {
  /// Callback: inside?, distance meter ke kantor terdekat, kantor terdekat
  final void Function(
    bool inside,
    double? distanceM,
    dto_loc.Location? nearest,
  )?
  onStatus;

  /// Radius default kalau null di data
  final double radiusFallback;

  /// Opsional: tinggi fallback ketika parent memberi constraints tidak jelas
  final double fallbackHeight;

  const GeofenceMap({
    super.key,
    this.onStatus,
    this.radiusFallback = 100,
    this.fallbackHeight = 260,
  });

  @override
  State<GeofenceMap> createState() => _GeofenceMapState();
}

class _GeofenceMapState extends State<GeofenceMap> {
  static const LatLng _fallbackCenter = LatLng(-8.409518, 115.188919); // Bali
  final MapController _map = MapController();

  // Simpan provider supaya TIDAK lookup ancestor di dispose()
  late final LocationProvider _lp;

  Position? _pos;
  StreamSubscription<Position>? _posSub;

  dto_loc.Location? _nearest;
  double? _nearestDistM;
  bool _inside = false;

  // cache agar tidak spam callback
  dto_loc.Location? _lastNearest;
  double? _lastDist;
  bool? _lastInside;

  // Listener yang kita pasang ke _lp
  VoidCallback? _locationsListener;

  @override
  void initState() {
    super.initState();

    // Ambil provider tanpa listening dan simpan referensinya
    // (boleh di initState ketika pakai read / listen:false)
    _lp = context.read<LocationProvider>();

    // Mulai fetch lokasi kantor bila kosong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lp.items.isEmpty) _lp.fetch();
    });

    // Dengarkan perubahan data kantor → hitung ulang nearest
    _locationsListener = () {
      if (!mounted) return;
      _recalcNearest();
    };
    _lp.addListener(_locationsListener!);

    // Ambil izin & posisi awal + mulai stream
    _ensureLocation(startStream: true);
  }

  @override
  void dispose() {
    // Hentikan stream lebih dulu supaya tak ada callback terlambat
    _posSub?.cancel();
    _posSub = null;

    // Lepas listener provider TANPA mengakses context di sini
    if (_locationsListener != null) {
      _lp.removeListener(_locationsListener!);
      _locationsListener = null;
    }

    super.dispose();
  }

  /// Helper untuk memastikan nilai longitude berada di antara -180 dan 180
  double _wrapLongitude(double longitude) {
    if (longitude >= -180 && longitude <= 180) return longitude;
    return (longitude + 180) % 360 - 180;
  }

  Future<void> _ensureLocation({bool startStream = false}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location Services mati. Aktifkan dulu.')),
      );
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
      return;
    }

    // Posisi awal
    final p = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (!mounted) return;
    setState(() => _pos = p);
    _map.move(LatLng(p.latitude, p.longitude), 17);
    _recalcNearest();

    // Stream realtime (opsional)
    if (startStream) {
      await _posSub?.cancel();
      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5, // update jika bergerak ≥5m
            ),
          ).listen((pos) {
            if (!mounted) return; // guard bila widget sudah disposed
            setState(() => _pos = pos);
            _recalcNearest();
          });
    }
  }

  void _recalcNearest() {
    final items = _lp.items; // pakai referensi, bukan context.read
    if (_pos == null || items.isEmpty) {
      if (!mounted) return;
      setState(() {
        _nearest = null;
        _nearestDistM = null;
        _inside = false;
      });
      _maybeNotify();
      return;
    }

    double best = double.infinity;
    dto_loc.Location? bestLoc;
    for (final e in items) {
      final lat = double.tryParse(e.latitude) ?? 0.0;
      final lng = double.tryParse(e.longitude) ?? 0.0;
      final d = Geolocator.distanceBetween(
        _pos!.latitude,
        _pos!.longitude,
        lat,
        _wrapLongitude(lng),
      );
      if (d < best) {
        best = d;
        bestLoc = e;
      }
    }

    final radius = ((bestLoc?.radius ?? widget.radiusFallback)).toDouble();
    final inside = best.isFinite && best <= radius;

    if (!mounted) return;
    setState(() {
      _nearest = bestLoc;
      _nearestDistM = best.isFinite ? best : null;
      _inside = inside;
    });
    _maybeNotify();
  }

  void _maybeNotify() {
    final cb = widget.onStatus;
    if (cb == null) return;
    if (_nearest != _lastNearest ||
        _nearestDistM != _lastDist ||
        _inside != _lastInside) {
      _lastNearest = _nearest;
      _lastDist = _nearestDistM;
      _lastInside = _inside;
      cb(_inside, _nearestDistM, _nearest);
    }
  }

  List<LatLng> _makeCircle(
    LatLng center,
    double radiusMeters, {
    int segments = 64,
  }) {
    const double earthRadius = 6378137.0; // meter
    final double lat = center.latitudeInRad;
    final double lng = center.longitudeInRad;
    final double d = radiusMeters / earthRadius;
    final List<LatLng> pts = [];
    for (int i = 0; i <= segments; i++) {
      final double brng = 2 * math.pi * i / segments;
      final double lat2 = math.asin(
        math.sin(lat) * math.cos(d) +
            math.cos(lat) * math.sin(d) * math.cos(brng),
      );
      final double lng2 =
          lng +
          math.atan2(
            math.sin(brng) * math.sin(d) * math.cos(lat),
            math.cos(d) - math.sin(lat) * math.sin(lat2),
          );
      final latDeg = lat2 * 180 / math.pi;
      final lngDeg = lng2 * 180 / math.pi;
      pts.add(LatLng(latDeg, _wrapLongitude(lngDeg)));
    }
    return pts;
  }

  void _fitAll() {
    final items = _lp.items;
    final points = <LatLng>[];
    if (_pos != null) points.add(LatLng(_pos!.latitude, _pos!.longitude));
    for (final e in items) {
      final lat = double.tryParse(e.latitude) ?? 0.0;
      final lng = double.tryParse(e.longitude) ?? 0.0;
      if (!lat.isNaN && !lng.isNaN && (lat != 0.0 || lng != 0.0)) {
        points.add(LatLng(lat, _wrapLongitude(lng)));
      }
    }
    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);
    _map.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan items untuk redraw visual (tanpa listener manual)
    final items = context.watch<LocationProvider>().items;

    // center awal
    final center = _pos != null
        ? LatLng(_pos!.latitude, _pos!.longitude)
        : (items.isNotEmpty
              ? LatLng(
                  double.tryParse(items.first.latitude) ??
                      _fallbackCenter.latitude,
                  _wrapLongitude(
                    double.tryParse(items.first.longitude) ??
                        _fallbackCenter.longitude,
                  ),
                )
              : _fallbackCenter);

    final polygons = <Polygon>[];
    final markers = <Marker>[];

    // kantor (lingkaran + marker)
    for (final e in items) {
      final lat = double.tryParse(e.latitude) ?? 0.0;
      final lng = double.tryParse(e.longitude) ?? 0.0;
      if (lat == 0.0 && lng == 0.0) continue;

      final point = LatLng(lat, _wrapLongitude(lng));
      final radius = ((e.radius)).toDouble();
      final circle = _makeCircle(point, radius);

      polygons.add(
        Polygon(
          points: circle,
          color: Colors.blue.withOpacity(0.12),
          borderStrokeWidth: 2,
          borderColor: Colors.blue,
        ),
      );

      markers.add(
        Marker(
          point: point,
          width: 36,
          height: 36,
          child: const Icon(Icons.apartment, size: 32),
        ),
      );
    }

    // user marker
    if (_pos != null) {
      markers.add(
        Marker(
          point: LatLng(_pos!.latitude, _pos!.longitude),
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
      );
    }

    // Hardening: pastikan map selalu punya tinggi finite
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFiniteHeight =
            constraints.hasBoundedHeight &&
            constraints.maxHeight.isFinite &&
            constraints.maxHeight > 0;

        final mapWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              maxZoom: 20,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                keepBuffer: 2,
                // Penting untuk OSM policy (isi sesuai applicationId Android-mu)
                userAgentPackageName: 'com.example.e_hrm',
              ),
              if (polygons.isNotEmpty) PolygonLayer(polygons: polygons),
              if (markers.isNotEmpty) MarkerLayer(markers: markers),
            ],
          ),
        );

        final stacked = Stack(
          children: [
            mapWidget,
            Positioned(
              right: 8,
              bottom: 8,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'markMe',
                    onPressed: () => _ensureLocation(startStream: true),
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'fitAll',
                    onPressed: _fitAll,
                    child: const Icon(Icons.fit_screen),
                  ),
                ],
              ),
            ),
          ],
        );

        if (hasFiniteHeight) return stacked; // parent memberi tinggi yang jelas
        return SizedBox(height: widget.fallbackHeight, child: stacked);
      },
    );
  }
}
