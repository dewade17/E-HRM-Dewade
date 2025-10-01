import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan_klien.dart';
import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/detail_kunjungan_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/end_kunjungan/end_kunjungan_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/calendar_daftar_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentDaftarKunjungan extends StatefulWidget {
  const ContentDaftarKunjungan({super.key});

  @override
  State<ContentDaftarKunjungan> createState() => _ContentDaftarKunjunganState();
}

class _ContentDaftarKunjunganState extends State<ContentDaftarKunjungan> {
  bool _didFetchInitial = false;
  DateTime? _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didFetchInitial) return;
    _didFetchInitial = true;

    Future.microtask(() {
      if (!mounted) return;
      final kunjunganProvider = context.read<KunjunganKlienProvider>();
      final kategoriProvider = context.read<KategoriKunjunganProvider>();
      kunjunganProvider.refreshStatusBerlangsung();
      kunjunganProvider.refreshStatusSelesai();
      kategoriProvider.ensureLoaded();
    });
  }

  String _formatTanggal(Data item) {
    final tanggal = item.tanggal;
    if (tanggal == null) return '-';
    return DateFormat('d MMM yyyy', 'id_ID').format(tanggal);
  }

  String _formatJamRange(Data item) {
    final jamMulai = item.jamMulai;
    final jamSelesai = item.jamSelesai;
    final formatter = DateFormat('HH:mm', 'id_ID');

    final mulai = jamMulai != null ? formatter.format(jamMulai) : '--:--';
    final selesai = jamSelesai != null ? formatter.format(jamSelesai) : '--:--';
    return '$mulai - $selesai WITA';
  }

  String _resolveJudul(Data item, KategoriKunjunganProvider? kategoriProvider) {
    final kategori = item.kategori?.kategoriKunjungan;
    if (kategori != null && kategori.isNotEmpty) {
      return kategori;
    }
    final relationId = item.idKategoriKunjungan ?? item.kategoriIdFromRelation;
    if (relationId == null) {
      final deskripsi = item.deskripsi;
      return (deskripsi == null || deskripsi.isEmpty)
          ? 'Kunjungan Tanpa Judul'
          : deskripsi;
    }
    final found = kategoriProvider?.itemById(relationId);
    if (found != null && found.kategoriKunjungan.isNotEmpty) {
      return found.kategoriKunjungan;
    }
    final deskripsi = item.deskripsi;
    if (deskripsi != null && deskripsi.isNotEmpty) {
      return deskripsi;
    }
    return 'Kunjungan Tanpa Judul';
  }

  void _handleSelectDate(DateTime? date) {
    final provider = context.read<KunjunganKlienProvider>();
    setState(() {
      _selectedDate = date;
    });
    provider.setTanggalStatusBerlangsung(date);
    provider.setTanggalStatusSelesai(date);
  }

  Widget _buildStatusContainer({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 30,
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Center(child: Text(label)),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textDefaultColor,
          ),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.errorColor,
          ),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildKunjunganCard(
    Data item, {
    required bool isBerlangsung,
    required KategoriKunjunganProvider? kategoriProvider,
  }) {
    final judul = _resolveJudul(item, kategoriProvider);
    final tanggal = _formatTanggal(item);
    final jam = _formatJamRange(item);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.textColor,
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
              border: const Border(
                top: BorderSide(color: AppColors.primaryColor, width: 1),
                left: BorderSide(color: AppColors.primaryColor, width: 5),
                right: BorderSide(color: AppColors.primaryColor, width: 1),
                bottom: BorderSide(color: AppColors.primaryColor, width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      width: 100,
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          judul,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tanggal,
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textDefaultColor,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                jam,
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textDefaultColor,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              if (isBerlangsung) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EndKunjunganScreen(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DetailKunjunganScreen(),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              isBerlangsung
                                  ? 'Selesaikan Kunjungan'
                                  : 'Detail Kunjungan',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  color: isBerlangsung
                                      ? AppColors.errorColor
                                      : AppColors.textDefaultColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 25.0,
          child: Transform.translate(
            offset: const Offset(20, 0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isBerlangsung ? AppColors.hintColor : Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBerlangsung ? Icons.autorenew_rounded : Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final kunjunganProvider = context.watch<KunjunganKlienProvider>();
    final kategoriProvider = context.watch<KategoriKunjunganProvider>();

    final berlangsungItems = kunjunganProvider.berlangsungItems;
    final berlangsungLoading = kunjunganProvider.berlangsungLoading;
    final berlangsungError = kunjunganProvider.berlangsungError;

    final selesaiItems = kunjunganProvider.selesaiItems;
    final selesaiLoading = kunjunganProvider.selesaiLoading;
    final selesaiError = kunjunganProvider.selesaiError;

    final selectedDate =
        kunjunganProvider.berlangsungTanggalFilter ??
        kunjunganProvider.selesaiTanggalFilter ??
        _selectedDate;

    return Center(
      child: Column(
        children: [
          CalendarDaftarKunjungan(
            selectedDay: selectedDate,
            onDaySelected: _handleSelectDate,
          ),
          SizedBox(height: 20),
          Row(
            //dapat memilih melihat status selesai dan berlangsung
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusContainer(
                label: 'Berlangsung',
                onTap: () => _handleSelectDate(
                  kunjunganProvider.berlangsungTanggalFilter,
                ),
              ),
              _buildStatusContainer(
                label: 'Selesai',
                onTap: () =>
                    _handleSelectDate(kunjunganProvider.selesaiTanggalFilter),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (berlangsungLoading)
            _buildLoadingState()
          else if (berlangsungError != null)
            _buildErrorState(berlangsungError)
          else if (berlangsungItems.isEmpty)
            _buildEmptyState('Belum ada kunjungan berlangsung.')
          else ...[
            for (int i = 0; i < berlangsungItems.length; i++) ...[
              _buildKunjunganCard(
                berlangsungItems[i],
                isBerlangsung: true,
                kategoriProvider: kategoriProvider,
              ),
              if (i != berlangsungItems.length - 1) const SizedBox(height: 20),
            ],
          ],
          if (berlangsungItems.isNotEmpty || berlangsungLoading)
            const SizedBox(height: 20),
          if (selesaiLoading)
            _buildLoadingState()
          else if (selesaiError != null)
            _buildErrorState(selesaiError)
          else if (selesaiItems.isEmpty)
            _buildEmptyState('Belum ada kunjungan selesai.')
          else ...[
            for (int i = 0; i < selesaiItems.length; i++) ...[
              _buildKunjunganCard(
                selesaiItems[i],
                isBerlangsung: false,
                kategoriProvider: kategoriProvider,
              ),
              if (i != selesaiItems.length - 1) const SizedBox(height: 20),
            ],
          ],
        ],
      ),
    );
  }
}
