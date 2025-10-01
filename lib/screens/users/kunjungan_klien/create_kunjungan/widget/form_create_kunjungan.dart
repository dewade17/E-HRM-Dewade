import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/rencana_kunjungan/rencana_kunjungan_screen.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:e_hrm/shared_widget/time_picker_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FormCreateKunjungan extends StatefulWidget {
  const FormCreateKunjungan({super.key});

  @override
  State<FormCreateKunjungan> createState() => _FormCreateKunjunganState();
}

class _FormCreateKunjunganState extends State<FormCreateKunjungan> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _didFetchInitial = false;

  String? _selectedKategoriId;
  DateTime? _selectedTanggal;
  TimeOfDay? _selectedJamMulai;
  TimeOfDay? _selectedJamSelesai;

  final TextEditingController calendarkunjunganController =
      TextEditingController();
  final TextEditingController jamMulaiController = TextEditingController();
  final TextEditingController jamSelesaiController = TextEditingController();
  final TextEditingController keterangankunjungancontroller =
      TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didFetchInitial) return;
    _didFetchInitial = true;

    Future.microtask(() {
      if (!mounted) return;
      context.read<KategoriKunjunganProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    calendarkunjunganController.dispose();
    jamMulaiController.dispose();
    jamSelesaiController.dispose();
    keterangankunjungancontroller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    setState(() {
      _autoValidate = true;
    });

    if (!formState.validate()) {
      return;
    }

    final kategoriProvider = context.read<KategoriKunjunganProvider>();
    final kategoriId = _selectedKategoriId ?? kategoriProvider.selectedId;
    if (kategoriId == null) {
      _showSnackBar(
        'Silakan pilih jenis kunjungan terlebih dahulu.',
        isError: true,
      );
      return;
    }

    final tanggal = _selectedTanggal;
    if (tanggal == null) {
      _showSnackBar('Silakan pilih tanggal kunjungan.', isError: true);
      return;
    }

    final provider = context.read<KunjunganKlienProvider>();
    final deskripsi = keterangankunjungancontroller.text.trim();

    final normalizedDate = DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
    ); // local date only
    final tanggalUtc = DateTime.utc(
      normalizedDate.year,
      normalizedDate.month,
      normalizedDate.day,
    );

    await provider.createKunjungan(
      idKategoriKunjungan: kategoriId,
      tanggal: tanggalUtc,
      jamMulai: _combineDateTime(normalizedDate, _selectedJamMulai),
      jamSelesai: _combineDateTime(normalizedDate, _selectedJamSelesai),
      deskripsi: deskripsi.isEmpty ? null : deskripsi,
    );

    if (!mounted) return;

    final error = provider.saveError;
    final message = provider.saveMessage;

    if (error != null) {
      _showSnackBar(error, isError: true);
      return;
    }

    final navigator = Navigator.of(context);
    final successMessage = message ?? 'Kunjungan berhasil dibuat.';
    if (navigator.canPop()) {
      navigator.pop(successMessage);
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const RencanaKunjunganScreen()),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.accentColor,
      ),
    );
  }

  DateTime? _combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    final kategoriProvider = context.watch<KategoriKunjunganProvider>();
    final kunjunganProvider = context.watch<KunjunganKlienProvider>();
    final isSaving = kunjunganProvider.isSaving;

    final dropdownItems = kategoriProvider.items
        .map(
          (item) => DropdownMenuItem<String>(
            value: item.idKategoriKunjungan,
            child: Text(item.kategoriKunjungan),
          ),
        )
        .toList();

    final selectedKategoriId =
        _selectedKategoriId ?? kategoriProvider.selectedId;

    final autovalidateMode = _autoValidate
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;

    return Center(
      child: Container(
        width: 338,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.backgroundColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            children: [
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    DropdownFieldWidget<String>(
                      width: 290,
                      prefixIcon: Icons.add_box_outlined,
                      label: "Jenis Kunjungan",
                      hintText: "Pilih jenis kunjungan...",
                      value: selectedKategoriId,
                      items: dropdownItems,
                      onChanged:
                          kategoriProvider.isLoading && dropdownItems.isEmpty
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _selectedKategoriId = newValue;
                              });
                              if (newValue != null) {
                                kategoriProvider.setSelectedId(newValue);
                              }
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Anda harus memilih jenis kunjungan.';
                        }
                        return null;
                      },
                      autovalidateMode: autovalidateMode,
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      width: 290,
                      prefixIcon: Icons.message,
                      maxLines: 3,
                      label: "Keterangan",
                      controller: keterangankunjungancontroller,
                    ),
                    const SizedBox(height: 20),
                    DatePickerFieldWidget(
                      label: "Pilih Tanggal",
                      controller: calendarkunjunganController,
                      width: 290,
                      isRequired: true,
                      onDateChanged: (date) {
                        _selectedTanggal = date;
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TimePickerFieldWidget(
                          label: "Jam mulai",
                          controller: jamMulaiController,
                          width: 135,
                          onChanged: (value) {
                            _selectedJamMulai = value;
                          },
                        ),
                        TimePickerFieldWidget(
                          label: "Jam selesai",
                          controller: jamSelesaiController,
                          width: 135,
                          onChanged: (value) {
                            _selectedJamSelesai = value;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  elevation: 2,
                ),
                onPressed: isSaving ? null : _submit,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textDefaultColor,
                            ),
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDefaultColor,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
