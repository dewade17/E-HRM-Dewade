// lib/screens/users/jam_isitirahat/jam_istirahat_screen.dart

import 'dart:math' as math;
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/providers/istirahat/istirahat_provider.dart';
import 'package:e_hrm/screens/users/jam_isitirahat/widget/content_jam_istirahat.dart';
import 'package:e_hrm/screens/users/jam_isitirahat/widget/header_jam_istirahat.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JamIstirahatScreen extends StatefulWidget {
  const JamIstirahatScreen({super.key});

  @override
  State<JamIstirahatScreen> createState() => _JamIstirahatScreenState();
}

class _JamIstirahatScreenState extends State<JamIstirahatScreen> {
  Future<void> _refreshData() async {
    final provider = context.read<IstirahatProvider>();
    final auth = context.read<AuthProvider>();
    final userId = await resolveUserId(auth, context: context);
    if (userId != null) {
      await provider.fetchStatus(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconMax = (math.min(size.width, size.height) * 0.4).clamp(
      320.0,
      360.0,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
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

          Positioned.fill(
            child: SafeArea(
              left: false,
              right: false,
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(15, 120, 15, 24),
                  child: const ContentJamIstirahat(),
                ),
              ),
            ),
          ),
          const Positioned(top: 40, left: 10, child: HeaderJamIstirahat()),
        ],
      ),
    );
  }
}
