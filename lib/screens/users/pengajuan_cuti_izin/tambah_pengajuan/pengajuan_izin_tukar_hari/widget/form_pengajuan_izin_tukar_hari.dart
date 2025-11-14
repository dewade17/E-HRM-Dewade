import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
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

  final TextEditingController jenisCutiController = TextEditingController();
  final TextEditingController keperluanController = TextEditingController();

  final GlobalKey<FlutterMentionsState> _mentionsKey =
      GlobalKey<FlutterMentionsState>();
  String _handoverPlainText = '';
  String _handoverMarkupText = '';
  int _handoverFieldVersion = 0;
  String? _currentUserId;

  final List<_TanggalTukarPair> _daftarTanggal = [];

  bool _autoValidate = false;

  static final RegExp _mentionMarkupRegex = RegExp(
    r'([@#])\[__(.*?)__\]\(__(.*?)__\)',
  );

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  @override
  void initState() {
    super.initState();
    jenisCutiController.text = "Izin Tukar Hari";
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
    jenisCutiController.dispose();
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

  List<String> _extractMentionedUserIds(String markup) {
    if (markup.isEmpty) return const <String>[];

    final Set<String> ids = <String>{};
    for (final match in _mentionMarkupRegex.allMatches(markup)) {
      final String candidate = _pickBestMentionId(
        match.group(2) ?? '',
        match.group(3) ?? '',
      );
      if (candidate.isNotEmpty) {
        ids.add(candidate);
      }
    }
    return ids.toList(growable: false);
  }

  String _pickBestMentionId(String first, String second) {
    final String a = first.trim();
    final String b = second.trim();
    final bool aIsUuid = _uuidRegex.hasMatch(a);
    final bool bIsUuid = _uuidRegex.hasMatch(b);

    if (aIsUuid && !bIsUuid) return a;
    if (bIsUuid && !aIsUuid) return b;
    if (aIsUuid && bIsUuid) return a;
    if (a.isNotEmpty && !a.contains(' ')) return a;
    if (b.isNotEmpty && !b.contains(' ')) return b;
    return a.isNotEmpty ? a : b;
  }

  void _submitForm() {
    setState(() {
      _autoValidate = true;
    });

    if (formKey.currentState?.validate() ?? false) {
      bool allDatesValid = true;
      for (var pair in _daftarTanggal) {
        if (pair.tanggalIzin == null || pair.tanggalPengganti == null) {
          allDatesValid = false;
          break;
        }
        if (pair.tanggalIzin!.isAtSameMomentAs(pair.tanggalPengganti!)) {
          _showSnackBar(
            'Tanggal pengganti tidak boleh sama dengan tanggal izin.',
            isError: true,
          );
          return;
        }
      }

      if (!allDatesValid) {
        _showSnackBar(
          'Harap lengkapi semua pasangan tanggal izin dan pengganti.',
          isError: true,
        );
        return;
      }

      final String handoverMarkup =
          _mentionsKey.currentState?.controller?.markupText ??
          _handoverMarkupText;
      final String handoverPlainText =
          _mentionsKey.currentState?.controller?.text ?? _handoverPlainText;

      final List<String> handoverUserIds = _extractMentionedUserIds(
        handoverMarkup,
      );

      print("Form valid. Mengirim data...");
      print("Keperluan: ${keperluanController.text}");
      print("Handover (Markup): $handoverMarkup");
      print("Handover (Plain): $handoverPlainText");
      print("Handover User IDs: $handoverUserIds");
      print("Jumlah pasangan tanggal: ${_daftarTanggal.length}");
      for (var pair in _daftarTanggal) {
        print("Izin: ${pair.tanggalIzin}, Pengganti: ${pair.tanggalPengganti}");
      }

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
            TextFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Jenis Cuti',
              controller: jenisCutiController,
              hintText: 'Izin Tukar Hari',
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
