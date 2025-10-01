import 'dart:io';

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan_klien.dart';
import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/create_kunjungan/create_kunjungan_screen.dart';
import 'package:e_hrm/screens/users/profile/widget/foto_profile.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/calendar_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentRencanaKunjungan extends StatefulWidget {
  const ContentRencanaKunjungan({super.key});

  @override
  State<ContentRencanaKunjungan> createState() =>
      _ContentRencanaKunjunganState();
}

class _ContentRencanaKunjunganState extends State<ContentRencanaKunjungan> {
  bool _didFetchInitial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didFetchInitial) return;
    _didFetchInitial = true;

    Future.microtask(() {
      if (!mounted) return;
      final kunjunganProvider = context.read<KunjunganKlienProvider>();
      final kategoriProvider = context.read<KategoriKunjunganProvider>();
      kunjunganProvider.refreshStatusDiproses();
      kategoriProvider.ensureLoaded();
    });
  }

  String _formatHeaderDate(KunjunganKlienProvider provider) {
    final filter = provider.diprosesTanggalFilter;
    DateTime? source = filter;
    if (source == null && provider.diprosesItems.isNotEmpty) {
      source = provider.diprosesItems.first.tanggal;
    }

    if (source == null) {
      return 'Belum ada jadwal kunjungan';
    }

    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(source);
  }

  String _resolveKategoriName(
    Data item,
    KategoriKunjunganProvider kategoriProvider,
  ) {
    final kategori = item.kategori?.kategoriKunjungan;
    if (kategori != null && kategori.isNotEmpty) {
      return kategori;
    }
    final relationId = item.idKategoriKunjungan ?? item.kategoriIdFromRelation;
    if (relationId == null) return '-';
    final found = kategoriProvider.itemById(relationId);
    return found?.kategoriKunjungan ?? '-';
  }

  String _formatTanggal(Data item) {
    final tanggal = item.tanggal;
    if (tanggal == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(tanggal);
  }

  String _formatJamRange(Data item) {
    final jamMulai = item.jamMulai;
    final jamSelesai = item.jamSelesai;
    final formatter = DateFormat('HH:mm', 'id_ID');

    final mulai = jamMulai != null ? formatter.format(jamMulai) : '--:--';
    final selesai = jamSelesai != null ? formatter.format(jamSelesai) : '--:--';
    return '$mulai - $selesai WITA';
  }

  Future<void> _handleStartKunjungan(Data item) async {
    final provider = context.read<KunjunganKlienProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _StartKunjunganSheet(item: item),
    );

    if (!mounted || result != true) return;

    final message = provider.saveMessage ?? 'Check-in kunjungan berhasil.';
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.accentColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kunjunganProvider = context.watch<KunjunganKlienProvider>();
    final kategoriProvider = context.watch<KategoriKunjunganProvider>();
    final isLoading = kunjunganProvider.diprosesLoading;
    final error = kunjunganProvider.diprosesError;
    final items = kunjunganProvider.diprosesItems;

    final headerText = _formatHeaderDate(kunjunganProvider);

    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: CalendarKunjungan(),
          ),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.textDefaultColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  color: Colors.black12,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.album_outlined,
                    color: AppColors.menuColor,
                    size: 12,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      headerText,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentColor,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  color: Colors.black12,
                ),
              ],
            ),
            child: Column(
              children: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  )
                else if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      error,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.errorColor,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (items.isEmpty)
                  Text(
                    "Rencana kunjungan kamu masih kosong, \nsilahkan masukkan jadwal kunjungan kamu",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.hintColor,
                      ),
                    ),
                  )
                else ...[
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RencanaKunjunganCard(
                        item: item,
                        kategoriText: _resolveKategoriName(
                          item,
                          kategoriProvider,
                        ),
                        tanggalText: _formatTanggal(item),
                        jamText: _formatJamRange(item),
                        onStart: () => _handleStartKunjungan(item),
                      ),
                    ),
                ],
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateKunjunganScreen(),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 240,
                    height: 50,
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_rounded),
                          const SizedBox(width: 10),
                          Text(
                            "Jadwalkan Kunjungan",
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RencanaKunjunganCard extends StatelessWidget {
  const _RencanaKunjunganCard({
    required this.item,
    required this.kategoriText,
    required this.tanggalText,
    required this.jamText,
    required this.onStart,
  });

  final Data item;
  final String kategoriText;
  final String tanggalText;
  final String jamText;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final deskripsi = item.deskripsi?.isNotEmpty == true
        ? item.deskripsi!
        : 'Tidak ada keterangan';

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border(
          top: BorderSide(color: AppColors.primaryColor, width: 1),
          left: BorderSide(color: AppColors.primaryColor, width: 5),
          right: BorderSide(color: AppColors.primaryColor, width: 1),
          bottom: BorderSide(color: AppColors.primaryColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                kategoriText,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDefaultColor,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.message),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    deskripsi,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorColor,
                    foregroundColor: AppColors.menuColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(),
                      child: Text(
                        "Mulai",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 10),
                Text(tanggalText),
                const SizedBox(width: 20),
                const Icon(Icons.access_time),
                Text(' $jamText'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartKunjunganSheet extends StatefulWidget {
  const _StartKunjunganSheet({required this.item});

  final Data item;

  @override
  State<_StartKunjunganSheet> createState() => _StartKunjunganSheetState();
}

class _StartKunjunganSheetState extends State<_StartKunjunganSheet> {
  File? _pickedFile;
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (_submitting) return;

    if (_pickedFile == null) {
      setState(() {
        _errorMessage = 'Harap lampirkan foto check-in terlebih dahulu.';
      });
      return;
    }

    final provider = context.read<KunjunganKlienProvider>();
    final navigator = Navigator.of(context);

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final position = await _obtainCurrentPosition();
      if (position == null) {
        setState(() => _submitting = false);
        return;
      }

      final lampiran = await http.MultipartFile.fromPath(
        'lampiran_kunjungan',
        _pickedFile!.path,
      );

      await provider.submitStartKunjungan(
        widget.item.idKunjungan,
        jamCheckin: DateTime.now(),
        startLatitude: position.latitude,
        startLongitude: position.longitude,
        lampiran: lampiran,
      );

      final error = provider.saveError;
      if (error != null) {
        setState(() {
          _errorMessage = error;
          _submitting = false;
        });
        return;
      }

      if (!mounted) return;
      navigator.pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _submitting = false;
      });
    }
  }

  Future<Position?> _obtainCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              'Location Services mati. Harap aktifkan untuk melanjutkan.';
        });
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Izin lokasi ditolak. Harap izinkan akses lokasi.';
        });
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkannya.';
        });
        return null;
      }

      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengambil lokasi: $e';
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomPadding + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Mulai Kunjungan',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FotoProfile(
            enabled: !_submitting,
            radius: 55,
            onPicked: (file) {
              setState(() {
                _pickedFile = file;
                _errorMessage = null;
              });
            },
            onRemove: () {
              setState(() {
                _pickedFile = null;
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Lampirkan foto sebagai bukti check-in. Lokasi & jam akan diambil otomatis.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.hintColor,
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.errorColor,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: AppColors.menuColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Mulai Sekarang',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.hintColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
