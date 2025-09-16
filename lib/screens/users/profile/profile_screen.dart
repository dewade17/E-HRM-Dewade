// lib/screens/users/profile/profile_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:e_hrm/dto/users/users.dart';
import 'package:e_hrm/providers/users/users_provider.dart';
import 'package:e_hrm/screens/users/profile/widget/profile_header.dart';
import 'package:e_hrm/screens/users/profile/widget/button_profile.dart';
import 'package:e_hrm/screens/users/profile/widget/form_profile.dart';
import 'package:e_hrm/screens/users/profile/widget/half_oval_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameprofileController = TextEditingController();
  final emailprofileController = TextEditingController();
  final kontakprofileController = TextEditingController();
  final agamaprofileController = TextEditingController();
  final dateprofileController = TextEditingController();
  final departementprofileController = TextEditingController();
  final alamatkantorprofileController = TextEditingController();

  File? _pickedFile;
  String? _userId;

  // guards
  bool _didRequest = false; // supaya fetchById hanya sekali
  bool _didPrefill = false; // supaya isi controller hanya sekali

  @override
  void initState() {
    super.initState();
    _readUserIdFromToken(); // ambil userId dari JWT lokal
  }

  Future<void> _readUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final payload = JwtDecoder.decode(token);
    setState(() {
      _userId = (payload['id_user'] ?? payload['sub'] ?? payload['userId'])
          ?.toString();
    });
  }

  void _prefillOnce(Users u) {
    if (_didPrefill) return;
    _didPrefill = true;

    nameprofileController.text = u.namaPengguna;
    emailprofileController.text = u.email;
    kontakprofileController.text = u.kontak ?? '';
    agamaprofileController.text = u.agama ?? '';
    dateprofileController.text = u.tanggalLahir == null
        ? ''
        : u.tanggalLahir!.toIso8601String().split('T').first;

    departementprofileController.text = u.departement?.namaDepartement ?? '';
    alamatkantorprofileController.text = u.kantor?.namaKantor ?? '';
  }

  Future<void> _save() async {
    final prov = context.read<UserDetailProvider>();
    if (_userId == null) return;

    DateTime? tgl;
    if (dateprofileController.text.trim().isNotEmpty) {
      tgl = DateTime.tryParse(dateprofileController.text.trim());
    }

    bool ok;
    if (_pickedFile != null) {
      ok = await prov.updateByIdWithPhoto(
        _userId!,
        foto: XFile(_pickedFile!.path),
        namaPengguna: nameprofileController.text,
        email: emailprofileController.text,
        kontak: kontakprofileController.text,
        agama: agamaprofileController.text,
        tanggalLahir: tgl,
      );
    } else {
      ok = await prov.updateByIdJson(
        _userId!,
        namaPengguna: nameprofileController.text,
        email: emailprofileController.text,
        kontak: kontakprofileController.text,
        agama: agamaprofileController.text,
        tanggalLahir: tgl,
      );
    }

    if (!mounted) return;
    final msg =
        prov.error ??
        prov.message ??
        (ok ? 'Profil tersimpan.' : 'Gagal menyimpan.');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    if (ok && prov.user != null) {
      _pickedFile = null; // reset foto lokal
      _didPrefill = false;
      _prefillOnce(prov.user!);
      setState(() {}); // perbarui avatar dari URL terbaru
    }
  }

  @override
  void dispose() {
    nameprofileController.dispose();
    emailprofileController.dispose();
    kontakprofileController.dispose();
    agamaprofileController.dispose();
    dateprofileController.dispose();
    departementprofileController.dispose();
    alamatkantorprofileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserDetailProvider>(
      // ⬇️ injeksi ApiService dari tree (pastikan ApiService diprovide di main.dart)
      create: (ctx) => UserDetailProvider(),
      child: Consumer<UserDetailProvider>(
        builder: (ctx, prov, _) {
          // trigger fetch sekali ketika userId sudah ada & belum ada data
          if (_userId != null &&
              prov.user == null &&
              !_didRequest &&
              !prov.loading) {
            _didRequest = true;
            Future.microtask(() async {
              final ok = await prov.fetchById(_userId!);
              if (ok && prov.user != null) {
                _prefillOnce(prov.user!);
                if (mounted) setState(() {}); // supaya imageUrl update
              }
            });
          }

          final u = prov.user;
          final imageUrlForForm = _pickedFile != null
              ? null
              : ((u?.fotoProfilUser?.isNotEmpty ?? false)
                    ? u!.fotoProfilUser
                    : null);

          return Scaffold(
            body: SingleChildScrollView(
              child: SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: CustomPaint(painter: HalfOvalPainter()),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 170, 15, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FormProfile(
                              nameprofileController: nameprofileController,
                              emailprofileController: emailprofileController,
                              kontakprofileController: kontakprofileController,
                              agamaprofileController: agamaprofileController,
                              dateprofileController: dateprofileController,
                              departementrofileController:
                                  departementprofileController,
                              alamatkantorprofileController:
                                  alamatkantorprofileController,
                              imageUrl: imageUrlForForm,
                              onImagePicked: (File? f) =>
                                  setState(() => _pickedFile = f),
                              onRemovePhoto: () async {
                                if (_userId == null) return;
                                final ok = await prov.removePhoto(_userId!);
                                if (!mounted) return;
                                final msg =
                                    prov.error ??
                                    prov.message ??
                                    (ok
                                        ? 'Foto dihapus.'
                                        : 'Gagal hapus foto.');
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(msg)));
                              },
                            ),
                            const SizedBox(height: 16),
                            ButtonProfile(
                              onPressed: prov.saving ? null : _save,
                            ),
                            const SizedBox(height: 32),
                            if (prov.loading || prov.saving)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    prov.loading
                                        ? 'Memuat profil...'
                                        : 'Menyimpan...',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      Positioned(top: 30, left: 20, child: ProfileHeader()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
