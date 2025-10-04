// lib/screens/users/absensi/take_face_absensi/take_face_absensi_screen.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:e_hrm/providers/absensi/absensi_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class TakeFaceAbsensiScreen extends StatefulWidget {
  const TakeFaceAbsensiScreen({
    super.key,
    required this.isCheckin,
    required this.userId,
    this.locationId,
    required this.latitude,
    required this.longitude,
    required this.agendaIds,
    required this.recipientIds,
    required this.catatan,
    required this.locationName,
    required this.scheduleLabel,
    this.shiftName,
    this.agendaCount = 0,
    this.recipientCount = 0,
    this.catatanCount = 0,
    this.berkasCount = 0,
  });

  final bool isCheckin;
  final String userId;
  final String? locationId;
  final double latitude;
  final double longitude;
  final List<String> agendaIds;
  final List<String> recipientIds;
  final List<AbsensiCatatanEntry> catatan;
  final String locationName;
  final String scheduleLabel;
  final String? shiftName;
  final int agendaCount;
  final int recipientCount;
  final int catatanCount;
  final int berkasCount;

  @override
  State<TakeFaceAbsensiScreen> createState() => _TakeFaceAbsensiScreenState();
}

class _TakeFaceAbsensiScreenState extends State<TakeFaceAbsensiScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _init;
  bool _taking = false;
  final bool _mirrorFrontPreview = true;
  final bool _enablePinchZoom = false;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  final double _baseZoomOnScaleStart = 1.0;
  bool _isFront = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final selected = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      _isFront = selected.lensDirection == CameraLensDirection.front;
      CameraController controller = CameraController(
        selected,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Menggunakan serangkaian fallback resolusi jika `max` gagal
      Future<void> init = controller.initialize().catchError((_) async {
        controller.dispose();
        controller = CameraController(
          selected,
          ResolutionPreset.veryHigh,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        return controller.initialize().catchError((_) async {
          controller.dispose();
          controller = CameraController(
            selected,
            ResolutionPreset.high,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );
          return controller.initialize();
        });
      });

      setState(() {
        _controller = controller;
        _init = init;
      });

      await init;
      if (!mounted) return;

      _minZoom = await controller.getMinZoomLevel();
      _maxZoom = await controller.getMaxZoomLevel();
      await controller.setZoomLevel(_currentZoom.clamp(_minZoom, _maxZoom));
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setFlashMode(FlashMode.off);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menginisialisasi kamera')),
        );
      }
    }
  }

  Future<XFile> _mirrorIfNeeded(XFile file) async {
    if (!_isFront || !_mirrorFrontPreview) return file;
    try {
      final bytes = await file.readAsBytes();
      final imgSrc = img.decodeImage(bytes);
      if (imgSrc == null) return file;
      final flipped = img.flipHorizontal(imgSrc);
      final outBytes = img.encodeJpg(flipped, quality: 95);
      final dir = await getTemporaryDirectory();
      final outPath = p.join(
        dir.path,
        'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final outFile = File(outPath);
      await outFile.writeAsBytes(outBytes, flush: true);
      return XFile(outFile.path);
    } catch (e) {
      debugPrint('Mirror file gagal: $e');
      return file;
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _taking) {
      return;
    }
    final absensi = context.read<AbsensiProvider>();
    setState(() => _taking = true);

    try {
      final raw = await _controller!.takePicture();
      final mirrored = await _mirrorIfNeeded(raw);
      final file = File(mirrored.path);

      final result = widget.isCheckin
          ? await absensi.checkin(
              userId: widget.userId,
              locationId: widget.locationId,
              lat: widget.latitude,
              lng: widget.longitude,
              imageFile: file,
              agendaKerjaIds: widget.agendaIds,
              recipients: widget.recipientIds,
              catatan: widget.catatan,
            )
          : await absensi.checkout(
              userId: widget.userId,
              locationId: widget.locationId,
              lat: widget.latitude,
              lng: widget.longitude,
              imageFile: file,
              agendaKerjaIds: widget.agendaIds,
              recipients: widget.recipientIds,
              catatan: widget.catatan,
            );

      // --- REKOMENDASI: Tambah pengecekan `mounted` di sini ---
      if (!mounted) return;

      if (result != null) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Berhasil!',
          text: widget.isCheckin
              ? 'Anda berhasil melakukan check-in.'
              : 'Anda berhasil melakukan check-out.',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.of(context).pop(); // Tutup dialog
            Navigator.of(context).pop(true); // Tutup halaman kamera
          },
        );
      } else {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: absensi.error ?? 'Gagal mengirim data absensi.',
          confirmBtnText: 'Coba Lagi',
        );
      }
    } catch (e) {
      // --- REKOMENDASI: Tambah pengecekan `mounted` di sini ---
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'Gagal mengambil atau memproses foto: ${e.toString()}',
        confirmBtnText: 'OK',
      );
    } finally {
      if (mounted) setState(() => _taking = false);
    }
  }

  // Widget _buildFullCamera() tidak ada perubahan
  Widget _buildFullCamera() {
    final c = _controller;
    if (c == null) return const SizedBox.shrink();
    return FutureBuilder(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done ||
            !c.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        final size = MediaQuery.of(context).size;
        final previewSize = Size(
          c.value.previewSize!.height,
          c.value.previewSize!.width,
        );
        final screenAspectRatio = size.aspectRatio;
        final previewAspectRatio = previewSize.aspectRatio;
        var scale = screenAspectRatio > previewAspectRatio
            ? screenAspectRatio / previewAspectRatio
            : 1.0;
        Widget preview = CameraPreview(c);
        if (_mirrorFrontPreview && _isFront) {
          preview = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(math.pi),
            child: preview,
          );
        }
        preview = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) async {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final localPos = box.globalToLocal(details.globalPosition);
            final w = box.size.width;
            final h = box.size.height;
            var rel = Offset(
              (localPos.dx / w).clamp(0.0, 1.0),
              (localPos.dy / h).clamp(0.0, 1.0),
            );
            if (_mirrorFrontPreview && _isFront) {
              rel = Offset(1.0 - rel.dx, rel.dy);
            }
            try {
              if (c.value.exposurePointSupported) await c.setExposurePoint(rel);
              if (c.value.focusPointSupported) {
                await c.setFocusPoint(rel);
                await c.setFocusMode(FocusMode.auto);
              }
            } catch (_) {}
          },
          child: preview,
        );
        return ClipRect(
          clipper: _OverflowClipper(size),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Center(child: preview),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleDiameter = (math.min(size.width, size.height) * 0.65).clamp(
      240.0,
      340.0,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _buildFullCamera()),
          Center(
            child: IgnorePointer(
              child: Container(
                width: circleDiameter,
                height: circleDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 96,
            child: _InfoCard(
              scheduleLabel: widget.scheduleLabel,
              locationName: widget.locationName,
              shiftName: widget.shiftName,
              recipientCount: widget.recipientCount,
              agendaCount: widget.agendaCount,
              catatanCount: widget.catatanCount,
              berkasCount: widget.berkasCount,
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            child: ElevatedButton(
              onPressed: (_controller?.value.isInitialized ?? false) && !_taking
                  ? _takePicture
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE93353),
                foregroundColor: Colors.white,
                elevation: 8,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(
                _taking
                    ? 'Memproses...'
                    : (widget.isCheckin ? 'Presensi Masuk' : 'Presensi Keluar'),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 12,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 16,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentZoom.toStringAsFixed(2)}x',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// _InfoCard dan _OverflowClipper tidak ada perubahan
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.scheduleLabel,
    required this.locationName,
    this.shiftName,
    this.recipientCount = 0,
    this.agendaCount = 0,
    this.catatanCount = 0,
    this.berkasCount = 0,
  });
  final String scheduleLabel;
  final String locationName;
  final String? shiftName;
  final int recipientCount;
  final int agendaCount;
  final int catatanCount;
  final int berkasCount;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha((0.95 * 255).round()),
      borderRadius: BorderRadius.circular(24),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scheduleLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black45),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 20,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationName,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (shiftName != null && shiftName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Shift: $shiftName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            Row(
              children: List.generate(4, (i) {
                final labels = ['Supervisi', 'Pekerjaan', 'Catatan', 'Berkas'];
                final vals = [
                  recipientCount.toString(),
                  agendaCount.toString(),
                  catatanCount.toString(),
                  berkasCount.toString(),
                ];
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        vals[i],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverflowClipper extends CustomClipper<Rect> {
  final Size size;
  _OverflowClipper(this.size);
  @override
  Rect getClip(Size _) => Offset.zero & size;
  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
