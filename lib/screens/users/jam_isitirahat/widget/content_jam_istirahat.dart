// lib/screens/users/jam_isitirahat/widget/content_jam_istirahat.dart

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/providers/istirahat/istirahat_provider.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ContentJamIstirahat extends StatefulWidget {
  final Color primary;
  final Color accent;

  const ContentJamIstirahat({
    super.key,
    this.primary = const Color(0xFF9ED3F5),
    this.accent = const Color(0xFF317EA6),
  });

  @override
  State<ContentJamIstirahat> createState() => _ContentJamIstirahatState();
}

class _ContentJamIstirahatState extends State<ContentJamIstirahat> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final id = await resolveUserId(auth, context: context);
      if (id != null) {
        setState(() => _userId = id);
        context.read<IstirahatProvider>().fetchStatus(id);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset dan mulai ulang timer saat status provider berubah
    final provider = context.watch<IstirahatProvider>();
    if (provider.isIstirahatActive) {
      _startTimer(provider.status!.activeBreak!.startIstirahat!);
    } else {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime startTime) {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsed = DateTime.now().difference(startTime);
      });
    });
  }

  void _stopTimer() {
    _ticker?.cancel();
    if (mounted && _elapsed != Duration.zero) {
      setState(() {
        _elapsed = Duration.zero;
      });
    }
  }

  String get _mmss {
    if (_elapsed.inSeconds < 0) return '00:00';
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen, buka pengaturan.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _handleButtonPress(IstirahatProvider provider) async {
    if (provider.saving || _userId == null) return;

    try {
      final position = await _getCurrentPosition();
      if (!mounted) return;

      bool success;
      if (provider.isIstirahatActive) {
        success = await provider.endIstirahat(
          userId: _userId!,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        success = await provider.startIstirahat(
          userId: _userId!,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      if (!mounted) return;
      final message = provider.message ?? provider.error;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success
                ? AppColors.succesColor
                : AppColors.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<IstirahatProvider>(
      builder: (context, provider, child) {
        final bool isActive = provider.isIstirahatActive;
        final bool isLoading = provider.loading || provider.saving;

        return Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                isActive ? 'Waktu Istirahat Berjalan' : 'Mulai Istirahat',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2C5163),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
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
                      child: provider.loading && !isActive
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _mmss,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => _handleButtonPress(provider),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: const StadiumBorder(),
                    elevation: 6,
                    shadowColor: widget.primary.withOpacity(0.6),
                    backgroundColor: widget.primary,
                    foregroundColor: const Color(0xFF1C4660),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1C4660),
                          ),
                        )
                      : Text(
                          isActive ? 'Selesai' : 'Mulai',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppColors.errorColor),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
