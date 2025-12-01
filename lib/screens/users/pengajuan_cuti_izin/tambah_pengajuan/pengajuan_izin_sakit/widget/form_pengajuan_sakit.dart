// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:async';
import 'package:e_hrm/providers/riwayat_pengajuan/riwayat_pengajuan_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
import 'package:e_hrm/providers/pengajuan_sakit/pengajuan_sakit_provider.dart';
import 'package:e_hrm/utils/mention_parser.dart';
import 'package:e_hrm/providers/pengajuan_sakit/kategori_pengajuan_sakit_provider.dart';
import 'package:e_hrm/dto/pengajuan_sakit/kategori_pengajuan_sakit.dart'
    as dto_sakit;
import 'package:e_hrm/dto/pengajuan_sakit/pengajuan_sakit.dart'
    as pengajuan_sakit;
import 'package:e_hrm/shared_widget/kategori_sakit_selection_field.dart';
import 'package:e_hrm/providers/tag_hand_over/tag_hand_over_provider.dart';
import 'package:e_hrm/dto/tag_hand_over/tag_hand_over.dart' as dto_tag;
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';

class FormPengajuanSakit extends StatefulWidget {
  const FormPengajuanSakit({super.key, this.initialPengajuan});

  final pengajuan_sakit.Data? initialPengajuan;

  @override
  State<FormPengajuanSakit> createState() => _FormPengajuanSakitState();
}

