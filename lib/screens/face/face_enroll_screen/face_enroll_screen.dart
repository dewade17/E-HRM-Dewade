// lib/screens/face/face_enroll_screen.dart
// Screen untuk enroll wajah: 1x take foto, kirim via FaceEnrollProvider.

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
    // Secara otomatis memunculkan kamera setelah layar dimuat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePhoto();
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
      if (x != null) {
        setState(() => _shot = x);
      }
    } catch (e) {
      _snack('Gagal membuka kamera: $e', isError: true);
    }
  }

  Future<void> _submit() async {
    if (_shot == null) return;
    final prov = context.read<FaceEnrollProvider>();
    final ok = await prov.enrollFace(
      userId: widget.userId,
      image: File(_shot!.path),
    );

    if (!mounted) return;
    if (ok) {
      // Enrol berhasil, beri umpan balik ke pengguna
      _snack(prov.message ?? 'Enroll berhasil.');
      // Tidak perlu menyimpan flag face_enrolled di lokal. Setelah sukses,
      // langsung arahkan pengguna kembali ke home.
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home-screen', (r) => false);
      }
    } else {
      _snack(prov.error ?? 'Enroll gagal.', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<FaceEnrollProvider>().saving;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: saving,
          child: Stack(
            children: [
              // Overlay progress saat saving
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
