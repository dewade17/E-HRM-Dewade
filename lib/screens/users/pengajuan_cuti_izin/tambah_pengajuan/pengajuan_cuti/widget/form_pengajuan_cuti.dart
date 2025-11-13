import 'dart:io';

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_cuti/kategori_pengajuan_cuti.dart'
    as kategori_dto;
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as pengajuan_dto;
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/providers/konfigurasi_cuti/provider_konfigurasi_cuti.dart';
import 'package:e_hrm/providers/pengajuan_cuti/kategori_cuti_provider.dart';
import 'package:e_hrm/providers/pengajuan_cuti/pengajuan_cuti_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/kategori_cuti_selection_field.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Mentions
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:e_hrm/providers/tag_hand_over/tag_hand_over_provider.dart';
import 'package:e_hrm/dto/tag_hand_over/tag_hand_over.dart' as dto;

class FormPengajuanCuti extends StatefulWidget {
  const FormPengajuanCuti({super.key, this.initialData});

  final pengajuan_dto.Data? initialData;

  @override
  State<FormPengajuanCuti> createState() => _FormPengajuanCutiState();
}

class _FormPengajuanCutiState extends State<FormPengajuanCuti> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController keperluanController = TextEditingController();
  final GlobalKey<FlutterMentionsState> _mentionsKey =
      GlobalKey<FlutterMentionsState>();
  final TextEditingController tanggalMasukKerjaController =
      TextEditingController();

  String _handoverPlainText = '';
  String _handoverMarkupText = '';
  int _handoverFieldVersion = 0;

  List<DateTime> _selectedDates = [];
  DateTime? _tanggalMasukKerja;
  File? _buktiFile;
  kategori_dto.Data? _selectedKategoriCuti;
  bool _autoValidate = false;

  final DateFormat _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  bool get _isEditing => widget.initialData != null;

  // Regex markup mentions
  static final RegExp _mentionMarkupRegex = RegExp(
    r'([@#])\[__(.*?)__\]\(__(.*?)__\)',
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _applyInitialData(widget.initialData, notify: false);
    }
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
    tanggalMasukKerjaController.dispose();
    super.dispose();
  }

  void _scheduleApproverUpdate(VoidCallback action) {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      action();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          action();
        }
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _autoValidate = true;
    });

    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      _showSnackBar('Harap periksa kembali semua isian form.', isError: true);
      return;
    }

    if (_selectedKategoriCuti == null) {
      _showSnackBar('Harap pilih jenis cuti terlebih dahulu.', isError: true);
      return;
    }

    if (_selectedDates.isEmpty) {
      _showSnackBar('Tanggal cuti wajib diisi.', isError: true);
      return;
    }

    if (_tanggalMasukKerja == null) {
      _showSnackBar('Tanggal masuk kerja wajib diisi.', isError: true);
      return;
    }

    final approvers = context.read<ApproversPengajuanProvider>();
    if (approvers.selectedRecipientIds.isEmpty) {
      _showSnackBar(
        'Pilih minimal satu penerima laporan (supervisi).',
        isError: true,
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
        _showSnackBar('Gagal membaca lampiran: $e', isError: true);
        return;
      }
    }

    final pengajuanProvider = context.read<PengajuanCutiProvider>();
    final String idKategori = _selectedKategoriCuti!.idKategoriCuti;
    final String keperluan = keperluanController.text.trim();
    final String handover = _getCurrentHandoverMarkup().trim();

    _selectedDates.sort();

    pengajuan_dto.Data? result;
    if (_isEditing) {
      final String id = widget.initialData!.idPengajuanCuti;
      result = await pengajuanProvider.updatePengajuan(
        id,
        idKategoriCuti: idKategori,
        keperluan: keperluan,
        tanggalList: _selectedDates,
        tanggalMasukKerja: _tanggalMasukKerja!,
        handover: handover,
        approversProvider: approvers,
        lampiran: lampiran,
      );
    } else {
      result = await pengajuanProvider.createPengajuan(
        idKategoriCuti: idKategori,
        keperluan: keperluan,
        tanggalList: _selectedDates,
        tanggalMasukKerja: _tanggalMasukKerja!,
        handover: handover,
        approversProvider: approvers,
        lampiran: lampiran,
      );
    }
    if (!mounted) return;

    final String? errorMessage = pengajuanProvider.saveError;
    final String? successMessage = pengajuanProvider.saveMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      _showSnackBar(errorMessage, isError: true);
      return;
    }

    if (successMessage != null && successMessage.isNotEmpty) {
      _showSnackBar(successMessage, isError: false);
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
          _tanggalMasukKerja = null;
        });
      }
    }
  }

  Future<void> _pickDate(FormFieldState<List<DateTime>> state) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDates.lastOrNull ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        if (!_selectedDates.contains(picked)) {
          _selectedDates.add(picked);
          _selectedDates.sort();
          state.didChange(_selectedDates);
        } else {
          _showSnackBar('Tanggal sudah dipilih.', isError: true);
        }
      });
    }
  }

  Future<void> _handlePickDate(
    FormFieldState<List<DateTime>> state,
    int? remainingQuota,
  ) async {
    if (remainingQuota != null && remainingQuota <= 0) {
      _showSnackBar('Kuota cuti Anda sudah habis.', isError: true);
      return;
    }

    await _pickDate(state);
  }

  int? _calculateAvailableQuota(KonfigurasiCutiProvider provider) {
    if (provider.items.isEmpty) return null;

    final latestData = provider.items.last;
    final String rawStatus = provider.statusCuti?.trim().toLowerCase() ?? '';
    final bool statusActive = rawStatus == 'aktif';

    int available = latestData.koutaCuti;
    if (statusActive) {
      available += latestData.cutiTabung;
    }

    return available;
  }

  int? _calculateRemainingQuota(int? availableQuota) {
    if (availableQuota == null) return null;
    final int remaining = availableQuota - _selectedDates.length;
    return remaining > 0 ? remaining : 0;
  }

  void _removeDate(DateTime date, FormFieldState<List<DateTime>> state) {
    setState(() {
      _selectedDates.remove(date);
      state.didChange(_selectedDates);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? AppColors.errorColor
              : AppColors.succesColor,
        ),
      );
  }

  void _applyInitialData(pengajuan_dto.Data? data, {bool notify = true}) {
    final approversProvider = context.read<ApproversPengajuanProvider>();

    void updateState({
      required kategori_dto.Data? kategori,
      required List<DateTime> dates,
      required String handoverPlain,
      required String handoverMarkup,
      required DateTime? tanggalMasukKerja,
    }) {
      _selectedKategoriCuti = kategori;
      _selectedDates = dates;
      _handoverPlainText = handoverPlain;
      _handoverMarkupText = handoverMarkup;
      _handoverFieldVersion++;
      _tanggalMasukKerja = tanggalMasukKerja;

      if (tanggalMasukKerja != null) {
        tanggalMasukKerjaController.text = _dateFormatter.format(
          tanggalMasukKerja,
        );
      } else {
        tanggalMasukKerjaController.clear();
      }
    }

    if (data == null) {
      keperluanController.clear();
      tanggalMasukKerjaController.clear();
      approversProvider.clearSelection();
      _scheduleApproverUpdate(() => approversProvider.clearSelection());

      final List<DateTime> newSelectedDates = <DateTime>[];

      void apply() {
        updateState(
          kategori: null,
          dates: newSelectedDates,
          handoverPlain: '',
          handoverMarkup: '',
          tanggalMasukKerja: null,
        );
      }

      if (notify) {
        setState(apply);
      } else {
        apply();
      }

      _scheduleHandoverControllerSync('');
      return;
    }

    // Ada data existing (edit)
    keperluanController.text = data.keperluan;

    final List<DateTime> newSelectedDates =
        data.tanggalList.map((dt) => dt.toLocal()).toList()..sort();

    final kategori_dto.Data? kategoriData = _resolveInitialKategori(data);
    final DateTime tanggalMasukKerja = data.tanggalMasukKerja.toLocal();

    final Set<String> supervisorIds = data.approvals
        .map((approval) => approval.approverUserId)
        .whereType<String>()
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    _scheduleApproverUpdate(() {
      if (supervisorIds.isNotEmpty) {
        approversProvider.replaceSelection(supervisorIds);
      } else {
        approversProvider.clearSelection();
      }
    });

    final String plainHandover = _convertMarkupToDisplay(data.handover);

    void apply() {
      updateState(
        kategori: kategoriData,
        dates: newSelectedDates,
        handoverPlain: plainHandover,
        handoverMarkup: data.handover,
        tanggalMasukKerja: tanggalMasukKerja,
      );
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }

    _scheduleHandoverControllerSync(plainHandover);
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

  // Helper validasi
  int _getWordCount(String text) {
    final String v = text.trim();
    if (v.isEmpty) return 0;
    return v.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  String _convertMarkupToDisplay(String markup) {
    if (markup.isEmpty) return '';
    return markup.replaceAllMapped(_mentionMarkupRegex, (match) {
      final String trigger = match.group(1) ?? '';
      final String display = match.group(3) ?? '';
      return '$trigger$display';
    });
  }

  void _scheduleHandoverControllerSync(String text) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _mentionsKey.currentState?.controller;
      if (controller == null || controller.text == text) return;

      controller
        ..text = text
        ..selection = TextSelection.collapsed(offset: text.length);
    });
  }

  String _getCurrentHandoverText() {
    final controller = _mentionsKey.currentState?.controller;
    if (controller != null) {
      _handoverPlainText = controller.text;
      return controller.text;
    }
    return _handoverPlainText;
  }

  String _getCurrentHandoverMarkup() {
    final controller = _mentionsKey.currentState?.controller;
    if (controller != null) {
      _handoverPlainText = controller.text;
      _handoverMarkupText = controller.markupText;
      return controller.markupText;
    }
    return _handoverMarkupText;
  }

  @override
  Widget build(BuildContext context) {
    final AutovalidateMode autovalidateMode = _autoValidate
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    final kategoriCutiProvider = context.watch<KategoriCutiProvider>();
    final konfigurasiProvider = context.watch<KonfigurasiCutiProvider>();
    final int? availableQuota = _calculateAvailableQuota(konfigurasiProvider);
    final int? remainingQuota = _calculateRemainingQuota(availableQuota);
    final bool canSelectMore = remainingQuota == null || remainingQuota > 0;
    final tagProvider = context.watch<TagHandOverProvider>();

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Jenis Cuti
            KategoriCutiSelectionField(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Jenis Cuti',
              selectedKategori: _selectedKategoriCuti,
              onKategoriSelected: (selected) {
                setState(() => _selectedKategoriCuti = selected);
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
            if (kategoriCutiProvider.loading &&
                kategoriCutiProvider.items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 20),

            // Handover Pekerjaan + Mentions
            // Keperluan
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

            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Handover Pekerjaan',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDefaultColor,
                        ),
                      ),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FormField<String>(
                  key: ValueKey(_handoverFieldVersion),
                  initialValue: _handoverPlainText,
                  autovalidateMode: autovalidateMode,
                  validator: (value) {
                    final String text = (value ?? _getCurrentHandoverText())
                        .trim();

                    if (text.isEmpty) {
                      return 'Handover Pekerjaan tidak boleh kosong';
                    }

                    final int wordCount = _getWordCount(text);
                    if (wordCount < 15) {
                      return 'Minimal 15 kata. (Sekarang: $wordCount kata)';
                    }

                    return null;
                  },
                  builder: (state) {
                    final bool hasError = state.hasError;
                    final Color borderColor = hasError
                        ? AppColors.errorColor
                        : AppColors.textDefaultColor;
                    final Color focusedBorderColor = hasError
                        ? AppColors.errorColor
                        : AppColors.primaryColor;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FlutterMentions(
                          key: _mentionsKey,
                          defaultText: _handoverPlainText,
                          maxLines: 5,
                          minLines: 3,
                          onChanged: (value) {
                            state.didChange(value);
                            _handoverPlainText = value;
                          },
                          onMarkupChanged: (value) {
                            _handoverMarkupText = value;
                          },
                          onSearchChanged: (trigger, query) {
                            context.read<TagHandOverProvider>().search(query);
                          },
                          decoration: InputDecoration(
                            fillColor: AppColors.textColor,
                            filled: true,
                            hintText:
                                'Handover Pekerjaan (min. 50 kata). Ketik @ untuk mention...',
                            prefixIcon: const Icon(Icons.description_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: focusedBorderColor),
                            ),
                          ),
                          mentions: [
                            Mention(
                              trigger: '@',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              data: tagProvider.items
                                  .map(
                                    (dto.Data user) => {
                                      'id': user.idUser,
                                      'display': user.namaPengguna,
                                      'photo': user.fotoProfilUser,
                                      'email': user.email,
                                    },
                                  )
                                  .toList(),
                              suggestionBuilder: (data) {
                                return Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        backgroundImage: data['photo'] != null
                                            ? NetworkImage(data['photo']!)
                                            : null,
                                        child: data['photo'] == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(data['display']!),
                                          Text(
                                            data['email']!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        if (hasError && state.errorText != null)
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
              ],
            ),

            const SizedBox(height: 20),

            // Tanggal Cuti (multi-date)
            FormField<List<DateTime>>(
              key: ValueKey(_selectedDates.length),
              autovalidateMode: autovalidateMode,
              initialValue: _selectedDates,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tanggal cuti wajib diisi.';
                }
                return null;
              },
              builder: (FormFieldState<List<DateTime>> state) {
                final bool hasError = state.hasError;
                final Color borderColor = hasError
                    ? AppColors.errorColor
                    : AppColors.textDefaultColor;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '* ',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.errorColor,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: 'Tanggal Cuti',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _selectedDates.isEmpty
                                ? Text(
                                    'Pilih tanggal...',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                : Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: _selectedDates.map((date) {
                                      return Chip(
                                        label: Text(
                                          _dateFormatter.format(date),
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        onDeleted: () =>
                                            _removeDate(date, state),
                                        deleteIconColor: Colors.red.shade700,
                                        backgroundColor: AppColors.accentColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: canSelectMore
                                  ? AppColors.secondaryColor
                                  : Colors.grey,
                            ),
                            onPressed: canSelectMore
                                ? () => _handlePickDate(state, remainingQuota)
                                : null,
                            tooltip: 'Tambah Tanggal Cuti',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          remainingQuota == null
                              ? 'Sisa kuota cuti: --'
                              : 'Sisa kuota cuti: $remainingQuota hari',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: remainingQuota == null || canSelectMore
                                  ? AppColors.textDefaultColor
                                  : AppColors.errorColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (hasError)
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

            const SizedBox(height: 20),

            DatePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Tanggal Masuk Kerja',
              controller: tanggalMasukKerjaController,
              initialDate: _tanggalMasukKerja,
              onDateChanged: (date) {
                setState(() {
                  _tanggalMasukKerja = date;
                });
              },
              isRequired: true,
            ),

            const SizedBox(height: 20),

            // Recipient Supervisi
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

            // Lampiran / Bukti
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

            const SizedBox(height: 20),

            // Tombol Submit
            Consumer<PengajuanCutiProvider>(
              builder: (context, provider, _) {
                final bool saving = provider.saving;
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
