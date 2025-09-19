import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FullScreenFaceCamera extends StatefulWidget {
  const FullScreenFaceCamera({super.key});

  @override
  State<FullScreenFaceCamera> createState() => _FullScreenFaceCameraState();
}

class _FullScreenFaceCameraState extends State<FullScreenFaceCamera>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _init;
  bool _taking = false;

  final bool _mirrorFrontPreview = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
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
    }
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final selected = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      final controller = CameraController(
        selected,
        ResolutionPreset.high, // ganti ke medium kalau emulator berat
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      final init = controller.initialize();
      setState(() {
        _controller = controller;
        _init = init;
      });
      await init;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_taking) return;
    setState(() => _taking = true);
    try {
      final file = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.pop(context, file); // atau lanjut ke preview
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
        final r = c.value.aspectRatio; // w/h sensor
        final isFront =
            c.description.lensDirection == CameraLensDirection.front;

        // Trik “cover”: scale supaya CameraPreview menutup sisi pendek layar
        // Gunakan LayoutBuilder untuk hitung skala relatif terhadap layar
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final screenH = constraints.maxHeight;
            final screenRatio = screenW / screenH;

            // Jika preview lebih lebar dari layar -> butuh scale vertical, sebaliknya scale horizontal.
            double scale = 1.0;
            if (r < screenRatio) {
              // preview lebih “tinggi” daripada layar => perlebar preview
              scale = screenRatio / r;
            } else {
              // preview lebih “lebar” daripada layar => pertebal tinggi preview
              scale = r / screenRatio;
            }

            Widget preview = CameraPreview(c);
            if (_mirrorFrontPreview && isFront) {
              preview = Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: preview,
              );
            }

            return Transform.scale(
              scale: scale, // ini yang bikin full screen tanpa gepeng
              child: Center(
                child: AspectRatio(aspectRatio: r, child: preview),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final circleDiameter = (math.min(size.width, size.height) * 0.52).clamp(
      220.0,
      320.0,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1) FULLSCREEN CAMERA
          Positioned.fill(child: _buildFullCamera()),

          // 2) OVERLAY TOP: lingkaran panduan transparan
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: circleDiameter,
                  height: circleDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06), // efek kabut
                    border: Border.all(
                      color: Colors.white.withOpacity(0.85),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3) BOTTOM SHEET INFO (tiruan kartu pada screenshot)
          Positioned(left: 16, right: 16, bottom: 96, child: _InfoCard()),

          // 4) BOTTOM BUTTON
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
              child: Text(_taking ? 'Memproses...' : 'Presensi Keluar'),
            ),
          ),

          // 5) Tombol back bulat di kiri
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
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
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
