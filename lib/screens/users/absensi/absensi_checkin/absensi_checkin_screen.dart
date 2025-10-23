// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:math' as math;
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/content_absensi_checkin.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkin/widget/header_absensi_checkin.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AbsensiCheckinScreen extends StatefulWidget {
  final String? userId;
  const AbsensiCheckinScreen({super.key, this.userId});

  @override
  State<AbsensiCheckinScreen> createState() => _AbsensiCheckinScreenState();
}

class _AbsensiCheckinScreenState extends State<AbsensiCheckinScreen> {
  String? _userId;
  bool _loading = true;

  // KUNCI PENTING: pakai untuk memaksa rebuild konten saat refresh
  Key _contentKey = UniqueKey();

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

  // Tarik untuk refresh: selain resolve ulang user id,
  // ganti _contentKey supaya ContentAbsensiCheckin re-initialize (initState jalan lagi).
  Future<void> _refreshData() async {
    await _initUserId();
    setState(() {
      _contentKey = UniqueKey();
    });
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
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.fingerprint_rounded,
                  size: iconMax,
                  color: AppColors.primaryColor.withOpacity(0.04),
                ),
              ),
            ),
          ),
          SafeArea(
            left: false,
            right: false,
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_userId == null || _userId!.isEmpty)
                  ? const Center(child: Text("Silahkan Login Kembali."))
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          const HeaderAbsensiCheckin(),
                          const SizedBox(height: 30),
                          // PASANG KEY DI SINI!
                          ContentAbsensiCheckin(
                            key: _contentKey,
                            userId: _userId!,
                          ),
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
