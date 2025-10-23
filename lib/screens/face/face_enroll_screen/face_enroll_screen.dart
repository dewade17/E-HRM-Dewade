// lib/screens/face/face_enroll_screen.dart

// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:e_hrm/providers/face/face_enroll/face_enroll_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class FaceEnrollScreen extends StatefulWidget {
  const FaceEnrollScreen({super.key, required this.userId});
  final String userId;

  @override
  State<FaceEnrollScreen> createState() => _FaceEnrollScreenState();
}

class _FaceEnrollScreenState extends State<FaceEnrollScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _init;
  bool _taking = false;

  // opsi UI/preview
  final bool _mirrorFrontPreview = true;
  bool _isFront = false;

  // zoom (label saja, pinch bisa ditambah nanti)
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  final double _currentZoom = 1.0;

  // stream analitik ringan (panduan adaptif)
  bool _streaming = false;
  DateTime _lastAnalyze = DateTime.fromMillisecondsSinceEpoch(0);
  String _hint = 'Posisikan wajah di dalam lingkaran, ekspresi netral.';
  String _lightLabel = 'cahaya: ?';
  double _lastLuma = 128;

  // review mode (pratinjau & foto ulang)
  File? _reviewFile;
  bool get _reviewMode => _reviewFile != null;
  List<String> _reviewTips = [];
  bool _reviewQualityOK = false;

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
    _stopStream();
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _stopStream();
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
        // YUV agar bisa startImageStream untuk panduan adaptif
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // fallback resolusi
      Future<void> init = controller.initialize().catchError((_) async {
        controller.dispose();
        controller = CameraController(
          selected,
          ResolutionPreset.veryHigh,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        return controller.initialize().catchError((_) async {
          controller.dispose();
          controller = CameraController(
            selected,
            ResolutionPreset.high,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.yuv420,
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

      await _startStream();

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

  Future<void> _startStream() async {
    if (_streaming) return;
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    try {
      await c.startImageStream((CameraImage image) {
        // Debounce ~300ms
        final now = DateTime.now();
        if (now.difference(_lastAnalyze).inMilliseconds < 300) return;
        _lastAnalyze = now;

        try {
          // Ambil luma rata-rata dari plane Y (0)
          final Plane yPlane = image.planes.first;
          final Uint8List bytes = yPlane.bytes;
          const step = 24; // sampling ringan
          int sum = 0;
          int count = 0;
          for (int i = 0; i < bytes.length; i += step) {
            sum += bytes[i];
            count++;
          }
          if (count > 0) _lastLuma = sum / count;

          String light;
          String hint;
          if (_lastLuma < 70) {
            light = 'gelap';
            hint =
                'Tingkatkan pencahayaan — menghadap sumber cahaya, hindari backlight.';
          } else if (_lastLuma > 200) {
            light = 'terlalu terang';
            hint = 'Terlalu terang — geser sedikit dari cahaya langsung.';
          } else {
            light = 'cukup';
            hint = 'Posisikan wajah di dalam lingkaran, ekspresi netral.';
          }

          if (mounted) {
            setState(() {
              _lightLabel = 'cahaya: $light';
              _hint = hint;
            });
          }
        } catch (_) {
          // abaikan bila parsing Y gagal
        }
      });
      _streaming = true;
    } catch (e) {
      debugPrint('startImageStream gagal: $e');
      _streaming = false;
    }
  }

  Future<void> _stopStream() async {
    if (!_streaming) return;
    try {
      await _controller?.stopImageStream();
    } catch (_) {}
    _streaming = false;
  }

  Future<XFile> _mirrorIfNeeded(XFile file) async {
    if (!_isFront || !_mirrorFrontPreview) return file;
    try {
      final bytes = await file.readAsBytes();
      final src = img.decodeImage(bytes);
      if (src == null) return file;
      final flipped = img.flipHorizontal(src);
      final outBytes = img.encodeJpg(flipped, quality: 95);
      final dir = await getTemporaryDirectory();
      final outPath = p.join(
        dir.path,
        'enroll_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final outFile = File(outPath);
      await outFile.writeAsBytes(outBytes, flush: true);
      return XFile(outFile.path);
    } catch (e) {
      debugPrint('Mirror file gagal: $e');
      return file;
    }
  }

  Future<void> _takeAndSubmit() async {
    // Jepret -> review mode (bisa foto ulang / kirim)
    final c = _controller;
    if (c == null || !c.value.isInitialized || _taking || _reviewMode) return;

    setState(() => _taking = true);

    try {
      await _stopStream(); // perlu stop sebelum takePicture
      final raw = await c.takePicture();
      final mirrored = await _mirrorIfNeeded(raw);
      final file = File(mirrored.path);

      // Analisis kualitas dasar
      final analysis = await _analyzePhoto(file);
      final tips = analysis.$1;
      final qualityOK = analysis.$2;

      if (!mounted) return;
      setState(() {
        _reviewFile = file;
        _reviewTips = tips;
        _reviewQualityOK = qualityOK;
      });
    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'Gagal mengambil atau memproses foto: $e',
        confirmBtnText: 'OK',
      );
      await _startStream();
    } finally {
      if (mounted) setState(() => _taking = false);
    }
  }

  /// Analisis sederhana: brightness + sharpness (Sobel) pada area tengah.
  /// Mengembalikan (tips, qualityOK).
  Future<(List<String>, bool)> _analyzePhoto(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final src = img.decodeImage(bytes);
      if (src == null) return (['Gambar tidak dapat dibaca.'], false);

      // crop pusat ~60% sisi terpendek (area wajah kira-kira)
      final minSide = math.min(src.width, src.height);
      final cropSide = (minSide * 0.6).round();
      final cx = (src.width - cropSide) ~/ 2;
      final cy = (src.height - cropSide) ~/ 2;
      final cropped = img.copyCrop(
        src,
        x: cx,
        y: cy,
        width: cropSide,
        height: cropSide,
      );

      // brightness (luma rata-rata)
      double sum = 0;
      int count = 0;
      for (int y = 0; y < cropped.height; y += 4) {
        for (int x = 0; x < cropped.width; x += 4) {
          // Gunakan Image.getPixel(x, y) untuk mendapatkan objek Pixel
          final pixel = cropped.getPixel(x, y);

          // ✅ PERBAIKAN: Menggunakan enum 'Channel' (dari 'package:image')
          final r = pixel.getChannel(img.Channel.red).toDouble();
          final g = pixel.getChannel(img.Channel.green).toDouble();
          final b = pixel.getChannel(img.Channel.blue).toDouble();

          // Nilai channel dikembalikan sebagai num, konversi ke double untuk perhitungan luma.
          // Luma: 0.2126*R + 0.7152*G + 0.0722*B
          final luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;
          sum += luma;
          count++;
        }
      }

      final avgLuma = count > 0 ? sum / count : 128.0;
      // sharpness (mean magnitude Sobel grayscale)
      final gray = img.grayscale(cropped);
      final sob = img.sobel(gray);
      double edgeSum = 0;
      int edgeCount = 0;
      for (int y = 0; y < sob.height; y += 4) {
        for (int x = 0; x < sob.width; x += 4) {
          edgeSum += img.getLuminance(sob.getPixel(x, y));
          edgeCount++;
        }
      }
      final sharp = edgeCount > 0 ? edgeSum / edgeCount : 0;

      final tips = <String>[];
      bool ok = true;

      if (avgLuma < 80) {
        tips.add('Pencahayaan redup — hadapkan wajah ke sumber cahaya.');
        ok = false;
      } else if (avgLuma > 220) {
        tips.add('Terlalu terang — hindari cahaya langsung/backlight kuat.');
        ok = false;
      }

      if (sharp < 18) {
        tips.add('Foto cenderung buram — pegang perangkat stabil.');
        ok = false;
      } else if (sharp < 26) {
        tips.add('Ketajaman pas — coba tahan sebentar sebelum jepret.');
      }

      if (ok && sharp < 30) {
        tips.add('Pastikan wajah berada di dalam lingkaran panduan.');
      }

      if (tips.isEmpty) tips.add('Foto terlihat bagus untuk didaftarkan.');

      return (tips, ok);
    } catch (e) {
      return (['Analisis gagal: $e'], true);
    }
  }

  Future<void> _submitReviewed() async {
    if (!_reviewMode) return;
    final prov = context.read<FaceEnrollProvider>();
    final file = _reviewFile!;
    setState(() => _taking = true);
    try {
      final ok = await prov.enrollFace(userId: widget.userId, image: file);
      if (!mounted) return;

      if (ok) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Berhasil!',
          text: 'Wajah Anda berhasil didaftarkan.',
          confirmBtnText: 'Lanjut',
          onConfirmBtnTap: () {
            Navigator.of(context).pop(); // tutup dialog
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home-screen', (r) => false);
          },
        );
      } else {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text:
              context.read<FaceEnrollProvider>().error ??
              'Enroll gagal. Coba lagi.',
          confirmBtnText: 'OK',
        );
      }
    } finally {
      if (mounted) setState(() => _taking = false);
    }
  }

  Future<void> _retake() async {
    try {
      await _reviewFile?.delete();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _reviewFile = null;
      _reviewTips = [];
      _reviewQualityOK = false;
    });
    await _startStream();
  }

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
        final screenAR = size.aspectRatio;
        final previewAR = previewSize.aspectRatio;
        final scale = screenAR > previewAR ? screenAR / previewAR : 1.0;

        Widget preview = CameraPreview(c);

        if (_mirrorFrontPreview && _isFront) {
          preview = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(math.pi),
            child: preview,
          );
        }

        // tap-to-focus & exposure
        preview = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) async {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;

            final local = box.globalToLocal(details.globalPosition);
            final w = box.size.width;
            final h = box.size.height;

            var rel = Offset(
              (local.dx / w).clamp(0.0, 1.0),
              (local.dy / h).clamp(0.0, 1.0),
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(child: preview),
                if (_reviewMode)
                  Container(color: Colors.black.withOpacity(0.45)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    final saving = context.read<FaceEnrollProvider>().saving;
    return !(_taking || saving);
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<FaceEnrollProvider>().saving;
    final size = MediaQuery.of(context).size;

    final circleDiameter = (math.min(size.width, size.height) * 0.65).clamp(
      240.0,
      340.0,
    );

    final safeTop = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // preview kamera
            Positioned.fill(child: _buildFullCamera()),

            // lingkaran panduan
            if (!_reviewMode)
              Center(
                child: IgnorePointer(
                  child: Container(
                    width: circleDiameter,
                    height: circleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.85),
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

            // ====== BAR ATAS (tidak saling tumpuk) ======
            // tombol back
            Positioned(
              left: 16,
              top: safeTop + 8,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: IconButton(
                  onPressed: (_taking || saving)
                      ? null
                      : () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: (_taking || saving) ? Colors.black26 : Colors.black,
                  ),
                ),
              ),
            ),

            // chip zoom (kanan atas)
            if (!_reviewMode)
              Positioned(
                right: 16,
                top: safeTop + 8,
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

            // chip cahaya (di bawah chip zoom)
            if (!_reviewMode)
              Positioned(
                right: 16,
                top: safeTop + 40,
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
                      _lightLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),

            // tips adaptif (digeser turun + disisihkan kiri/kanan)
            if (!_reviewMode)
              Positioned(
                // sisakan ruang 72 di kiri (diameter circle back + margin)
                left: 72,
                // sisakan ruang ±120 di kanan untuk chip zoom & cahaya
                right: 120,
                // diletakkan di bawah bar atas supaya tidak bertabrakan
                top: safeTop + 72,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _hint,
                      maxLines: 2,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),

            // tombol shutter/submit ATAU panel review
            if (!_reviewMode)
              Positioned(
                left: 20,
                right: 20,
                bottom: 24 + MediaQuery.of(context).padding.bottom,
                child: ElevatedButton(
                  onPressed:
                      (_controller?.value.isInitialized ?? false) &&
                          !_taking &&
                          !saving
                      ? _takeAndSubmit
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
                    _taking || saving ? 'Memproses...' : 'Ambil Foto',
                  ),
                ),
              )
            else
              _buildReviewPanel(),

            // overlay loading global
            if (_taking || saving)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x35000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewPanel() {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: MediaQuery.of(context).padding.top + 56,
      child: Column(
        children: [
          // Pratinjau foto yang diambil
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _reviewFile == null
                    ? const SizedBox.shrink()
                    : Image.file(_reviewFile!, fit: BoxFit.cover),
              ),
            ),
          ),
          // Tips kualitas + aksi
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safeBottom),
            decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      _reviewQualityOK ? Icons.check_circle : Icons.error,
                      color: _reviewQualityOK
                          ? Colors.greenAccent
                          : Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _reviewQualityOK
                          ? 'Kualitas foto baik'
                          : 'Perlu perbaikan sebelum kirim',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _reviewTips
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• $t',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (_taking) ? null : _retake,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Foto Ulang'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_taking) ? null : _submitReviewed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE93353),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Gunakan Foto'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
