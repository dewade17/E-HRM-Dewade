import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/absensi/absensi_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/screens/payment.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/absensi_checkin_screen.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkout/absensi_checkout_screen.dart';
import 'package:e_hrm/screens/users/dashboard.dart';
import 'package:e_hrm/screens/users/home/widget/header_home.dart';
import 'package:e_hrm/screens/users/home/widget/home_content.dart';
import 'package:e_hrm/screens/users/home/widget/information_home.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenContent(),
    const Dashboard(), // halaman biasa
    const Payment(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.notifications, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        color: AppColors.primaryColor,
        buttonBackgroundColor: AppColors.secondaryColor,
        backgroundColor: Colors.transparent,
        height: 60,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// Konten untuk tab pertama
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent>
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
    // 1) Ambil dari AuthProvider dulu
    final auth = context.read<AuthProvider>();
    String? id = auth.currentUser?.idUser;

    // 2) Fallback ke SharedPreferences jika perlu (aman setelah restart app)
    if (id == null) {
      final prefs = await SharedPreferences.getInstance();
      id = prefs.getString('id_user');
    }

    if (!mounted) return;
    setState(() => _userId = id);

    // 3) Tarik status absensi hari ini dari server
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

    // Buka screen sesuai mode
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
      // done -> sudah selesai, jangan apa-apa
      return;
    }

    // Setelah kembali, refresh status lagi
    await abs.fetchTodayStatus(_userId!);
  }

  @override
  Widget build(BuildContext context) {
    final abs = context.watch<AbsensiProvider>();
    final loading = abs.loadingStatus && abs.todayStatus == null;

    String label;
    bool enabled;

    if (loading) {
      label = 'Memuat...';
      enabled = false;
    } else {
      switch (abs.todayStatus?.mode) {
        case 'checkin':
          label = 'Masuk (Check-in)';
          enabled = true;
          break;
        case 'checkout':
          label = 'Pulang (Check-out)';
          enabled = true;
          break;
        case 'done':
          label = 'Sudah Selesai Hari Ini';
          enabled = false;
          break;
        default:
          label = 'Masuk (Check-in)';
          enabled = true;
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: HeaderHome(),
            ),
            const InformationHome(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  "Menu",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDefaultColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const HomeContent(),
            const SizedBox(height: 40),

            // Tombol Absensi Dinamis (ganti '/absensi-center')
            GestureDetector(
              onTap: enabled ? _handleTap : null,
              child: Card(
                color: enabled ? AppColors.errorColor : Colors.grey.shade400,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 110, vertical: 15),
                  child:
                      _AbsensiButtonLabel(), // pakai builder biar teks ikut provider
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget kecil untuk ambil label terbaru dari provider (tanpa rebuild besar)
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