class _FormPengajuanSakitState extends State<FormPengajuanSakit> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController tanggalPengajuanSakitController =
      TextEditingController();

  final GlobalKey<FlutterMentionsState> _mentionsKey =
      GlobalKey<FlutterMentionsState>();
  String _handoverPlainText = '';
  String _handoverMarkupText = '';
  int _handoverFieldVersion = 0;
  String? _currentUserId;
  dto_sakit.Data? _selectedKategoriSakit;

  DateTime? _tanggalPengajuanSakit;
  File? _buktiFile;
  bool _autoValidate = false;
  String? _initialKategoriId;
  bool _kategoriPrefilledFromProvider = false;

  bool get _isEditing => widget.initialPengajuan != null;

  @override
  void initState() {
    super.initState();
    _prefillInitialPengajuan(widget.initialPengajuan);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resolveCurrentUserId();
      context.read<KategoriPengajuanSakitProvider>().fetch();
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

  void _prefillInitialPengajuan(pengajuan_sakit.Data? data) {
    if (data == null) return;

    _initialKategoriId = data.idKategoriSakit.isNotEmpty
        ? data.idKategoriSakit
        : null;

    if (data.kategori != null && data.kategori!.idKategoriSakit.isNotEmpty) {
      _selectedKategoriSakit = dto_sakit.Data(
        idKategoriSakit: data.kategori!.idKategoriSakit,
        namaKategori: data.kategori!.namaKategori,
        createdAt: data.updatedAt ?? DateTime.now(),
        updatedAt: data.updatedAt ?? DateTime.now(),
        deletedAt: null,
      );
    }

    _tanggalPengajuanSakit = data.tanggalPengajuan;
    if (data.tanggalPengajuan != null) {
      tanggalPengajuanSakitController.text = DateFormat(
        'dd MMMM yyyy',
        'id_ID',
      ).format(data.tanggalPengajuan!);
    }

    _handoverMarkupText = data.handover;
    _handoverPlainText = MentionParser.convertMarkupToDisplay(data.handover);
  }

  void _tryPrefillKategoriFromProvider(
    KategoriPengajuanSakitProvider kategoriProvider,
  ) {
    if (_kategoriPrefilledFromProvider ||
        _initialKategoriId == null ||
        kategoriProvider.items.isEmpty) {
      return;
    }

    if (_selectedKategoriSakit != null &&
        _selectedKategoriSakit!.idKategoriSakit == _initialKategoriId) {
      _kategoriPrefilledFromProvider = true;
      return;
    }

    try {
      final match = kategoriProvider.items.firstWhere(
        (item) => item.idKategoriSakit == _initialKategoriId,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedKategoriSakit = match;
          _kategoriPrefilledFromProvider = true;
        });
      });
    } catch (_) {
      _kategoriPrefilledFromProvider = true;
    }
  }

  void _resetFormFields(ApproversPengajuanProvider approversProvider) {
    formKey.currentState?.reset();
    approversProvider.clearSelection();
    tanggalPengajuanSakitController.clear();

    setState(() {
      _selectedKategoriSakit = null;
      _tanggalPengajuanSakit = null;
      _buktiFile = null;
      _handoverPlainText = '';
      _handoverMarkupText = '';
      _handoverFieldVersion++;
      _autoValidate = false;
      _initialKategoriId = null;
      _kategoriPrefilledFromProvider = false;
    });
  }

  @override
  void dispose() {
    tanggalPengajuanSakitController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      _autoValidate = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    if (!(formKey.currentState?.validate() ?? false)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Harap periksa kembali semua isian form.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    if (_selectedKategoriSakit == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Kategori sakit wajib dipilih.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    if (!_isEditing && _buktiFile == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Bukti wajib diunggah.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final approversProvider = context.read<ApproversPengajuanProvider>();
    final pengajuanSakitProvider = context.read<PengajuanSakitProvider>();

    final String handoverMarkup = _getCurrentHandoverMarkup().trim();
    final List<String> handoverUserIds = MentionParser.extractMentionedUserIds(
      handoverMarkup,
    );

    http.MultipartFile? lampiran;
    if (_buktiFile != null) {
      final String path = _buktiFile!.path.toLowerCase();
      if (!path.endsWith('.jpg') &&
          !path.endsWith('.jpeg') &&
          !path.endsWith('.png')) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Format file tidak valid! Hanya JPG/PNG.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final String? mimeStr = lookupMimeType(_buktiFile!.path);
      MediaType? mediaType;
      if (mimeStr != null) {
        mediaType = MediaType.parse(mimeStr);
      }

      try {
        lampiran = await http.MultipartFile.fromPath(
          'lampiran_izin_sakit',
          _buktiFile!.path,
          contentType: mediaType,
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal membaca lampiran: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }
    }

    pengajuan_sakit.Data? result;

    if (_isEditing) {
      result = await pengajuanSakitProvider.updatePengajuan(
        widget.initialPengajuan!.idPengajuanIzinSakit,
        idKategoriSakit: _selectedKategoriSakit!.idKategoriSakit,
        tanggalPengajuan: _tanggalPengajuanSakit,
        handover: handoverMarkup,
        handoverUserIds: handoverUserIds,
        approversProvider: approversProvider,
        lampiran: lampiran,
      );
    } else {
      result = await pengajuanSakitProvider.createPengajuan(
        idKategoriSakit: _selectedKategoriSakit!.idKategoriSakit,
        tanggalPengajuan: _tanggalPengajuanSakit,
        handover: handoverMarkup,
        handoverUserIds: handoverUserIds,
        approversProvider: approversProvider,
        lampiran: lampiran,
      );
    }

    final String? saveError = pengajuanSakitProvider.saveError;
    final String? saveMessage = pengajuanSakitProvider.saveMessage;

    if (saveError != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveError),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    if (saveMessage != null && saveMessage.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveMessage),
          backgroundColor: AppColors.succesColor,
        ),
      );
    }

    if (mounted) {
      await context.read<RiwayatPengajuanProvider>().fetch();
    }

    final popPayload = result ?? true;

    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(popPayload);
    } else {
      _resetFormFields(approversProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final autovalidateMode = _autoValidate
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    final kategoriProvider = context.watch<KategoriPengajuanSakitProvider>();
    final tagProvider = context.watch<TagHandOverProvider>();
    final authProvider = context.watch<AuthProvider>();
    final String? providerUserId = _sanitizeUserId(
      authProvider.currentUser?.user.idUser,
    );
    final String? effectiveCurrentUserId =
        providerUserId ?? _sanitizeUserId(_currentUserId);
    _tryPrefillKategoriFromProvider(kategoriProvider);

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            KategoriSakitSelectionField(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Kategori Sakit',
              hintText: 'Pilih Kategori Sakit...',
              selectedKategori: _selectedKategoriSakit,
              onKategoriSelected: (selected) {
                setState(() {
                  _selectedKategoriSakit = selected;
                });
                if (_autoValidate) {
                  formKey.currentState?.validate();
                }
              },
              isRequired: true,
              autovalidateMode: autovalidateMode,
              validator: (value) {
                if (value == null) {
                  return 'Kategori sakit wajib dipilih';
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
                    if (wordCount < 10) {
                      return 'Minimal 10 kata. (Sekarang: $wordCount kata)';
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
                                    (dto_tag.Data user) =>
                                        effectiveCurrentUserId == null ||
                                        user.idUser != effectiveCurrentUserId,
                                  )
                                  .map(
                                    (dto_tag.Data user) => {
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
            FilePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Unggah Bukti (JPG/PNG)',
              buttonText: 'Unggah Bukti',
              prefixIcon: Icons.camera_alt_outlined,
              file: _buktiFile,
              fileUrl: widget.initialPengajuan?.lampiranIzinSakitUrl,
              allowedExtensions: const ['jpg', 'jpeg', 'png'],
              onFileChanged: (newFile) {
                setState(() {
                  _buktiFile = newFile;
                });
                if (_autoValidate) {
                  formKey.currentState?.validate();
                }
              },
              isRequired: !_isEditing,
              autovalidateMode: autovalidateMode,
              validator: (file) {
                if (!_isEditing && file == null) {
                  return 'Bukti wajib diunggah';
                }
                if (file != null) {
                  final String path = file.path.toLowerCase();
                  final bool isValidImage =
                      path.endsWith('.jpg') ||
                      path.endsWith('.jpeg') ||
                      path.endsWith('.png');
                  if (!isValidImage) {
                    return 'Format file harus JPG, JPEG, atau PNG.';
                  }
                  final bytes = file.lengthSync();
                  if (bytes > 5 * 1024 * 1024) {
                    return 'Ukuran foto maksimal 5MB.';
                  }
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Consumer<PengajuanSakitProvider>(
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
                            _isEditing ? "Simpan" : "Kirim",
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
