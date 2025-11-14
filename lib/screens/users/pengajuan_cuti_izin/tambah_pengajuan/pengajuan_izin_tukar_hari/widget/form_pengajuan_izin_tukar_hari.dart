import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  final TextEditingController handoverController = TextEditingController();

  final List<_TanggalTukarPair> _daftarTanggal = [];

  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    jenisCutiController.text = "Izin Tukar Hari";
    _addPair();
  }

  @override
  void dispose() {
    jenisCutiController.dispose();
    keperluanController.dispose();
    handoverController.dispose();

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

      print("Form valid. Mengirim data...");
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
