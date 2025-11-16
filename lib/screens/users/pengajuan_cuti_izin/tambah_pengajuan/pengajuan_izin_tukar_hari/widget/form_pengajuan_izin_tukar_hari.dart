import 'dart:io';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/providers/pengajuan_izin_tukar_hari/pengajuan_izin_tukar_hari_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:e_hrm/providers/tag_hand_over/tag_hand_over_provider.dart';
import 'package:e_hrm/dto/tag_hand_over/tag_hand_over.dart' as dto;
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
import 'package:e_hrm/utils/mention_parser.dart';

class _TanggalTukarPair {
  DateTime? tanggalIzin;
  DateTime? tanggalPengganti;
  final TextEditingController izinController = TextEditingController();
  final TextEditingController penggantiController = TextEditingController();

  void dispose() {
    izinController.dispose();
    penggantiController.dispose();
  }
}

class FormPengajuanIzinTukarHari extends StatefulWidget {
  const FormPengajuanIzinTukarHari({super.key});

  @override
  State<FormPengajuanIzinTukarHari> createState() =>
      _FormPengajuanIzinTukarHariState();
}

class _FormPengajuanIzinTukarHariState
    extends State<FormPengajuanIzinTukarHari> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController keperluanController = TextEditingController();

  final GlobalKey<FlutterMentionsState> _mentionsKey =
      GlobalKey<FlutterMentionsState>();
  String _handoverPlainText = '';
  String _handoverMarkupText = '';
  int _handoverFieldVersion = 0;
  String? _currentUserId;

  final List<_TanggalTukarPair> _daftarTanggal = [];

  bool _autoValidate = false;
  File? _buktiFile;

  String? _selectedKategori;
  final List<String> _kategoriItems = ['Personal Impact', 'Company Impact'];

  @override
  void initState() {
    super.initState();
    _addPair();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resolveCurrentUserId();
    });
  }

  Future<void> _resolveCurrentUserId() async {
    final auth = context.read<AuthProvider>();
    final current = auth.currentUser?.user.idUser;
    if (current != null && current.isNotEmpty) {
      setState(() {
        _currentUserId = current;
      });
      return;
    }

    final fallback = await loadUserIdFromPrefs();
    if (!mounted) return;
    setState(() {
      _currentUserId = fallback;
    });
  }

  String? _sanitizeUserId(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int _getWordCount(String text) {
    final String v = text.trim();
    if (v.isEmpty) return 0;
    return v.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  @override
  void dispose() {
    keperluanController.dispose();

    for (var pair in _daftarTanggal) {
      pair.dispose();
    }
    super.dispose();
  }

  void _addPair() {
    setState(() {
      _daftarTanggal.add(_TanggalTukarPair());
    });
  }

  void _removePair(int index) {
    if (_daftarTanggal.length <= 1) {
      _showSnackBar('Minimal harus ada satu pasangan tanggal.', isError: true);
      return;
    }
    setState(() {
      _daftarTanggal[index].dispose();
      _daftarTanggal.removeAt(index);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorColor : AppColors.succesColor,
      ),
    );
  }

  Future<void> _submitForm() async {
    setState(() {
      _autoValidate = true;
    });

    if (!(formKey.currentState?.validate() ?? false)) {
      _showSnackBar('Harap periksa kembali semua isian form.', isError: true);
      return;
    }

    final List<DateTime> hariIzinList = <DateTime>[];
    final List<DateTime> hariPenggantiList = <DateTime>[];

    for (final pair in _daftarTanggal) {
      final DateTime? tanggalIzin = pair.tanggalIzin;
      final DateTime? tanggalPengganti = pair.tanggalPengganti;

      if (tanggalIzin == null || tanggalPengganti == null) {
        _showSnackBar(
          'Harap lengkapi semua pasangan tanggal izin dan pengganti.',
          isError: true,
        );
        return;
      }

      if (tanggalIzin.isAtSameMomentAs(tanggalPengganti)) {
        _showSnackBar(
          'Tanggal pengganti tidak boleh sama dengan tanggal izin.',
          isError: true,
        );
        return;
      }

      hariIzinList.add(tanggalIzin);
      hariPenggantiList.add(tanggalPengganti);
    }

    if (_selectedKategori == null) {
      _showSnackBar('Kategori wajib dipilih.', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    http.MultipartFile? lampiran;
    if (_buktiFile != null) {
      try {
        lampiran = await http.MultipartFile.fromPath(
          'lampiran_izin_tukar_hari',
          _buktiFile!.path,
        );
      } catch (e) {
        _showSnackBar('Gagal membaca lampiran: $e', isError: true);
        return;
      }
    }

    final String rawKeperluan = keperluanController.text.trim();
    final String kategori = _selectedKategori!;
    final String handoverMarkup =
        (_mentionsKey.currentState?.controller?.markupText ??
                _handoverMarkupText)
            .trim();

    final List<String> handoverUserIds = MentionParser.extractMentionedUserIds(
      handoverMarkup,
    );

    final approvers = context.read<ApproversPengajuanProvider>();
    final pengajuanProvider = context.read<PengajuanIzinTukarHariProvider>();

    final result = await pengajuanProvider.createPengajuan(
      kategori: kategori,
      keperluan: rawKeperluan,
      handover: handoverMarkup,
      handoverTagUserIds: handoverUserIds,
      approversProvider: approvers,
      hariIzinList: hariIzinList,
      hariPenggantiList: hariPenggantiList,
      lampiran: lampiran,
    );

    if (!mounted) return;

    final String? errorMessage = pengajuanProvider.saveError;
    final String? successMessage = pengajuanProvider.saveMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      _showSnackBar(errorMessage, isError: true);
      return;
    }

    if (successMessage != null && successMessage.isNotEmpty) {
      _showSnackBar(successMessage);
    }

    if (result != null) {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop(result);
      } else {
        _resetFormState(resetApprovers: true);
      }
    }
  }

  void _resetFormState({bool resetApprovers = false}) {
    formKey.currentState?.reset();

    for (final pair in _daftarTanggal) {
      pair.dispose();
    }

    setState(() {
      _daftarTanggal
        ..clear()
        ..add(_TanggalTukarPair());
      keperluanController.clear();
      _handoverPlainText = '';
      _handoverMarkupText = '';
      _handoverFieldVersion++;
      _autoValidate = false;
      _buktiFile = null;
      _selectedKategori = null;
    });

    if (resetApprovers) {
      context.read<ApproversPengajuanProvider>().clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final autovalidateMode = _autoValidate
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    final tagProvider = context.watch<TagHandOverProvider>();
    final authProvider = context.watch<AuthProvider>();

    final String? providerUserId = _sanitizeUserId(
      authProvider.currentUser?.user.idUser,
    );
    final String? effectiveCurrentUserId =
        providerUserId ?? _sanitizeUserId(_currentUserId);

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            DropdownFieldWidget<String>(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Kategori',
              hintText: 'Pilih Kategori Izin...',
              value: _selectedKategori,
              items: _kategoriItems.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedKategori = newValue;
                });
              },
              isRequired: true,
              autovalidateMode: autovalidateMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kategori wajib dipilih';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
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
                    final String text =
                        (_mentionsKey.currentState?.controller?.text ??
                                _handoverPlainText)
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
                              data: tagProvider.items
                                  .where(
                                    (dto.Data user) =>
                                        effectiveCurrentUserId == null ||
                                        user.idUser != effectiveCurrentUserId,
                                  )
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
            SizedBox(height: 20),
            Column(
              children: [
                ..._daftarTanggal.asMap().entries.map((entry) {
                  int index = entry.key;
                  _TanggalTukarPair pair = entry.value;
                  return _buildPairRow(index, pair);
                }),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text("Tambah Tanggal"),
                onPressed: _addPair,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondaryColor,
                ),
              ),
            ),
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
            FilePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Unggah Bukti (Opsional)',
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
            Consumer<PengajuanIzinTukarHariProvider>(
              builder: (context, provider, _) {
                final bool saving = provider.saving;
                return SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: saving ? null : () => _submitForm(),
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
                            "Kirim",
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

  Widget _buildPairRow(int index, _TanggalTukarPair pair) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.errorColor,
              disabledColor: Colors.grey,
              tooltip: 'Hapus pasangan tanggal',
              onPressed: _daftarTanggal.length > 1
                  ? () => _removePair(index)
                  : null,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                DatePickerFieldWidget(
                  width: null,
                  backgroundColor: AppColors.textColor,
                  borderColor: AppColors.textDefaultColor,
                  label: 'Tanggal Izin',
                  controller: pair.izinController,
                  initialDate: pair.tanggalIzin,
                  onDateChanged: (date) =>
                      setState(() => pair.tanggalIzin = date),
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                DatePickerFieldWidget(
                  width: null,
                  backgroundColor: AppColors.textColor,
                  borderColor: AppColors.textDefaultColor,
                  label: 'Tanggal Pengganti',
                  controller: pair.penggantiController,
                  initialDate: pair.tanggalPengganti,
                  onDateChanged: (date) =>
                      setState(() => pair.tanggalPengganti = date),
                  isRequired: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
