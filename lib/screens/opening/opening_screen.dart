// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_hrm/utils/auth_utils.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    // Cek token setelah frame pertama supaya Navigator siap.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // --- TAMBAHKAN PEMERIKSAAN 'mounted' ---
      if (!mounted) return;
      await AuthUtils.checkLoginStatus(context);
      if (!mounted) return;
      setState(() => _checking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'lib/assets/image/bg_login.png',
                fit: BoxFit.cover,
              ),
            ),

            // Konten utama
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "ONE STEP SOLUTION",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "WE MAKE YOUR PRIORITY",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.backgroundColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Image.asset(
                        'lib/assets/image/icon_bg.png',
                        width: 380,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),

                      // Tombol Login (muncul saat user belum login)
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            foregroundColor: AppColors.accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _checking
                              ? null
                              : () {
                                  Navigator.of(context).pushNamed('/login');
                                },
                          child: Text(
                            "Login",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Overlay loading saat proses cek token
            if (_checking)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.08),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
