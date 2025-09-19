import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class TakeFaceAbsensiScreen extends StatefulWidget {
  const TakeFaceAbsensiScreen({super.key});

  @override
  State<TakeFaceAbsensiScreen> createState() => _TakeFaceAbsensiScreenState();
}

class _TakeFaceAbsensiScreenState extends State<TakeFaceAbsensiScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _init;
  bool _taking = false;

  // Mirror preview kamera depan (jadi seperti selfie app)
  final bool _mirrorFrontPreview = true;

  // Nonaktifkan pinch-to-zoom agar tidak pernah "zoom"
  final bool _enablePinchZoom = false;

  // Zoom state (tetap diset ke 1.0)
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoomOnScaleStart = 1.0;

  // Simpan rasio & apakah kamera depan
  double _previewAspectRatio = 3 / 4;
  bool _isFront = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // === Immersive fullscreen ===
    // Sembunyikan status bar + nav bar agar preview terlihat benar-benar full
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();

    // Kembalikan UI sistem seperti semula
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null) return;

    // Tangani lifecycle agar kamera tidak nge-freeze setelah resume
    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
      // Pastikan tetap immersive setelah kembali dari background
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      // Pilih kamera depan jika ada
      final selected = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      _isFront = selected.lensDirection == CameraLensDirection.front;

      // Pakai preset tertinggi yang aman; kualitas foto tetap high-res.
      CameraController controller = CameraController(
        selected,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

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

      // Pastikan zoom di 1.0 (NO zoom) dan tetap di batas aman
      try {
        _minZoom = await controller.getMinZoomLevel();
        _maxZoom = await controller.getMaxZoomLevel();
        _currentZoom = 1.0.clamp(_minZoom, _maxZoom);
        await controller.setZoomLevel(_currentZoom);
      } catch (_) {}

      // Auto exposure & focus; flash off untuk konsistensi
      try {
        await controller.setFocusMode(FocusMode.auto);
        await controller.setExposureMode(ExposureMode.auto);
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _previewAspectRatio = controller.value.aspectRatio;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menginisialisasi kamera')),
        );
      }
    }
  }

  // Mirror file hasil foto kalau kamera depan & preview dimirror
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
      return file; // fallback: pakai file asli
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_taking) return;

    setState(() => _taking = true);
    try {
      // Pastikan zoom tetap 1.0 sebelum ambil foto
      try {
        await _controller!.setZoomLevel(1.0.clamp(_minZoom, _maxZoom));
      } catch (_) {}

      final raw = await _controller!.takePicture();
      final file = await _mirrorIfNeeded(raw);

      if (!mounted) return;
      Navigator.pop(context, file); // kembalikan XFile ke caller
    } catch (e) {
      debugPrint('Take picture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mengambil foto')));
      }
    } finally {
      if (mounted) setState(() => _taking = false);
    }
  }

  // Preview kamera TANPA cropping/zoom: letterbox (contain).
  // GANTI FUNGSI LAMA DENGAN YANG INI
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

        // === PERUBAHAN DIMULAI DI SINI ===

        // 1. Dapatkan ukuran layar
        final size = MediaQuery.of(context).size;

        // 2. Dapatkan ukuran pratinjau dari controller kamera
        // Perlu dibalik karena orientasi sensor (biasanya landscape)
        final previewSize = Size(
          c.value.previewSize!.height,
          c.value.previewSize!.width,
        );
        final screenAspectRatio = size.aspectRatio;
        final previewAspectRatio = previewSize.aspectRatio;

        // 3. Hitung faktor skala untuk "cover"
        var scale = screenAspectRatio > previewAspectRatio
            ? screenAspectRatio / previewAspectRatio
            : 1.0; // Jika layar lebih "lebar" dari preview, skala. Jika tidak, tetap 1.0 (atau bisa juga diatur sebaliknya tergantung kebutuhan)

        Widget preview = CameraPreview(c);

        // MIRROR preview untuk kamera depan
        if (_mirrorFrontPreview && _isFront) {
          preview = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(math.pi),
            child: preview,
          );
        }

        // Gesture untuk tap-to-focus (tidak berubah)
        preview = GestureDetector(
          // ... (kode GestureDetector Anda yang sudah ada tetap di sini)
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
              if (c.value.exposurePointSupported) {
                await c.setExposurePoint(rel);
              }
              if (c.value.focusPointSupported) {
                await c.setFocusPoint(rel);
                await c.setFocusMode(FocusMode.auto);
              }
            } catch (_) {}
          },
          child: preview,
        );

        // 4. Terapkan scaling untuk mendapatkan efek BoxFit.cover
        //    AspectRatio tidak lagi diperlukan di sini.
        return ClipRect(
          clipper: _OverflowClipper(size),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Center(child: preview),
          ),
        );
        // === AKHIR DARI PERUBAHAN ===
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Diameter lingkaran dibuat sedikit lebih besar agar lebih pas di tengah
    final circleDiameter = (math.min(size.width, size.height) * 0.65).clamp(
      240.0,
      340.0,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1) FULLSCREEN CAMERA (tidak berubah)
          Positioned.fill(child: _buildFullCamera()),

          // 2) OVERLAY LINGKARAN PANDUAN (YANG DIPERBARUI)
          // LAMA: Menggunakan Positioned dengan properti 'top'
          // BARU: Menggunakan Center agar posisi sempurna di tengah
          Center(
            child: IgnorePointer(
              child: Container(
                width: circleDiameter,
                height: circleDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Sedikit lebih transparan agar tidak terlalu mendominasi
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

          // 3) Kartu info (tidak berubah)
          const Positioned(left: 16, right: 16, bottom: 96, child: _InfoCard()),

          // 4) Tombol capture (tidak berubah)
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
              child: Text(_taking ? 'Memproses...' : 'Presensi Keluar'), //: "Prensesi Masuk"
            ),
          ),

          // 5) Back (tidak berubah)
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

          // 6) Indikator zoom (tidak berubah)
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

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(24),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: Colors.black54,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jumat, 19 Sep 2025 (08:40 - 18:00)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.black45),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.location_on_rounded, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'OSS Bali',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(4, (i) {
                final labels = ['Supervisi', 'Pekerjaan', 'Catatan', 'Berkas'];
                final vals = ['2', '1', '0', '0'];
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

// Tambahkan class helper ini di luar class State Anda
// untuk memastikan preview tidak "bocor" keluar layar
class _OverflowClipper extends CustomClipper<Rect> {
  final Size size;
  _OverflowClipper(this.size);

  @override
  Rect getClip(Size _) => Offset.zero & size;

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
