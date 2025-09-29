// lib/screens/users/kunjungan_klien/create_kunjungan_klien/create_form_kunjungan.dart
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget/mark_me_map.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget/recipient_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateFormKunjungan extends StatefulWidget {
  const CreateFormKunjungan({super.key});

  @override
  State<CreateFormKunjungan> createState() => _CreateFormKunjunganState();
}

class _CreateFormKunjunganState extends State<CreateFormKunjungan> {
  final formKey = GlobalKey<FormState>();

  // Tetap gunakan controller agar nilai mudah diambil saat submit,
  // tapi TIDAK kita tampilkan sebagai TextField.
  final _latC = TextEditingController();
  final _lngC = TextEditingController();

  final deskripsiControllerkunjungan = TextEditingController();
  final calendarControllerkunjungan = TextEditingController();
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<KategoriKunjunganProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _latC.dispose();
    _lngC.dispose();
    deskripsiControllerkunjungan.dispose();
    super.dispose();
  }

  void _updateWordCount(String text) {
    setState(() {
      if (text.trim().isEmpty) {
        _wordCount = 0;
      } else {
        _wordCount = text.trim().split(RegExp(r'\s+')).length;
      }
    });
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    final kategoriProvider = context.read<KategoriKunjunganProvider>();
    final kunjunganProvider = context.read<KunjunganProvider>();
    final selectedKategori = kategoriProvider.selectedItem;
    if (selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori kunjungan belum dipilih.')),
      );
      return;
    }

    // Di titik ini, _latC.text dan _lngC.text sudah terisi oleh MarkMeMap.
    final lat = double.tryParse(_latC.text);
    final lng = double.tryParse(_lngC.text);
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koordinat tidak valid. Silakan tandai ulang.'),
        ),
      );
      return;
    }
    final deskripsi = deskripsiControllerkunjungan.text.trim();

    final now = DateTime.now();
    final tanggal = DateTime(now.year, now.month, now.day);

    final result = await kunjunganProvider.create({
      'id_master_data_kunjungan': selectedKategori.idMasterDataKunjungan,
      'deskripsi': deskripsi,
      'start_latitude': lat,
      'start_longitude': lng,
      'tanggal': tanggal,
      'jam_mulai': now,
      'jam_selesai': null,
    });

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunjungan berhasil dibuat.')),
      );
      Navigator.of(context).pop();
    } else {
      final message = kunjunganProvider.lastMessage ?? kunjunganProvider.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Gagal membuat kunjungan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kategoriProvider = context.watch<KategoriKunjunganProvider>();
    final kunjunganProvider = context.watch<KunjunganProvider>();
    final kategoriItems = kategoriProvider.items;
    final selectedKategoriId = kategoriProvider.selectedId;
    final kategoriLoading = kategoriProvider.isLoading && kategoriItems.isEmpty;
    final kategoriError = kategoriProvider.error;
    final isSaving = kunjunganProvider.isSaving;

    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Peta + tombol "mark me" (auto-isi _latC dan _lngC)
                MarkMeMap(
                  latitudeController: _latC,
                  longitudeController: _lngC,
                  autoFetchOnInit: false,
                  onPicked: (lat, lng) {
                    debugPrint('Koordinat terpilih: $lat, $lng');
                  },
                ),
                // FormField tersembunyi: hanya untuk validasi koordinat.
                // Tidak merender TextField—cuma akan menampilkan error text bila invalid.
                FormField<bool>(
                  validator: (_) {
                    if (_latC.text.isEmpty || _lngC.text.isEmpty) {
                      return 'Silakan tandai lokasi terlebih dulu.';
                    }
                    return null;
                  },
                  builder: (state) {
                    if (state.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          state.errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              child: Text(
                "Laporan Ke",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(10, 0, 10, 0),
            child: RecipientKunjungan(),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 330,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    ' Kategori Kunjungan',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: selectedKategoriId,
                      isExpanded: true,
                      items: kategoriItems
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.idMasterDataKunjungan,
                              child: Text(item.kategoriKunjungan),
                            ),
                          )
                          .toList(),
                      onChanged: kategoriLoading
                          ? null
                          : (value) {
                              kategoriProvider.setSelectedId(value);
                            },
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Icon(Icons.adf_scanner_sharp),
                        ),
                        hintText: kategoriLoading
                            ? 'Memuat layanan...'
                            : (kategoriItems.isEmpty
                                  ? 'Kategori belum tersedia'
                                  : 'Pilih Layanan'),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      validator: (value) {
                        if (kategoriLoading) return null;
                        if (value == null || value.isEmpty) {
                          if (kategoriItems.isEmpty) {
                            return 'Kategori kunjungan belum tersedia.';
                          }
                          return 'Silakan pilih layanan terlebih dulu.';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                if (kategoriError != null && kategoriItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Gagal memuat kategori kunjungan.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            kategoriProvider.refresh();
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Deskripsi pekerjaan (tetap tampil)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 360,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ' Deskripsi Kunjungan',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        controller: deskripsiControllerkunjungan,
                        maxLines: 3,
                        // onChaged tetap diperlukan untuk menghitung kata secara internal
                        onChanged: _updateWordCount,

                        // Decoration dikembalikan persis seperti kode asli Anda
                        decoration: const InputDecoration(
                          hintText: 'Tulis deskripsi...',
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Icon(Icons.comment),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        // Validator dengan logika pengecekan jumlah kata
                        validator: (v) {
                          // 1. Cek jika kosong
                          if (v == null || v.isEmpty) {
                            return 'Masukkan deskripsi';
                          }
                          // 2. Cek jika kurang dari 50 kata
                          if (_wordCount < 15) {
                            return 'Deskripsi harus minimal 50 kata. Saat ini: $_wordCount kata.';
                          }
                          // 3. Jika valid
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),
          GestureDetector(
            onTap: isSaving ? null : _submit,
            child: SizedBox(
              child: Card(
                color: AppColors.backgroundColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(
                          "Simpan Kunjungan",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDefaultColor,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }
}
