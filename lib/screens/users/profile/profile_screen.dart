import 'dart:math' as math;

import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/providers/profile/profile_provider.dart';
import 'package:e_hrm/screens/users/profile/widget/form_profile.dart';
import 'package:e_hrm/screens/users/profile/widget/half_oval_painter_profile.dart';
import 'package:e_hrm/screens/users/profile/widget/header_profile.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    // Pastikan data profil termuat ketika halaman dibuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile({bool force = false}) async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final resolvedId = await resolveUserId(auth, context: context);
    if (!mounted) return;

    if (resolvedId == null || resolvedId.trim().isEmpty) {
      setState(() => _userId = null);
      return;
    }

    setState(() => _userId = resolvedId);

    final profileProvider = context.read<ProfileProvider>();
    if (!force && profileProvider.profile?.idUser == resolvedId) {
      return;
    }

    await profileProvider.fetchProfile(resolvedId);
  }

  Future<void> _refresh() => _loadProfile(force: true);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final isInitialLoading = profileProvider.loading && profile == null;
    final error = profileProvider.error;

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
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: const BlurHalfOvalHeader(height: 240, sigma: 0),
            ),
          ),
          // === Konten utama (scrollable) ===
          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // full width secara horizontal
                  padding: const EdgeInsets.fromLTRB(0, 80, 0, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 100),
                      if (isInitialLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (error != null && profile == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade400,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat profil',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => _refresh(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        )
                      else if ((_userId != null &&
                              _userId!.trim().isNotEmpty) ||
                          profile != null)
                        FormProfile(
                          provider: profileProvider,
                          userId: _userId ?? profile?.idUser,
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person_off_outlined,
                                size: 48,
                                color: Colors.black45,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'ID pengguna tidak ditemukan.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(top: 40, left: 10, child: HeaderProfile()),
        ],
      ),
    );
  }
}
