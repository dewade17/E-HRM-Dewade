import 'dart:math' as math;
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkout/widget/content_absensi_checkout.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkout/widget/header_absensi_checkout.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AbsensiCheckoutScreen extends StatefulWidget {
  final String? userId;
  const AbsensiCheckoutScreen({super.key, this.userId});

  @override
  State<AbsensiCheckoutScreen> createState() => _AbsensiCheckoutScreenState();
}

class _AbsensiCheckoutScreenState extends State<AbsensiCheckoutScreen> {
  String? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initUserId();
  }

  Future<void> _initUserId() async {
    final provided = widget.userId;
    if (provided != null && provided.isNotEmpty) {
      setState(() {
        _userId = provided;
        _loading = false;
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final resolved = await resolveUserId(auth, context: context);

    if (!mounted) return;

    setState(() {
      _userId = resolved;
      _loading = false;
    });

    if (resolved == null || resolved.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
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
                          const HeaderAbsensiCheckout(),
                          const SizedBox(height: 30),
                          ContentAbsensiCheckout(userId: _userId!),
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
