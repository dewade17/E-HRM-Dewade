// lib/screens/face/face_enroll_screen.dart

// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:e_hrm/providers/face/face_enroll/face_enroll_provider.dart';

class FaceEnrollScreen extends StatefulWidget {
  final String userId;

  const FaceEnrollScreen({super.key, required this.userId});

  @override
  State<FaceEnrollScreen> createState() => _FaceEnrollScreenState();
}

class _FaceEnrollScreenState extends State<FaceEnrollScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _shot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _takePhoto();
    });
  }

  Future<void> _takePhoto() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1280,
        imageQuality: 90,
      );
      if (x != null && mounted) {
        setState(() => _shot = x);
      }
    } catch (e) {
      if (mounted) _snack('Gagal membuka kamera: $e', isError: true);
    }
  }

  // --- FUNGSI INI YANG DIPERBARUI ---
  Future<void> _submit() async {
    final prov = context.read<FaceEnrollProvider>();

    // PERBAIKAN: Cek apakah proses sedang berjalan. Jika ya, jangan lakukan apa-apa.
    if (prov.saving || _shot == null) return;

    final ok = await prov.enrollFace(
      userId: widget.userId,
      image: File(_shot!.path),
    );

    if (!mounted) return;

    if (ok) {
      _snack(prov.message ?? 'Enroll berhasil.');
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home-screen', (r) => false);
    } else {
      _snack(prov.error ?? 'Enroll gagal.', isError: true);
    }
  }
  // --- AKHIR PERBAIKAN ---

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Anda sudah memantau state 'saving' di sini, ini sudah benar.
    final saving = context.watch<FaceEnrollProvider>().saving;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // AbsorbPointer juga sudah benar, mencegah interaksi saat loading.
        child: AbsorbPointer(
          absorbing: saving,
          child: Stack(
            children: [
              if (saving)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x55000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Silahkan daftarkan wajah anda',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _shot == null
                          ? Icon(
                              Icons.face,
                              size: 120,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.3),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.file(
                                File(_shot!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        // Logika 'onPressed' Anda sudah baik, karena menggunakan 'saving'
                        // dari provider untuk menonaktifkan tombol.
                        onPressed: saving
                            ? null
                            : () {
                                if (_shot == null) {
                                  _takePhoto();
                                } else {
                                  _submit();
                                }
                              },
                        child: Text(
                          _shot == null ? 'Ambil Foto' : 'Simpan',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
