// lib/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_jam/widget/form_pengajuan_izin_jam.dart

import 'dart:io';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
// Import provider (tetap diperlukan untuk sheet)
import 'package:e_hrm/providers/pengajuan_izin_jam/kategori_izin_jam.dart';
// Import DTO
import 'package:e_hrm/dto/pengajuan_izin_jam/kategori_izin_jam.dart'
    as dto_kategori_izin_jam;
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
// Perubahan: Import widget selection field baru
import 'package:e_hrm/shared_widget/kategori_izin_jam_selection_field.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:e_hrm/shared_widget/time_picker_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- IMPORT BARU UNTUK MENTION ---
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:e_hrm/providers/tag_hand_over/tag_hand_over_provider.dart';
import 'package:e_hrm/dto/tag_hand_over/tag_hand_over.dart' as dto;
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:e_hrm/utils/mention_parser.dart';
import 'dart:async';
// --- AKHIR IMPORT BARU ---

class FormPengajuanIzinJam extends StatefulWidget {
  const FormPengajuanIzinJam({super.key});

  @override
  State<FormPengajuanIzinJam> createState() => _FormPengajuanIzinJamState();
}

class _FormPengajuanIzinJamState extends State<FormPengajuanIzinJam> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController keperluanController = TextEditingController();

  // final TextEditingController handoverController = TextEditingController(); // DIGANTI

  final TextEditingController tanggalIjinJamController =
      TextEditingController();
  final TextEditingController tanggalPenggantiJamController =
      TextEditingController();
  final TextEditingController startTimeIjinController = TextEditingController();
  final TextEditingController endTimeIjinController = TextEditingController();
  final TextEditingController startTimePenggantiController =
      TextEditingController();
  final TextEditingController endTimePenggantiController =
      TextEditingController();

  // --- STATE BARU UNTUK MENTION ---
  final GlobalKey<FlutterMentionsState> _mentionsKey =
      GlobalKey<FlutterMentionsState>();
  String _handoverPlainText = '';
  String _handoverMarkupText = '';
  int _handoverFieldVersion = 0;
  String? _currentUserId;
  // --- AKHIR STATE BARU ---

  DateTime? _tanggalIjinJam;
  DateTime? _tanggalPenggantiJam;
  TimeOfDay? _startTimeIjin;
  TimeOfDay? _endTimeIjin;
  TimeOfDay? _startTimePengganti;
  TimeOfDay? _endTimePengganti;
  File? _buktiFile;

  dto_kategori_izin_jam.Data? _selectedKategoriIzinJam;

  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    // Tambahkan ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resolveCurrentUserId();
    });
  }

  // --- FUNGSI HELPER BARU ---
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
  // --- AKHIR FUNGSI HELPER BARU ---

  @override
  void dispose() {
    keperluanController.dispose();
    // handoverController.dispose(); // Sudah diganti
    tanggalIjinJamController.dispose();
    tanggalPenggantiJamController.dispose();
    startTimeIjinController.dispose();
    endTimeIjinController.dispose();
    startTimePenggantiController.dispose();
    endTimePenggantiController.dispose();
    super.dispose();
  }

  void _submitForm() {
    setState(() {
      _autoValidate = true;
    });

    if (formKey.currentState?.validate() ?? false) {
      // Validasi tambahan jika state belum ter-update
      if (_selectedKategoriIzinJam == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategori izin wajib dipilih.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }

      // TODO: Logika submit data
      print("Form valid. Mengirim data...");
      print("Keperluan: ${keperluanController.text}");

      print("Kategori ID: ${_selectedKategoriIzinJam?.idKategoriIzinJam}");

      // --- PERUBAHAN UNTUK MENTION ---
      final String handoverMarkup = _getCurrentHandoverMarkup().trim();
      final List<String> handoverUserIds =
          MentionParser.extractMentionedUserIds(handoverMarkup); //

      print("Handover (Markup): $handoverMarkup");
      print("Handover User IDs: $handoverUserIds");
      // --- AKHIR PERUBAHAN ---

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

    final kategoriProvider = context.watch<KategoriIzinJamProvider>();

    // --- Ambil provider untuk mentions ---
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
            KategoriIzinJamSelectionField(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Kategori Izin Jam',
              selectedKategori: _selectedKategoriIzinJam,
              onKategoriSelected: (selected) {
                setState(() {
                  _selectedKategoriIzinJam = selected;
                });
                if (_autoValidate) {
                  formKey.currentState?.validate();
                }
              },
              isRequired: true,
              autovalidateMode: autovalidateMode,
              validator: (value) {
                if (value == null) {
                  return 'Kategori izin wajib dipilih';
                }
                return null;
              },
            ),
            if (kategoriProvider.loading && kategoriProvider.items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(),
              ),

            SizedBox(height: 20),
            TextFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Keperluan',
              controller: keperluanController,
              hintText: 'Masukkan keperluan izin jam',
              isRequired: true,
              prefixIcon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              enabled: true,
              autovalidateMode: autovalidateMode,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Keperluan wajib diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // --- MULAI BLOK PENGGANTI HANDOVER ---
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
                    // Validasi 50 kata, sesuai file asli
                    if (wordCount < 50) {
                      return 'Minimal 50 kata. (Sekarang: $wordCount kata)';
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
              label: 'Tanggal Izin',
              controller: tanggalIjinJamController,
              initialDate: _tanggalIjinJam,
              onDateChanged: (date) => setState(() => _tanggalIjinJam = date),
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
                    controller: startTimeIjinController,
                    onChanged: (time) => setState(() => _startTimeIjin = time),
                    isRequired: true,
                    validator: (value) {
                      if (_startTimeIjin == null) return 'Wajib diisi';
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
                    controller: endTimeIjinController,
                    onChanged: (time) => setState(() => _endTimeIjin = time),
                    isRequired: true,
                    validator: (value) {
                      if (_endTimeIjin == null) return 'Wajib diisi';
                      if (_startTimeIjin != null && _endTimeIjin != null) {
                        final startMinutes =
                            _startTimeIjin!.hour * 60 + _startTimeIjin!.minute;
                        final endMinutes =
                            _endTimeIjin!.hour * 60 + _endTimeIjin!.minute;
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
                    validator: (value) {
                      if (_endTimePengganti == null) return 'Wajib diisi';
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

            // --- AKHIR BLOK PENGGANTI HANDOVER ---
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
