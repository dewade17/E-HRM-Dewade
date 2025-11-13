import 'dart:io';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_cuti/kategori_pengajuan_cuti.dart'
    as kategori_dto;
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as pengajuan_dto;
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
// Impor provider Konfigurasi Cuti
import 'package:e_hrm/providers/konfigurasi_cuti/provider_konfigurasi_cuti.dart';
import 'package:e_hrm/providers/pengajuan_cuti/kategori_cuti_provider.dart';
import 'package:e_hrm/providers/pengajuan_cuti/pengajuan_cuti_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
// Impor DatePickerFieldWidget
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

// Impor untuk mentions
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
  // TAMBAHKAN: Controller untuk tanggal masuk kerja
  final TextEditingController tanggalMasukKerjaController =
      TextEditingController();

  final GlobalKey<FlutterMentionsState> _mentionsKey =
      GlobalKey<FlutterMentionsState>();
  String _handoverPlainText = '';
  String _handoverMarkupText = '';
  int _handoverFieldVersion = 0;

  List<DateTime> _selectedDates = [];
  // TAMBAHKAN: State untuk tanggal masuk kerja
  DateTime? _selectedTanggalMasukKerja;

  File? _buktiFile;
  kategori_dto.Data? _selectedKategoriCuti;
  bool _autoValidate = false;
  final DateFormat _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _applyInitialData(widget.initialData, notify: false);
    }
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
    // TAMBAHKAN: Dispose controller
    tanggalMasukKerjaController.dispose();
    super.dispose();
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

    // TAMBAHKAN: Validasi tanggal masuk kerja
    if (_selectedTanggalMasukKerja == null) {
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
    final idKategori = _selectedKategoriCuti!.idKategoriCuti;
    final keperluan = keperluanController.text.trim();
    final handover = _getCurrentHandoverMarkup().trim();
    // TAMBAHKAN: Ambil nilai tanggal masuk kerja
    final tanggalMasuk = _selectedTanggalMasukKerja!;

    _selectedDates.sort();

    // TAMBAHKAN: Siapkan additionalFields
    final additionalFields = {
      'tanggal_masuk_kerja': tanggalMasuk.toIso8601String(),
    };

    pengajuan_dto.Data? result;
    if (_isEditing) {
      final id = widget.initialData!.idPengajuanCuti;
      result = await pengajuanProvider.updatePengajuan(
        id,
        idKategoriCuti: idKategori,
        keperluan: keperluan,
        tanggalList: _selectedDates,
        handover: handover,
        approversProvider: approvers,
        lampiran: lampiran,
        additionalFields: additionalFields, // <-- Kirim data tambahan
      );
    } else {
      result = await pengajuanProvider.createPengajuan(
        idKategoriCuti: idKategori,
        keperluan: keperluan,
        tanggalList: _selectedDates,
        handover: handover,
        approversProvider: approvers,
        lampiran: lampiran,
        additionalFields: additionalFields, // <-- Kirim data tambahan
      );
    }

    if (!mounted) return;

    final errorMessage = pengajuanProvider.saveError;
    final successMessage = pengajuanProvider.saveMessage;

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
        });
      }
    }
  }

  // --- MODIFIKASI: _pickDate sekarang menggunakan KonfigurasiCutiProvider ---
  Future<void> _pickDate(FormFieldState<List<DateTime>> state) async {
    // 1. Baca provider konfigurasi cuti
    final konfigurasiCutiProvider = context.read<KonfigurasiCutiProvider>();
    // 2. Dapatkan kuota (default 0 jika tidak ada data)
    final int koutaCuti = konfigurasiCutiProvider.items.isNotEmpty
        ? konfigurasiCutiProvider.items.last.koutaCuti
        : 0;
    // 3. Cek apakah kuota sudah habis
    final bool isQuotaMet = _selectedDates.length >= koutaCuti;

    // 4. Tampilkan peringatan jika kuota habis (seharusnya tombol sudah disable,
    //    tapi ini sebagai pengaman ganda)
    if (isQuotaMet) {
      _showSnackBar(
        'Anda sudah mencapai batas kuota cuti ($koutaCuti hari).',
        isError: true,
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDates.lastOrNull ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
      // 5. Tambahkan predikat untuk menonaktifkan tanggal
      selectableDayPredicate: (DateTime day) {
        // Normalisasi HARI INI (tanpa jam)
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );

        // Alasan nonaktif (return false):
        // 1. Kuota sudah habis
        if (isQuotaMet) return false;
        // 2. Tanggal sudah dipilih sebelumnya
        if (_selectedDates.contains(day)) return false;
        // 3. Tanggal adalah Sabtu (6) atau Minggu (7)
        if (day.weekday == 6 || day.weekday == 7) return false;
        // 4. Tanggal adalah hari sebelum hari ini
        if (day.isBefore(today)) return false;

        // Jika lolos semua, tanggal bisa dipilih
        return true;
      },
    );

    if (picked != null) {
      // Logika ini tetap sama
      setState(() {
        if (!_selectedDates.contains(picked)) {
          _selectedDates.add(picked);
          _selectedDates.sort();
          state.didChange(_selectedDates);
        } else {
          // Seharusnya tidak terjadi karena selectableDayPredicate
          _showSnackBar('Tanggal sudah dipilih.', isError: true);
        }
      });
    }
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
      // TAMBAHKAN: Tanggal Masuk Kerja
      required DateTime? tanggalMasuk,
    }) {
      _selectedKategoriCuti = kategori;
      _selectedDates = dates;
      _handoverPlainText = handoverPlain;
      _handoverMarkupText = handoverMarkup;
      _handoverFieldVersion++;
      // TAMBAHKAN: Set state tanggal masuk kerja
      _selectedTanggalMasukKerja = tanggalMasuk;
    }

    if (data == null) {
      keperluanController.clear();
      // TAMBAHKAN: Hapus controller tanggal masuk
      tanggalMasukKerjaController.clear();
      approversProvider.clearSelection();
      _scheduleApproverUpdate(() => approversProvider.clearSelection());

      final newSelectedDates = <DateTime>[];
      apply() {
        updateState(
          kategori: null,
          dates: newSelectedDates,
          handoverPlain: '',
          handoverMarkup: '',
          tanggalMasuk: null, // <-- Set null
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

    keperluanController.text = data.keperluan;

    final newSelectedDates = data.tanggalList.map((dt) => dt.toLocal()).toList()
      ..sort();

    // TAMBAHKAN: Ambil tanggal masuk kerja
    final DateTime? tanggalMasuk = data.tanggalMasukKerja.toLocal();
    if (tanggalMasuk != null) {
      tanggalMasukKerjaController.text = _dateFormatter.format(tanggalMasuk);
    }

    final kategori_dto.Data? kategoriData = _resolveInitialKategori(data);

    final supervisorIds = data.approvals
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

    final plainHandover = _convertMarkupToDisplay(data.handover);
    apply() {
      updateState(
        kategori: kategoriData,
        dates: newSelectedDates,
        handoverPlain: plainHandover,
        handoverMarkup: data.handover,
        tanggalMasuk: tanggalMasuk, // <-- Set data
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
    final v = text.trim();
    if (v.isEmpty) return 0;
    return v.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  static final RegExp _mentionMarkupRegex = RegExp(
    r'([@#])\[__(.*?)__\]\(__(.*?)__\)',
  );

  String _convertMarkupToDisplay(String markup) {
    if (markup.isEmpty) return '';
    return markup.replaceAllMapped(_mentionMarkupRegex, (match) {
      final trigger = match.group(1) ?? '';
      final display = match.group(3) ?? '';
      return '$trigger$display';
    });
  }

  void _scheduleHandoverControllerSync(String text) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _mentionsKey.currentState?.controller;
      if (controller == null || controller.text == text) {
        return;
      }
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
    final autovalidateMode = _autoValidate
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    final kategoriCutiProvider = context.watch<KategoriCutiProvider>();
    // Ambil provider tag
    final tagProvider = context.watch<TagHandOverProvider>();

    // --- TAMBAHKAN: Ambil Konfigurasi Cuti Provider untuk cek kuota ---
    final konfigurasiCutiProvider = context.watch<KonfigurasiCutiProvider>();
    final int koutaCuti = konfigurasiCutiProvider.items.isNotEmpty
        ? konfigurasiCutiProvider.items.last.koutaCuti
        : 0;
    final bool isQuotaMet = _selectedDates.length >= koutaCuti;
    // --- AKHIR TAMBAHAN ---

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
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
                    final text = (value ?? _getCurrentHandoverText()).trim();
                    if (text.isEmpty) {
                      return 'Handover Pekerjaan tidak boleh kosong';
                    }
                    final wordCount = _getWordCount(text);
                    if (wordCount < 15) {
                      return 'Minimal 15 kata. (Sekarang: $wordCount kata)';
                    }
                    return null;
                  },
                  builder: (state) {
                    final hasError = state.hasError;
                    final borderColor = hasError
                        ? AppColors.errorColor
                        : AppColors.textDefaultColor;
                    final focusedBorderColor = hasError
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
                                'Handover Pekerjaan (min. 15 kata). Ketik @ untuk mention...',
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
                              data: tagProvider.items.map((dto.Data user) {
                                return {
                                  'id': user.idUser,
                                  'display': user.namaPengguna,
                                  'photo': user.fotoProfilUser,
                                  'email': user.email,
                                };
                              }).toList(),
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
                            text:
                                'Tanggal Cuti (Sisa: ${koutaCuti - _selectedDates.length})', // <-- Tampilkan sisa
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
                            // --- MODIFIKASI: Tombol nonaktif jika kuota habis ---
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: isQuotaMet
                                  ? Colors
                                        .grey // <-- Warna nonaktif
                                  : AppColors.secondaryColor,
                            ),
                            onPressed: isQuotaMet
                                ? null // <-- Nonaktifkan tombol
                                : () => _pickDate(state),
                            tooltip: isQuotaMet
                                ? 'Kuota cuti sudah habis ($koutaCuti Hari)'
                                : 'Tambah Tanggal Cuti',
                          ),
                        ],
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

            // --- TAMBAHKAN: Field Tanggal Masuk Kerja ---
            DatePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Tanggal Masuk Kerja',
              controller: tanggalMasukKerjaController,
              initialDate: _selectedTanggalMasukKerja,
              onDateChanged: (date) {
                setState(() => _selectedTanggalMasukKerja = date);
                if (_autoValidate) {
                  formKey.currentState?.validate();
                }
              },
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tanggal masuk kerja wajib diisi';
                }
                if (_selectedTanggalMasukKerja != null &&
                    _selectedDates.isNotEmpty) {
                  final lastCutiDate = _selectedDates.last;
                  if (!_selectedTanggalMasukKerja!.isAfter(lastCutiDate)) {
                    return 'Harus setelah tanggal cuti terakhir';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // --- AKHIR TAMBAHAN ---
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
