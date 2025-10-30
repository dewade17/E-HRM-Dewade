// lib/screens/users/home/home_screen.dart

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/absensi/absensi_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/providers/profile/profile_provider.dart';
import 'package:e_hrm/providers/shift_kerja/shift_kerja_realtime_provider.dart';
import 'package:e_hrm/screens/users/calender_view/calendar_view_screen.dart';
import 'package:e_hrm/screens/users/home/widget/header_home.dart';
import 'package:e_hrm/screens/users/home/widget/home_content.dart';
import 'package:e_hrm/screens/users/home/widget/information_home.dart';
import 'package:e_hrm/screens/users/home/widget/absensi_button.dart';
import 'package:e_hrm/screens/users/notification/notification_screen.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreenContent(),
    NotificationScreen(),
    CalendarViewScreen(),
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
          Icon(Icons.calendar_month, color: Colors.white),
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

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  Future<void> _handleRefresh() async {
    // 1. Ambil semua provider yang dibutuhkan
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final shiftProvider = context.read<ShiftKerjaRealtimeProvider>();
    final absensiProvider = context.read<AbsensiProvider>();

    // 2. Dapatkan user ID yang sedang aktif
    final userId = await resolveUserId(authProvider, context: context);
    if (userId == null || userId.isEmpty) {
      // Jika tidak ada user ID, hentikan proses refresh
      return;
    }

    // 3. Jalankan semua proses fetch data secara bersamaan
    await Future.wait([
      profileProvider.fetchProfile(userId),
      shiftProvider.fetch(idUser: userId, date: DateTime.now()),
      absensiProvider.fetchTodayStatus(userId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: HeaderHome(),
              ),
              InformationHome(),
              Align(
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
              SizedBox(height: 10),
              HomeContent(),
              SizedBox(height: 10),
              AbsensiButton(),
            ],
          ),
        ),
      ),
    );
  }
}
