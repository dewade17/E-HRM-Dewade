import 'dart:math' as math;
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/notification/widget/notification_content.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Fungsi yang akan dipanggil saat ikon notifikasi di-tap.
  // Saat ini hanya menampilkan pesan di konsol (debug).
  void _onNotificationIconTap() {
    // Di sini kamu bisa menambahkan logika seperti
    // menavigasi ke pengaturan notifikasi atau membuka menu.
    debugPrint("Tombol notifikasi di-tap!");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final iconMax = (math.min(size.width, size.height) * 0.4).clamp(
      320.0,
      360.0,
    );
    return Scaffold(
      backgroundColor:
          Colors.white, // Tambahkan ini agar warna latar belakang konsisten
      appBar: AppBar(
        // PERCANTIK: Hapus bayangan (shadow) untuk tampilan lebih datar
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Notifikasi",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDefaultColor,
          ),
        ),
        centerTitle: true,

        // MENAMBAH IKON NOTIF: Gunakan properti actions
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none, // Ikon notifikasi (lonceng)
              color: AppColors.textDefaultColor, // Sesuaikan warna ikon
            ),
            onPressed: _onNotificationIconTap, // Panggil fungsi saat di-tap
          ),
          const SizedBox(width: 8), // Sedikit jarak di sebelah kanan
        ],
      ),
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

          // Konten utama
          Positioned.fill(
            child: SafeArea(
              left: false,
              right: false,
              child: NotificationContent(),
            ),
          ),
        ],
      ),
    );
  }
}
