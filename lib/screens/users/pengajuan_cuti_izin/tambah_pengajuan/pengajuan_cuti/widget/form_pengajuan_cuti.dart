// lib/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/widget/form_pengajuan_cuti.dart

import 'dart:io'; // <-- Impor 'dart:io'
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_cuti/kategori_pengajuan_cuti.dart'
    as kategori_dto;
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as pengajuan_dto;
import 'package:e_hrm/providers/approvers/approvers_absensi_provider.dart';
import 'package:e_hrm/providers/pengajuan_cuti/kategori_cuti_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/kategori_cuti_selection_field.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FormPengajuanCuti extends StatefulWidget {
  const FormPengajuanCuti({super.key, this.initialData});

  final pengajuan_dto.Data? initialData;

  @override
  State<FormPengajuanCuti> createState() => _FormPengajuanCutiState();
}

class _FormPengajuanCutiState extends State<FormPengajuanCuti> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Hapus controller 'jenisCutiController'
  // final TextEditingController jenisCutiController = TextEditingController();

  final TextEditingController keperluanController = TextEditingController();
  final TextEditingController handoverController = TextEditingController();
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalMasukController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalMasuk;
  File? _buktiFile;

  // TAMBAHKAN STATE UNTUK KATEGORI TERPILIH
  kategori_dto.Data? _selectedKategoriCuti;

  bool _autoValidate = false;
  final DateFormat _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _applyInitialData(widget.initialData, notify: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<KategoriCutiProvider>().fetch(append: false);
    });
  }

  @override
  void didUpdateWidget(covariant FormPengajuanCuti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      _applyInitialData(widget.initialData);
    }
  }

  @override
  void dispose() {
    // Hapus controller 'jenisCutiController'
    // jenisCutiController.dispose();

    keperluanController.dispose();
    handoverController.dispose();
    tanggalMulaiController.dispose();
    tanggalMasukController.dispose();
    super.dispose();
  }

  void _submitForm() {
    setState(() {
      _autoValidate = true;
    });

    if (formKey.currentState?.validate() ?? false) {
      // Validasi tambahan (meskipun validator field sudah menangani ini)
      if (_selectedKategoriCuti == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harap pilih jenis cuti terlebih dahulu.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }

      // TODO: Logika submit data pengajuan cuti
      print("Form valid. Mengirim data...");
      print("Kategori Cuti ID: ${_selectedKategoriCuti!.idKategoriCuti}");
      print("Nama Kategori: ${_selectedKategoriCuti!.namaKategori}");
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

  void _applyInitialData(pengajuan_dto.Data? data, {bool notify = true}) {
    if (data == null) {
      keperluanController.clear();
      handoverController.clear();
      tanggalMulaiController.clear();
      tanggalMasukController.clear();
      if (notify) {
        setState(() {
          _selectedKategoriCuti = null;
          _tanggalMulai = null;
          _tanggalMasuk = null;
        });
      } else {
        _selectedKategoriCuti = null;
        _tanggalMulai = null;
        _tanggalMasuk = null;
      }
      return;
    }

    keperluanController.text = data.keperluan;
    handoverController.text = data.handover;
    tanggalMulaiController.text = _dateFormatter.format(data.tanggalCuti);
    tanggalMasukController.text = _dateFormatter.format(data.tanggalMasukKerja);

    final kategori_dto.Data? kategoriData = _resolveInitialKategori(data);

    if (notify) {
      setState(() {
        _selectedKategoriCuti = kategoriData;
        _tanggalMulai = data.tanggalCuti;
        _tanggalMasuk = data.tanggalMasukKerja;
      });
    } else {
      _selectedKategoriCuti = kategoriData;
      _tanggalMulai = data.tanggalCuti;
      _tanggalMasuk = data.tanggalMasukKerja;
    }
  }

  kategori_dto.Data? _resolveInitialKategori(pengajuan_dto.Data data) {
    final kategori = data.kategoriCuti;

    try {
      final provider = context.read<KategoriCutiProvider>();
      return provider.items.firstWhere(
        (item) => item.idKategoriCuti == kategori.idKategoriCuti,
        orElse: () => _createFallbackKategori(kategori),
      );
    } catch (_) {
      return _createFallbackKategori(kategori);
    }
  }

  kategori_dto.Data _createFallbackKategori(
    pengajuan_dto.KategoriCuti kategori,
  ) {
    return kategori_dto.Data(
      idKategoriCuti: kategori.idKategoriCuti,
      namaKategori: kategori.namaKategori,
      penguranganKouta: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      deletedAt: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final autovalidateMode = _autoValidate
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    // Perlu watch provider KategoriCuti untuk status loading (jika ingin)
    final kategoriCutiProvider = context.watch<KategoriCutiProvider>();

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // --- GANTI TextFieldWidget DENGAN KategoriCutiSelectionField ---
            KategoriCutiSelectionField(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Jenis Cuti',
              selectedKategori: _selectedKategoriCuti,
              onKategoriSelected: (selected) {
                setState(() => _selectedKategoriCuti = selected);
                // Trigger re-validation jika form was already submitted
                if (_autoValidate) {
                  formKey.currentState?.validate();
                }
              },
              isRequired: true,
              autovalidateMode: autovalidateMode,
              validator: (value) {
                if (value == null) {
                  return 'Jenis cuti wajib dipilih';
                }
                return null;
              },
            ),
            // Tampilkan loading indicator jika provider sedang memuat
            if (kategoriCutiProvider.loading &&
                kategoriCutiProvider.items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(),
              ),

            // --- AKHIR PERGANTIAN ---
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
            const SizedBox(height: 20),
            TextFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Keperluan',
              controller: keperluanController,
              hintText: 'Tulis Keperluan Cuti...',
              isRequired: true,
              prefixIcon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              autovalidateMode: autovalidateMode,
            ),
            SizedBox(height: 20),
            DatePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Tanggal Mulai Cuti',
              controller: tanggalMulaiController,
              initialDate: _tanggalMulai,
              onDateChanged: (date) => setState(() => _tanggalMulai = date),
              isRequired: true,
            ),
            SizedBox(height: 20),
            DatePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Tanggal Masuk Cuti',
              controller: tanggalMasukController,
              initialDate: _tanggalMasuk,
              onDateChanged: (date) => setState(() => _tanggalMasuk = date),
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
            FilePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Unggah Bukti',
              buttonText: 'Unggah Bukti',
              prefixIcon: Icons.camera_alt_outlined,
              file: _buktiFile,
              onFileChanged: (newFile) {
                setState(() {
                  _buktiFile = newFile;
                });
                if (_autoValidate) {
                  formKey.currentState?.validate();
                }
              },
              isRequired: false,
              autovalidateMode: autovalidateMode,
              validator: (file) {
                return null;
              },
            ),
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
