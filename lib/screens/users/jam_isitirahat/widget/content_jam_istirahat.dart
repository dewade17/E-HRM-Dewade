import 'dart:async';

import 'package:flutter/material.dart';

class ContentJamIstirahat extends StatefulWidget {
  final Duration total;
  final Color primary;
  final Color accent;
  const ContentJamIstirahat({
    super.key,
    this.total = const Duration(minutes: 5), // durasi default 5 menit
    this.primary = const Color(0xFF9ED3F5), // biru muda pada ring
    this.accent = const Color(0xFF317EA6), // biru lebih gelap untuk progres
  });

  @override
  State<ContentJamIstirahat> createState() => _ContentJamIstirahatState();
}

class _ContentJamIstirahatState extends State<ContentJamIstirahat> {
  Timer? _ticker;
  late Duration _remain;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remain = widget.total;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remain.inSeconds <= 1) {
        t.cancel();
        setState(() {
          _running = false;
          _remain = Duration.zero;
        });
        return;
      }
      setState(() {
        _remain = Duration(seconds: _remain.inSeconds - 1);
      });
    });
  }

  void _stopAndReset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _remain = widget.total;
    });
  }

  String get _mmss {
    final m = (_remain.inSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remain.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final total = widget.total.inSeconds.toDouble().clamp(1, double.infinity);
    final done = (total - _remain.inSeconds).clamp(0, total);
    return done / total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            _running ? 'Waktu Sisa Istirahat' : 'Mulai Istirahat',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2C5163),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          // Lingkaran timer
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // cincin dasar + progres
                CustomPaint(
                  size: const Size.square(240),
                  painter: _RingPainter(
                    progress: _progress,
                    baseColor: widget.primary.withOpacity(0.25),
                    progressColor: widget.primary,
                    accent: widget.accent,
                    stroke: 22,
                  ),
                ),
                // disk hitam di tengah
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        offset: Offset(0, 6),
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _running ? _mmss : '00:00',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Tombol Mulai / Selesai
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: _running ? _stopAndReset : _start,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: const StadiumBorder(),
                elevation: 6,
                shadowColor: widget.primary.withOpacity(0.6),
                backgroundColor: widget.primary,
                foregroundColor: const Color(0xFF1C4660),
              ),
              child: Text(
                _running ? 'Selesai' : 'Mulai',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Hint kecil
          if (!_running && _remain == Duration.zero)
            TextButton(
              onPressed: _stopAndReset,
              child: const Text('Reset ke 05:00'),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
    required this.accent,
    required this.stroke,
  });

  final double progress; // 0..1
  final Color baseColor;
  final Color progressColor;
  final Color accent;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - stroke / 2;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = baseColor;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -1.5708, // -90°
        endAngle: 4.7124, // 270°
        colors: [progressColor, accent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Gambar cincin dasar penuh
    canvas.drawCircle(center, radius, base);

    // Gambar arc progres
    final start = -1.5708; // mulai dari atas
    final sweep = 2 * 3.1415926535 * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.stroke != stroke;
  }
}
