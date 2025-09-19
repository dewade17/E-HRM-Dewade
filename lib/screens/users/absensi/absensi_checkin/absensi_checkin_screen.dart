// ignore_for_file: use_build_context_synchronously

import 'dart:math' as math;

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/content_absensi_checkin.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/header_absensi_checkin.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsensiCheckinScreen extends StatefulWidget {
  final String? userId;
  const AbsensiCheckinScreen({super.key, this.userId});

  @override
  State<AbsensiCheckinScreen> createState() => _AbsensiCheckinScreenState();
}

class _AbsensiCheckinScreenState extends State<AbsensiCheckinScreen> {
  String? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initUserId();
  }

  //TODO: gunakan pengambilan id_user menggunakan id_user_resolver.dart
  Future<void> _initUserId() async {
    // 1) Kalau constructor sudah ngasih, pakai itu dulu
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      setState(() {
        _userId = widget.userId!;
        _loading = false;
      });
      return;
    }

    // 2) Coba ambil dari AuthProvider (lebih cepat, sudah ada di memori)
    try {
      final auth = context.read<AuthProvider>();
      final fromProvider = auth.currentUser?.idUser;
      if (fromProvider != null && fromProvider.isNotEmpty) {
        setState(() {
          _userId = fromProvider;
          _loading = false;
        });
        return;
      }
    } catch (_) {
      // provider belum tersedia di tree, lanjut ke prefs
    }

    // 3) Fallback: SharedPreferences 'id_user'
    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = prefs.getString('id_user');

    setState(() {
      _userId = fromPrefs; // bisa null kalau belum login
      _loading = false;
    });

    if (_userId == null || _userId!.isEmpty) {
      // Tampilkan snackbar informatif
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Silakan login ulang."),
            backgroundColor: AppColors.errorColor,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final iconMax = (math.min(size.width, size.height) * 0.4).clamp(
      320.0,
      360.0,
    );
    return Scaffold(
      body: Stack(
        children: [
          // BG ikon samar di tengah
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    'lib/assets/image/icon_bg.png',
                    width: iconMax,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Image.asset(
                'lib/assets/image/Pattern.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // === Konten utama (scrollable) ===
          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_userId == null || _userId!.isEmpty)
                  ? const Center(child: Text("Silahkan Login Kembali."))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          const HeaderAbsensiCheckin(),
                          const SizedBox(height: 30),
                          ContentAbsensiCheckin(userId: _userId!),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
