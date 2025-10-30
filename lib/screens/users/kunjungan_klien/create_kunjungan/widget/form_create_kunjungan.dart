import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kategori_kunjungan.dart'; // <-- Import DTO Kategori
import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/rencana_kunjungan/rencana_kunjungan_screen.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
// import 'package:e_hrm/shared_widget/dropdown_field_widget.dart'; // <-- Hapus ini
import 'package:e_hrm/shared_widget/kategori_kunjungan_selection_field.dart'; // <-- Import Field Baru
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

  // String? _selectedKategoriId; // <-- Ganti ini
  KategoriKunjunganItem? _selectedKategori; // <-- Dengan ini

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
      final kategoriProvider = context.read<KategoriKunjunganProvider>();
      kategoriProvider.ensureLoaded().then((_) {
        // Setelah data dimuat, coba set state awal jika ada selectedId di provider
        if (mounted &&
            kategoriProvider.selectedItem != null &&
            _selectedKategori == null) {
          setState(() {
            _selectedKategori = kategoriProvider.selectedItem;
          });
        }
      });
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

    // Validasi kategori sudah ditangani oleh KategoriKunjunganSelectionField
    // if (_selectedKategori == null) { ... } // Tidak perlu lagi

    final tanggal = _selectedTanggal;
    if (tanggal == null) {
      _showSnackBar('Silakan pilih tanggal kunjungan.', isError: true);
      return;
    }
    // Validasi jam mulai dan selesai
    if (_selectedJamMulai == null || _selectedJamSelesai == null) {
      _showSnackBar('Jam mulai dan jam selesai wajib diisi.', isError: true);
      return;
    }
    final startDateTime = _combineDateTime(tanggal, _selectedJamMulai!);
    final endDateTime = _combineDateTime(tanggal, _selectedJamSelesai!);
    if (endDateTime != null &&
        startDateTime != null &&
        !endDateTime.isAfter(startDateTime)) {
      _showSnackBar('Jam selesai harus setelah jam mulai.', isError: true);
      return;
    }

    final provider = context.read<KunjunganKlienProvider>();
    final deskripsi = keterangankunjungancontroller.text.trim();

    // Pastikan _selectedKategori tidak null sebelum mengakses id
    if (_selectedKategori == null) {
      _showSnackBar('Jenis kunjungan belum dipilih.', isError: true);
      return;
    }

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
      idKategoriKunjungan:
          _selectedKategori!.idKategoriKunjungan, // <-- Ambil ID dari objek
      tanggal: tanggalUtc,
      jamMulai: startDateTime, // Kirim DateTime
      jamSelesai: endDateTime, // Kirim DateTime
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
        backgroundColor: isError
            ? Colors.red
            : AppColors.succesColor, // <-- Perbaiki warna sukses
      ),
    );
  }

  DateTime? _combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider tetap diperlukan untuk status loading/saving
    final kategoriProvider = context.watch<KategoriKunjunganProvider>();
    final kunjunganProvider = context.watch<KunjunganKlienProvider>();
    final isSaving = kunjunganProvider.isSaving;

    // Autovalidate mode
    final autovalidateMode = _autoValidate
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;

    return Center(
      child: Container(
        width: 338,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: autovalidateMode, // Set autovalidate di Form
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // --- GANTI DROPDOWN DENGAN FIELD BARU ---
                    KategoriKunjunganSelectionField(
                      width: 290,
                      prefixIcon: Icons.add_box_outlined,
                      label: "Jenis Kunjungan",
                      hintText: "Pilih jenis kunjungan...",
                      selectedKategori: _selectedKategori, // Kirim objek
                      isRequired: true, // Tandai wajib
                      onKategoriSelected: (selected) {
                        setState(() => _selectedKategori = selected);
                        // Update juga ID di KategoriKunjunganProvider jika perlu
                        if (selected != null) {
                          kategoriProvider.setSelectedId(
                            selected.idKategoriKunjungan,
                          );
                        } else {
                          kategoriProvider.clearSelection();
                        }
                        // Trigger validasi jika form sudah pernah divalidasi
                        if (_autoValidate) {
                          _formKey.currentState?.validate();
                        }
                      },
                      validator: (value) {
                        // Validator sederhana
                        if (value == null) {
                          return 'Anda harus memilih jenis kunjungan.';
                        }
                        return null;
                      },
                      // autovalidateMode: autovalidateMode, // Dihapus dari field
                    ),
                    // --- AKHIR PERGANTIAN ---
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      width: 290,
                      prefixIcon: Icons.message,
                      maxLines: 3,
                      label: "Keterangan",
                      controller: keterangankunjungancontroller,
                      validator: (value) {
                        // Validator keterangan
                        if (value == null || value.trim().isEmpty) {
                          // Keterangan boleh kosong? Jika ya, return null. Jika tidak:
                          // return 'Keterangan tidak boleh kosong';
                          return null; // Asumsi boleh kosong, hapus jika wajib
                        }
                        final words = value
                            .trim()
                            .split(RegExp(r'\s+'))
                            .where((s) => s.isNotEmpty)
                            .toList();
                        if (words.length < 15) {
                          return 'Keterangan minimal 15 kata. (${words.length}/15)';
                        }
                        return null;
                      },
                      // autovalidateMode: autovalidateMode, // Dihapus dari field
                    ),
                    const SizedBox(height: 20),
                    DatePickerFieldWidget(
                      label: "Pilih Tanggal",
                      controller: calendarkunjunganController,
                      width: 290,
                      isRequired: true, // Tandai wajib
                      initialDate: _selectedTanggal, // Berikan nilai awal
                      onDateChanged: (date) {
                        setState(() => _selectedTanggal = date);
                        // Trigger validasi jika perlu
                        if (_autoValidate) {
                          _formKey.currentState?.validate();
                        }
                      },
                      // Validator otomatis ditangani jika isRequired = true
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Ganti ke spaceBetween
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Agar pesan error rapi
                      children: [
                        // Gunakan Flexible atau Expanded agar lebar terbagi
                        Flexible(
                          child: TimePickerFieldWidget(
                            label: "Jam mulai",
                            controller: jamMulaiController,
                            width: null, // Biarkan Flexible mengatur lebar
                            initialTime:
                                _selectedJamMulai, // Berikan nilai awal
                            isRequired: true,
                            onChanged: (value) {
                              setState(() => _selectedJamMulai = value);
                              // Trigger validasi jika perlu
                              if (_autoValidate) {
                                _formKey.currentState?.validate();
                              }
                            },
                            validator: (value) {
                              // Tambah validator
                              if (_selectedJamMulai == null) {
                                return 'Wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20), // Jarak antar field
                        Flexible(
                          child: TimePickerFieldWidget(
                            label: "Jam selesai",
                            controller: jamSelesaiController,
                            width: null, // Biarkan Flexible mengatur lebar
                            initialTime:
                                _selectedJamSelesai, // Berikan nilai awal
                            isRequired: true,
                            onChanged: (value) {
                              setState(() => _selectedJamSelesai = value);
                              // Trigger validasi jika perlu
                              if (_autoValidate) {
                                _formKey.currentState?.validate();
                              }
                            },
                            validator: (value) {
                              // Tambah validator
                              if (_selectedJamSelesai == null) {
                                return 'Wajib diisi';
                              }
                              // Validasi vs jam mulai
                              if (_selectedJamMulai != null &&
                                  _selectedJamSelesai != null) {
                                final startMinutes =
                                    _selectedJamMulai!.hour * 60 +
                                    _selectedJamMulai!.minute;
                                final endMinutes =
                                    _selectedJamSelesai!.hour * 60 +
                                    _selectedJamSelesai!.minute;
                                if (endMinutes <= startMinutes) {
                                  return 'Harus > jam mulai';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Tombol Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  elevation: 2,
                ),
                onPressed: isSaving ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 30,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors
                                  .textDefaultColor, // Atau warna lain yg kontras
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
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
