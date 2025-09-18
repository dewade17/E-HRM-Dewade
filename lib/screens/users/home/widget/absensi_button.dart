// lib/screens/users/home/widget/absensi_button.dart

// ignore_for_file: use_build_context_synchronously

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/absensi/absensi_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/absensi_checkin_screen.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkout/absensi_checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget berdikari untuk tombol Absensi:
/// - ambil userId (AuthProvider -> SharedPreferences)
/// - fetch status absensi hari ini
/// - handle tap (navigate ke checkin/checkout)
/// - auto refresh saat app kembali ke foreground (resumed)
class AbsensiButton extends StatefulWidget {
  const AbsensiButton({super.key});

  @override
  State<AbsensiButton> createState() => _AbsensiButtonState();
}

class _AbsensiButtonState extends State<AbsensiButton>
    with WidgetsBindingObserver {
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Saat balik dari background, refresh status (agar aman saat ganti hari)
    if (state == AppLifecycleState.resumed && _userId != null) {
      context.read<AbsensiProvider>().fetchTodayStatus(_userId!);
    }
  }

  Future<void> _bootstrap() async {
    // 1) Ambil dari AuthProvider
    final auth = context.read<AuthProvider>();
    String? id = auth.currentUser?.idUser;

    // 2) Fallback ke SharedPreferences
    if (id == null) {
      final prefs = await SharedPreferences.getInstance();
      id = prefs.getString('id_user');
    }

    if (!mounted) return;
    setState(() => _userId = id);

    // 3) Tarik status absensi hari ini
    if (id != null) {
      await context.read<AbsensiProvider>().fetchTodayStatus(id);
    }
  }

  Future<void> _handleTap() async {
    final abs = context.read<AbsensiProvider>();
    final mode = abs.todayStatus?.mode ?? 'checkin';

    if (_userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User tidak ditemukan')));
      return;
    }

    if (mode == 'checkin') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AbsensiCheckinScreen(userId: _userId!),
        ),
      );
    } else if (mode == 'checkout') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AbsensiCheckoutScreen(userId: _userId!),
        ),
      );
    } else {
      // mode == 'done' -> tidak melakukan apa-apa
      return;
    }

    // setelah kembali, refresh status
    await abs.fetchTodayStatus(_userId!);
  }

  @override
  Widget build(BuildContext context) {
    final abs = context.watch<AbsensiProvider>();
    final loading = abs.loadingStatus && abs.todayStatus == null;

    // Tentukan enable/disable tombol
    final String mode = abs.todayStatus?.mode ?? 'checkin';
    bool enabled =
        !loading &&
        _userId != null &&
        (mode == 'checkin' || mode == 'checkout');

    return GestureDetector(
      onTap: enabled ? _handleTap : null,
      child: Card(
        color: enabled ? AppColors.errorColor : Colors.grey.shade400,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 110, vertical: 15),
          child: _AbsensiButtonLabel(), // label reaktif dari provider
        ),
      ),
    );
  }
}

/// Widget kecil yang hanya mengurus label agar rebuild-nya ringan.
class _AbsensiButtonLabel extends StatelessWidget {
  const _AbsensiButtonLabel();

  @override
  Widget build(BuildContext context) {
    final abs = context.watch<AbsensiProvider>();
    final loading = abs.loadingStatus && abs.todayStatus == null;

    String label;
    if (loading) {
      label = 'Memuat...';
    } else {
      switch (abs.todayStatus?.mode) {
        case 'checkin':
          label = 'Masuk (Check-in)';
          break;
        case 'checkout':
          label = 'Pulang (Check-out)';
          break;
        case 'done':
          label = 'Sudah Selesai Hari Ini';
          break;
        default:
          label = 'Masuk (Check-in)';
      }
    }

    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.accentColor,
      ),
    );
  }
}
