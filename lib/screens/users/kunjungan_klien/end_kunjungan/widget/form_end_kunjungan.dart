// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kategori_kunjungan.dart'; // <-- Import DTO Kategori
import 'package:e_hrm/dto/kunjungan/kunjungan_klien.dart';
import 'package:e_hrm/providers/approvers/approvers_provider_all.dart';

import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/mark_me_map.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/recipient_kunjungan.dart';
// import 'package:e_hrm/shared_widget/dropdown_field_widget.dart'; // <-- Dihapus
import 'package:e_hrm/shared_widget/kategori_kunjungan_selection_field.dart'; // <-- Ditambahkan
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FormEndKunjungan extends StatefulWidget {
  const FormEndKunjungan({super.key, required this.item});

  final Data item;

  @override
  State<FormEndKunjungan> createState() => _FormEndKunjunganState();
}

class _FormEndKunjunganState extends State<FormEndKunjungan> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  late final TextEditingController latitudeEndcontroller;
  late final TextEditingController longitudeEndcontroller;
  late final TextEditingController keterangankunjungancontroller;
  // String? _selectedKategoriId; // <-- Diganti
  KategoriKunjunganItem? _selectedKategori; // <-- Menjadi ini
  bool _didInitProviders = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    latitudeEndcontroller = TextEditingController(
      text: item.endLatitude != null
          ? item.endLatitude!.toStringAsFixed(6)
          : '',
    );
    longitudeEndcontroller = TextEditingController(
      text: item.endLongitude != null
          ? item.endLongitude!.toStringAsFixed(6)
          : '',
    );
    keterangankunjungancontroller = TextEditingController(
      text: item.deskripsi ?? '',
    );
    // Simpan ID awal untuk lookup nanti
    final initialKategoriId =
        item.idKategoriKunjungan ?? item.kategoriIdFromRelation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didInitProviders) return;
      _didInitProviders = true;

      final kategoriProvider = context.read<KategoriKunjunganProvider>();
      // Pastikan data kategori dimuat SEBELUM mencoba mencari item
      kategoriProvider.ensureLoaded().then((_) {
        // Setelah data dimuat, cari objek Kategori berdasarkan ID awal
        if (mounted && initialKategoriId != null) {
          final initialItem = kategoriProvider.itemById(initialKategoriId);
          if (initialItem != null) {
            // Set state HANYA jika _selectedKategori masih null
            if (_selectedKategori == null) {
              setState(() {
                _selectedKategori = initialItem;
              });
              // Update juga selectedId di provider agar konsisten
              kategoriProvider.setSelectedId(initialKategoriId);
            }
          } else {
            // Jika tidak ketemu di list, buat objek sementara agar tampil
            if (_selectedKategori == null) {
              setState(() {
                // Buat objek sementara DENGAN nama dari data kunjungan jika ada
                _selectedKategori = KategoriKunjunganItem(
                  idKategoriKunjungan: initialKategoriId,
                  kategoriKunjungan:
                      item.kategori?.kategoriKunjungan ?? 'Kategori Tersimpan',
                );
              });
            }
          }
        } else if (mounted &&
            kategoriProvider.selectedItem != null &&
            _selectedKategori == null) {
          // Fallback ke selected item di provider jika initialId null
          setState(() {
            _selectedKategori = kategoriProvider.selectedItem;
          });
        }
      });

      final approverProvider = context.read<ApproversProviderAll>();
      approverProvider.clearSelection(); // Pastikan clear dulu
      // Ambil data approver terbaru SEBELUM set pilihan lama
      approverProvider.refresh().then((_) {
        if (!mounted) return;
        // Set approver terpilih dari data 'reports' kunjungan
        for (final report in widget.item.reports) {
          final id = report.idUser;
          if (id != null && id.isNotEmpty) {
            // Cari User di provider
            final userExists = approverProvider.users.any(
              (u) => u.idUser == id,
            );
            if (userExists &&
                !approverProvider.selectedRecipientIds.contains(id)) {
              // Gunakan toggleSelect agar state internal provider terupdate
              approverProvider.toggleSelect(id);
            } else if (!userExists) {
              // Tampilkan peringatan jika approver lama tidak ditemukan di daftar terbaru
              // print(
              //   "Warning: Approver with ID $id from report not found in current list.",
              // );
            }
          }
        }
        // Panggil notifyListeners jika toggleSelect tidak otomatis notify dan ada perubahan
        // approverProvider.notifyListeners();
      });
    });
  }

  @override
  void dispose() {
    latitudeEndcontroller.dispose();
    longitudeEndcontroller.dispose();
    keterangankunjungancontroller.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    // Tambah cek mounted
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.succesColor,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    setState(() {
      _autoValidate = true;
    });

    if (!formState.validate()) {
      _showSnackBar('Harap periksa kembali isian form.', isError: true);
      return;
    }

    // Validasi lokasi sudah ada di FormField
    final latitude = double.tryParse(latitudeEndcontroller.text.trim());
    final longitude = double.tryParse(longitudeEndcontroller.text.trim());
    // Tidak perlu cek null lagi

    // Validasi Kategori sudah ditangani oleh KategoriKunjunganSelectionField
    // Pastikan _selectedKategori tidak null
    if (_selectedKategori == null) {
      _showSnackBar('Jenis kunjungan belum dipilih.', isError: true);
      return;
    }

    final kunjunganProvider = context.read<KunjunganKlienProvider>();
    if (kunjunganProvider.isSaving) return;

    final approverProvider = context.read<ApproversProviderAll>();
    // Validasi Approver sudah ditangani oleh FormField

    FocusScope.of(context).unfocus();

    final deskripsi = keterangankunjungancontroller.text.trim();

    // Logika recipients (tidak berubah)
    final selectedUserMap = {
      for (final user in approverProvider.selectedUsers) user.idUser: user,
    };
    final existingRecipientMap = {
      for (final report in widget.item.reports)
        if (report.idUser != null && report.idUser!.isNotEmpty)
          report.idUser!: report,
    };

    final recipients = approverProvider.selectedRecipientIds
        .where((id) => id.trim().isNotEmpty)
        .map((id) {
          final user = selectedUserMap[id];
          final existing = existingRecipientMap[id];
          final name =
              (user?.namaPengguna ?? existing?.recipientNamaSnapshot)?.trim() ??
              '';
          final role = (user?.role ?? existing?.recipientRoleSnapshot)?.trim();

          if (name.isEmpty && (user != null || existing != null)) {
            // print(
            //   "Warning: Recipient name is empty for user ID $id. Using fallback.",
            // );
            // Anda mungkin ingin memberi nama default atau handle error di sini
          }

          return {
            'id_user': id,
            // Hanya kirim snapshot jika namanya valid
            if (name.isNotEmpty) 'recipient_nama_snapshot': name,
            if (role != null && role.isNotEmpty)
              'recipient_role_snapshot': role.toUpperCase(),
          };
        })
        .toList();

    // --- Kirim ke API ---
    await kunjunganProvider.submitEndKunjungan(
      widget.item.idKunjungan,
      deskripsi: deskripsi.isEmpty ? null : deskripsi,
      jamCheckout: DateTime.now(), // Gunakan waktu saat submit
      endLatitude: latitude!, // Aman karena sudah divalidasi
      endLongitude: longitude!, // Aman karena sudah divalidasi
      idKategoriKunjungan:
          _selectedKategori!.idKategoriKunjungan, // Ambil ID dari objek
      recipients: recipients.isEmpty ? null : recipients,
    );

    if (!mounted) return;

    // --- Handle Response ---
    final error = kunjunganProvider.saveError;
    final message = kunjunganProvider.saveMessage;

    if (error != null) {
      _showSnackBar(error, isError: true);
      return;
    }

    if (message != null && message.isNotEmpty) {
      _showSnackBar(message);
    } else {
      _showSnackBar('Kunjungan berhasil diselesaikan.');
    }

    // Pop dua kali jika sukses untuk kembali ke daftar utama
    int popCount = 0;
    Navigator.of(context).popUntil((route) {
      // Kembali sampai ke route SEBELUM halaman EndKunjunganScreen
      // atau maksimal 2 kali pop
      return popCount++ >= 1 &&
          route.settings.name !=
              '/end-kunjungan'; // Ganti '/end-kunjungan' jika nama route berbeda
      // Atau cara sederhana: pop 2x
      // return popCount++ == 2;
    });
    // Jika hanya ingin pop 1x (kembali ke detail):
    // Navigator.of(context).maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    // Pindahkan watch provider ke atas
    context.watch<ApproversProviderAll>();
    // Watch KategoriKunjunganProvider agar field bisa rebuild jika datanya berubah
    context.watch<KategoriKunjunganProvider>();
    final kunjunganProvider = context.watch<KunjunganKlienProvider>();

    final isSaving = kunjunganProvider.isSaving;
    final autovalidateMode = _autoValidate
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;

    return Center(
      child: Container(
        width: 338,
        decoration: BoxDecoration(
          // Gunakan warna solid atau gradient sesuai desain
          color: Colors.white, // Contoh warna solid
          border: Border.all(color: AppColors.secondaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            // Tambahkan shadow halus (opsional)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: autovalidateMode, // Set di Form
          child: Column(
            children: [
              const SizedBox(height: 20),
              // MarkMeMap dan validator lokasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    MarkMeMap(
                      latitudeController: latitudeEndcontroller,
                      longitudeController: longitudeEndcontroller,
                      autoFetchOnInit: true,
                      onPicked: (lat, lng) {
                        if (!mounted) return; // Cek mounted setelah async
                        latitudeEndcontroller.text = lat.toStringAsFixed(6);
                        longitudeEndcontroller.text = lng.toStringAsFixed(6);
                        // Trigger validasi jika form sudah pernah divalidasi
                        if (_autoValidate) {
                          _formKey.currentState?.validate();
                        }
                      },
                    ),
                    FormField<String>(
                      // Validator untuk lokasi
                      autovalidateMode: autovalidateMode,
                      validator: (_) {
                        final latText = latitudeEndcontroller.text.trim();
                        final lonText = longitudeEndcontroller.text.trim();
                        if (latText.isEmpty || lonText.isEmpty) {
                          return 'Anda harus menandai lokasi akhir kunjungan.';
                        }
                        if (double.tryParse(latText) == null ||
                            double.tryParse(lonText) == null) {
                          return 'Format lokasi tidak valid.';
                        }
                        return null; // Lolos validasi
                      },
                      builder: (state) {
                        if (state.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 6,
                              left: 4,
                              right: 4,
                            ), // Beri padding
                            child: Text(
                              state.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Text Field Keterangan
              TextFieldWidget(
                backgroundColor: AppColors.textColor,
                borderColor: AppColors.hintColor,
                width: 300,
                prefixIcon: Icons.message,
                maxLines: 3,
                label: 'Keterangan',
                controller: keterangankunjungancontroller,
                validator: (value) {
                  // Keterangan sekarang wajib minimal 15 kata
                  if (value == null || value.trim().isEmpty) {
                    return 'Keterangan tidak boleh kosong.';
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
                isRequired: true, // Tandai wajib di label
              ),
              const SizedBox(height: 20),
              // Label "Laporan Ke"
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 5,
                  ),
                  child: Text(
                    'Laporan Ke',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ), // Sesuaikan style label
                ),
              ),
              // RecipientKunjungan (pemilihan approver)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: const RecipientKunjungan(),
              ),
              // Validator untuk Approver
              FormField<bool>(
                autovalidateMode: autovalidateMode,
                // Cek approverProvider langsung di validator
                validator: (value) {
                  // Gunakan read karena hanya perlu nilai saat validasi
                  final currentSelectedIds = context
                      .read<ApproversProviderAll>()
                      .selectedRecipientIds;
                  if (currentSelectedIds.isEmpty) {
                    return 'Anda harus memilih minimal satu penerima laporan.';
                  }
                  return null;
                },
                builder: (FormFieldState<bool> state) {
                  if (state.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        left: 20,
                        right: 20,
                      ),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),
              // --- FIELD PEMILIHAN KATEGORI BARU ---
              KategoriKunjunganSelectionField(
                backgroundColor: AppColors.textColor,
                borderColor: AppColors.textDefaultColor,
                width: 300,
                prefixIcon: Icons.category_outlined, // Ganti ikon jika mau
                label: 'Jenis Kunjungan',
                hintText: 'Pilih jenis kunjungan...',
                selectedKategori: _selectedKategori, // Kirim objek
                isRequired: true, // Tandai wajib
                onKategoriSelected: (selected) {
                  // Cek mounted sebelum setState
                  if (!mounted) return;
                  setState(() => _selectedKategori = selected);
                  // Update juga ID di KategoriKunjunganProvider
                  final kategoriProv = context
                      .read<KategoriKunjunganProvider>();
                  if (selected != null) {
                    kategoriProv.setSelectedId(selected.idKategoriKunjungan);
                  } else {
                    kategoriProv.clearSelection();
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
              ),
              // --- AKHIR FIELD PEMILIHAN KATEGORI BARU ---
              const SizedBox(height: 20),
              // Tampilan Bukti Kunjungan (Image)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Bukti Kunjungan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    // Gunakan AspectRatio agar ukuran konsisten
                    aspectRatio: 16 / 9, // Sesuaikan rasio jika perlu
                    child:
                        (widget.item.lampiranKunjunganUrl != null &&
                            widget.item.lampiranKunjunganUrl!.isNotEmpty)
                        ? Image.network(
                            widget.item.lampiranKunjunganUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              /* ... error builder ... */
                              return Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  size: 42,
                                  color: Colors.black38,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              /* ... loading builder ... */
                              if (loadingProgress == null) return child;
                              return Container(
                                alignment: Alignment.center,
                                color: Colors.grey.shade200,
                                child: const CircularProgressIndicator(),
                              );
                            },
                          )
                        : Container(
                            // Placeholder jika tidak ada gambar
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Belum ada bukti kunjungan.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Tombol Selesai
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.errorColor, // Warna merah untuk selesai
                  foregroundColor: AppColors.textColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4, // Tambah sedikit shadow
                ),
                onPressed: isSaving ? null : _handleSubmit,
                child: isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Selesaikan Kunjungan', // Ubah teks tombol
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ), // Ubah ukuran/ketebalan font
                      ),
              ),
              const SizedBox(height: 30), // Beri jarak lebih di bawah tombol
            ],
          ),
        ),
      ),
    );
  }
}
