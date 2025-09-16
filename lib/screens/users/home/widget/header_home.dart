import 'package:e_hrm/providers/auth/auth_provider.dart'; // hanya untuk logout
import 'package:e_hrm/providers/users/users_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderHome extends StatefulWidget {
  const HeaderHome({super.key});

  @override
  State<HeaderHome> createState() => _HeaderHomeState();
}

class _HeaderHomeState extends State<HeaderHome> {
  @override
  void initState() {
    super.initState();
    // 1) Ambil id_user dari SharedPreferences
    // 2) Panggil fetch detail lewat UserDetailProvider
    _loadIdAndFetch();
  }

  Future<void> _loadIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final id = (prefs.getString('id_user') ?? '').trim();
    if (id.isEmpty) return;

    if (!mounted) return;

    // Fetch detail HANYA lewat UserDetailProvider
    final detail = context.read<UserDetailProvider>();
    if (detail.user == null || detail.user!.idUser != id) {
      await detail.fetchById(id);
    }
  }

  String _safe(String? s, {String fallback = "-"}) {
    final t = (s ?? '').trim();
    return t.isEmpty ? fallback : t;
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<UserDetailProvider>();

    // Sumber tampilan: HANYA dari UserDetailProvider
    final name = _safe(detail.user?.namaPengguna);
    final dept = _safe(detail.user?.departement?.namaDepartement);

    // Agar teks tidak melebar, beri batas maksimum
    final w = MediaQuery.of(context).size.width;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Align(
          alignment: Alignment.centerRight, // selalu di kanan
          child: Row(
            mainAxisSize: MainAxisSize.min, // tidak ambil lebar penuh
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Kolom teks dengan batas lebar -> tetap rapi dan nempel kanan
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: w * 0.60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (detail.loading && detail.user == null)
                      // Skeleton sementara menunggu fetch detail
                      Container(height: 16, width: 120, color: Colors.black12)
                    else
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 2),
                    if (detail.loading && detail.user == null)
                      Container(height: 12, width: 80, color: Colors.black12)
                    else
                      Text(
                        dept,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Avatar menu bulat (logout masih pakai AuthProvider — OK)
              PopupMenuButton<int>(
                tooltip: 'Akun',
                padding: EdgeInsets.zero,
                onSelected: (action) async {
                  final nav = Navigator.of(context, rootNavigator: true);
                  if (action == 2) {
                    nav.pushNamed('/profile-screen');
                  } else if (action == 4) {
                    await context.read<AuthProvider>().logout(context);
                    nav.pushReplacementNamed('/login');
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.person_2_outlined),
                        SizedBox(width: 8),
                        Text('Lihat Profil'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 4,
                    child: Row(
                      children: [
                        Icon(Icons.logout_outlined),
                        SizedBox(width: 8),
                        Text('Keluar'),
                      ],
                    ),
                  ),
                ],
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
