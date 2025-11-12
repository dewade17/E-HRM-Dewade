// lib/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/widget/form_pengajuan_cuti.dart

import 'dart:io'; // <-- Impor 'dart:io'
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_cuti/kategori_pengajuan_cuti.dart'
    as kategori_dto;
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as pengajuan_dto;
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/providers/pengajuan_cuti/kategori_cuti_provider.dart';
import 'package:e_hrm/providers/pengajuan_cuti/pengajuan_cuti_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/kategori_cuti_selection_field.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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

  kategori_dto.Data? _selectedKategoriCuti;

  bool _autoValidate = false;
  final DateFormat _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  bool get _isEditing => widget.initialData != null;

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _applyInitialData(widget.initialData);
        }
      });
    }
  }

  @override
  void dispose() {
    keperluanController.dispose();
    handoverController.dispose();
    tanggalMulaiController.dispose();
    tanggalMasukController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      _autoValidate = true;
    });

    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Harap periksa kembali semua isian form.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      return;
    }

    if (_selectedKategoriCuti == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Harap pilih jenis cuti terlebih dahulu.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      return;
    }

    if (_tanggalMulai == null || _tanggalMasuk == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Tanggal cuti dan tanggal masuk kerja wajib diisi.',
            ),
            backgroundColor: AppColors.errorColor,
          ),
        );
      return;
    }

    if (_tanggalMasuk!.isBefore(_tanggalMulai!)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Tanggal masuk kerja tidak boleh sebelum tanggal cuti.',
            ),
            backgroundColor: AppColors.errorColor,
          ),
        );
      return;
    }

    final approvers = context.read<ApproversPengajuanProvider>();
    if (approvers.selectedRecipientIds.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Pilih minimal satu penerima laporan (supervisi).',
            ),
            backgroundColor: AppColors.errorColor,
          ),
        );
      return;
    }

    FocusScope.of(context).unfocus();

    http.MultipartFile? lampiran;
    if (_buktiFile != null) {
      try {
        lampiran = await http.MultipartFile.fromPath(
          'lampiran_cuti',
          _buktiFile!.path,
        );
      } catch (e) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Gagal membaca lampiran: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        return;
      }
    }

    final pengajuanProvider = context.read<PengajuanCutiProvider>();
    final idKategori = _selectedKategoriCuti!.idKategoriCuti;
    final keperluan = keperluanController.text.trim();
    final handover = handoverController.text.trim();

    pengajuan_dto.Data? result;
    if (_isEditing) {
      final id = widget.initialData!.idPengajuanCuti;
      result = await pengajuanProvider.updatePengajuan(
        id,
        idKategoriCuti: idKategori,
        keperluan: keperluan,
        tanggalCuti: _tanggalMulai!,
        tanggalMasukKerja: _tanggalMasuk!,
        handover: handover,
        approversProvider: approvers,
        lampiran: lampiran,
      );
    } else {
      result = await pengajuanProvider.createPengajuan(
        idKategoriCuti: idKategori,
        keperluan: keperluan,
        tanggalCuti: _tanggalMulai!,
        tanggalMasukKerja: _tanggalMasuk!,
        handover: handover,
        approversProvider: approvers,
        lampiran: lampiran,
      );
    }

    if (!mounted) return;

    final errorMessage = pengajuanProvider.saveError;
    final successMessage = pengajuanProvider.saveMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorColor,
          ),
        );
      return;
    }

    if (successMessage != null && successMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppColors.succesColor,
          ),
        );
    }

    if (result != null) {
      if (_isEditing) {
        Navigator.of(context).pop(result);
      } else {
        formState.reset();
        _applyInitialData(null, notify: false);
        setState(() {
          _buktiFile = null;
          _autoValidate = false;
        });
      }
    }
  }

  void _applyInitialData(pengajuan_dto.Data? data, {bool notify = true}) {
    final approversProvider = context.read<ApproversPengajuanProvider>();

    if (data == null) {
      keperluanController.clear();
      handoverController.clear();
      tanggalMulaiController.clear();
      tanggalMasukController.clear();
      approversProvider.clearSelection();
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

    final supervisorIds = data.approvals
        .map((approval) => approval.approverUserId)
        .whereType<String>()
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    if (supervisorIds.isNotEmpty) {
      approversProvider.replaceSelection(supervisorIds);
    } else {
      approversProvider.clearSelection();
    }

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
            Consumer<PengajuanCutiProvider>(
              builder: (context, provider, _) {
                final saving = provider.saving;
                return SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: saving ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textColor,
                              ),
                            ),
                          )
                        : Text(
                            _isEditing ? 'Simpan Perubahan' : 'Kirim Pengajuan',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
