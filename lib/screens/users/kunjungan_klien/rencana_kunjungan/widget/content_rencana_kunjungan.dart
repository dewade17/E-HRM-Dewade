import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan_klien.dart';
import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/create_kunjungan/create_kunjungan_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/calendar_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  });

  final Data item;
  final String kategoriText;
  final String tanggalText;
  final String jamText;

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
                  onPressed: () {},
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
