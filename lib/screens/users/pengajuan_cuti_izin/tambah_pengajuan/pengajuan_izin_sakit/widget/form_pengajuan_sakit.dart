import 'dart:io';

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/approvers/approvers_absensi_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FormPengajuanSakit extends StatefulWidget {
  const FormPengajuanSakit({super.key});

  @override
  State<FormPengajuanSakit> createState() => _FormPengajuanSakitState();
}

class _FormPengajuanSakitState extends State<FormPengajuanSakit> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController jenisCutiController = TextEditingController();

  final TextEditingController handoverController = TextEditingController();
  final TextEditingController tanggalPengajuanSakitController =
      TextEditingController();

  DateTime? _tanggalPengajuanSakit;
  // DIUBAH: Gunakan File? dari dart:io
  File? _buktiFile;

  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    jenisCutiController.text = "Pengajuan Sakit";
  }

  @override
  void dispose() {
    jenisCutiController.dispose();
    handoverController.dispose();
    tanggalPengajuanSakitController.dispose();
    super.dispose();
  }

  void _submitForm() {
    setState(() {
      _autoValidate = true;
    });

    if (formKey.currentState?.validate() ?? false) {
      // TODO: Logika submit data pengajuan cuti
      print("Form valid. Mengirim data...");
      // Kirim _buktiFile (File) ke API Anda
      print("File yang diunggah: ${_buktiFile?.path ?? 'Tidak ada'}");
      print(
        "Ukuran file: ${_buktiFile != null ? _buktiFile!.lengthSync() : 0} bytes",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form Valid. Logika submit belum diimplementasikan.'),
          backgroundColor: AppColors.succesColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap periksa kembali semua isian form.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final autovalidateMode = _autoValidate
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            TextFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Jenis Cuti',
              controller: jenisCutiController,
              hintText: 'Pengajuan Sakit',
              isRequired: true,
              prefixIcon: Icons.description_outlined,
              keyboardType: TextInputType.text,
              maxLines: 1,
              enabled: false,
              autovalidateMode: autovalidateMode,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: FormField<Set<String>>(
                autovalidateMode: autovalidateMode,
                initialValue: context
                    .watch<ApproversProvider>()
                    .selectedRecipientIds,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penerima laporan (Supervisi) wajib dipilih.';
                  }
                  return null;
                },
                builder: (FormFieldState<Set<String>> state) {
                  final provider = context.watch<ApproversProvider>();
                  final currentValue = provider.selectedRecipientIds;
                  if (state.value != currentValue) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        state.didChange(currentValue);
                      }
                    });
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RecipientCuti(),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 8),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            DatePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Tanggal Pengajuan',
              controller: tanggalPengajuanSakitController,
              initialDate: _tanggalPengajuanSakit,
              onDateChanged: (date) =>
                  setState(() => _tanggalPengajuanSakit = date),
              isRequired: true,
            ),
            SizedBox(height: 20),
            TextFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Handover Pekerjaan',
              controller: handoverController,
              hintText: 'Handover Pekerjaan (min. 50 kata)',
              isRequired: true,
              prefixIcon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              autovalidateMode: autovalidateMode,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) {
                  return 'Handover Pekerjaan tidak boleh kosong';
                }
                final wordCount = v
                    .split(RegExp(r'\s+'))
                    .where((s) => s.isNotEmpty)
                    .length;
                if (wordCount < 50) {
                  return 'Minimal 50 kata. (Sekarang: $wordCount kata)';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // <-- DIUBAH: Menggunakan widget baru -->
            FilePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Unggah Bukti',
              buttonText: 'Unggah Bukti', // Sesuai desain
              prefixIcon: Icons.camera_alt_outlined,
              file: _buktiFile, // Kirim file dari state
              onFileChanged: (newFile) {
                // Terima file dan update state
                setState(() {
                  _buktiFile = newFile;
                });
                // Validasi ulang jika form sudah divalidasi
                if (_autoValidate) {
                  formKey.currentState?.validate();
                }
              },
              isRequired: false, // Set ke true jika bukti wajib
              autovalidateMode: autovalidateMode,
              validator: (file) {
                // (Contoh jika diwajibkan)
                // if (file == null && false /* ganti ini dgn true jika wajib */) {
                //   return 'Bukti wajib diunggah';
                // }
                return null;
              },
            ),

            // <-- AKHIR PERUBAHAN -->
            SizedBox(height: 20),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  "Kirim",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
