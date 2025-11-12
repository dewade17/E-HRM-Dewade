import 'dart:io';

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:e_hrm/shared_widget/time_picker_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FormPengajuanIzinJam extends StatefulWidget {
  const FormPengajuanIzinJam({super.key});

  @override
  State<FormPengajuanIzinJam> createState() => _FormPengajuanIzinJamState();
}

class _FormPengajuanIzinJamState extends State<FormPengajuanIzinJam> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController jenisCutiController = TextEditingController();

  final TextEditingController handoverController = TextEditingController();
  final TextEditingController tanggalPengajuanIjinJamController =
      TextEditingController();
  // Controller untuk tanggal pengganti
  final TextEditingController tanggalPenggantiJamController =
      TextEditingController();
  // Controller untuk time picker (pengajuan)
  final TextEditingController startTimePengajuanController =
      TextEditingController();
  final TextEditingController endTimePengajuanController =
      TextEditingController();
  // Controller untuk time picker (pengganti)
  final TextEditingController startTimePenggantiController =
      TextEditingController();
  final TextEditingController endTimePenggantiController =
      TextEditingController();

  DateTime? _tanggalPengajuanIjinJam;
  DateTime? _tanggalPenggantiJam;
  // State untuk time picker
  TimeOfDay? _startTimePengajuan;
  TimeOfDay? _endTimePengajuan;
  TimeOfDay? _startTimePengganti;
  TimeOfDay? _endTimePengganti;
  // DIUBAH: Gunakan File? dari dart:io
  File? _buktiFile;

  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    jenisCutiController.text = "Pengajuan Izin Jam";
  }

  @override
  void dispose() {
    jenisCutiController.dispose();
    handoverController.dispose();
    tanggalPengajuanIjinJamController.dispose();
    tanggalPenggantiJamController.dispose();
    startTimePengajuanController.dispose();
    endTimePengajuanController.dispose();
    startTimePenggantiController.dispose();
    endTimePenggantiController.dispose();
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
              hintText: 'Pengajuan Izin Jam',
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
                    .watch<ApproversPengajuanProvider>()
                    .selectedRecipientIds,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penerima laporan (Supervisi) wajib dipilih.';
                  }
                  return null;
                },
                builder: (FormFieldState<Set<String>> state) {
                  final provider = context.watch<ApproversPengajuanProvider>();
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
              controller: tanggalPengajuanIjinJamController,
              initialDate: _tanggalPengajuanIjinJam,
              onDateChanged: (date) =>
                  setState(() => _tanggalPengajuanIjinJam = date),
              isRequired: true,
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TimePickerFieldWidget(
                    backgroundColor: AppColors.textColor,
                    borderColor: AppColors.textDefaultColor,
                    label: "Jam Mulai",
                    controller: startTimePengajuanController,
                    onChanged: (time) =>
                        setState(() => _startTimePengajuan = time),
                    isRequired: true,
                    // Tambahkan validator untuk time picker jika perlu
                    validator: (value) {
                      if (_startTimePengajuan == null) return 'Wajib diisi';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TimePickerFieldWidget(
                    backgroundColor: AppColors.textColor,
                    borderColor: AppColors.textDefaultColor,
                    label: "Jam Selesai",
                    controller: endTimePengajuanController,
                    onChanged: (time) =>
                        setState(() => _endTimePengajuan = time),
                    isRequired: true,
                    // Tambahkan validator untuk time picker jika perlu
                    validator: (value) {
                      if (_endTimePengajuan == null) return 'Wajib diisi';
                      // Validasi tambahan: jam selesai > jam mulai
                      if (_startTimePengajuan != null &&
                          _endTimePengajuan != null) {
                        final startMinutes =
                            _startTimePengajuan!.hour * 60 +
                            _startTimePengajuan!.minute;
                        final endMinutes =
                            _endTimePengajuan!.hour * 60 +
                            _endTimePengajuan!.minute;
                        if (endMinutes <= startMinutes) {
                          return 'Jam selesai harus setelah jam mulai';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            DatePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Tanggal pengganti',
              controller: tanggalPenggantiJamController,
              initialDate: _tanggalPenggantiJam,
              onDateChanged: (date) =>
                  setState(() => _tanggalPenggantiJam = date),
              isRequired: true,
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TimePickerFieldWidget(
                    backgroundColor: AppColors.textColor,
                    borderColor: AppColors.textDefaultColor,
                    label: "Jam Mulai Pengganti",
                    controller: startTimePenggantiController,
                    onChanged: (time) =>
                        setState(() => _startTimePengganti = time),
                    isRequired: true,
                    // Tambahkan validator untuk time picker jika perlu
                    validator: (value) {
                      if (_startTimePengganti == null) return 'Wajib diisi';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TimePickerFieldWidget(
                    backgroundColor: AppColors.textColor,
                    borderColor: AppColors.textDefaultColor,
                    label: "Jam Selesai Pengganti",
                    controller: endTimePenggantiController,
                    onChanged: (time) =>
                        setState(() => _endTimePengganti = time),
                    isRequired: true,
                    // Tambahkan validator untuk time picker jika perlu
                    validator: (value) {
                      if (_endTimePengganti == null) return 'Wajib diisi';
                      // Validasi tambahan: jam selesai > jam mulai
                      if (_startTimePengganti != null &&
                          _endTimePengganti != null) {
                        final startMinutes =
                            _startTimePengganti!.hour * 60 +
                            _startTimePengganti!.minute;
                        final endMinutes =
                            _endTimePengganti!.hour * 60 +
                            _endTimePengganti!.minute;
                        if (endMinutes <= startMinutes) {
                          return 'Jam selesai Pengganti harus setelah jam mulai';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
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
