// ignore_for_file: deprecated_member_use

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

enum _KunjunganStatusTab { berlangsung, selesai }

class _ContentDaftarKunjunganState extends State<ContentDaftarKunjungan> {
  bool _didFetchInitial = false;
  _KunjunganStatusTab _activeTab = _KunjunganStatusTab.berlangsung;

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
    if (_activeTab == _KunjunganStatusTab.berlangsung) {
      provider.setTanggalStatusBerlangsung(date);
    } else {
      provider.setTanggalStatusSelesai(date);
    }
  }

  void _switchStatus(_KunjunganStatusTab status) {
    if (_activeTab == status) return;
    setState(() {
      _activeTab = status;
    });
  }

  Widget _buildStatusContainer({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.hintColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textDefaultColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
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
                      child:
                          (item.lampiranKunjunganUrl != null &&
                              item.lampiranKunjunganUrl!.isNotEmpty)
                          ? Image.network(
                              item.lampiranKunjunganUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
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
                                        EndKunjunganScreen(item: item),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailKunjunganScreen(
                                      idKunjungan: item.idKunjungan,
                                      initialData: item,
                                    ),
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

    final isBerlangsungActive = _activeTab == _KunjunganStatusTab.berlangsung;
    final selectedDate = isBerlangsungActive
        ? kunjunganProvider.berlangsungTanggalFilter
        : kunjunganProvider.selesaiTanggalFilter;

    final activeItems = isBerlangsungActive ? berlangsungItems : selesaiItems;
    final activeLoading = isBerlangsungActive
        ? berlangsungLoading
        : selesaiLoading;
    final activeError = isBerlangsungActive ? berlangsungError : selesaiError;
    final emptyMessage = isBerlangsungActive
        ? 'Belum ada kunjungan berlangsung.'
        : 'Belum ada kunjungan selesai.';

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
                isSelected: isBerlangsungActive,
                onTap: () => _switchStatus(_KunjunganStatusTab.berlangsung),
              ),
              _buildStatusContainer(
                label: 'Selesai',
                isSelected: !isBerlangsungActive,
                onTap: () => _switchStatus(_KunjunganStatusTab.selesai),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (activeLoading)
            _buildLoadingState()
          else if (activeError != null)
            _buildErrorState(activeError)
          else if (activeItems.isEmpty)
            _buildEmptyState(emptyMessage)
          else ...[
            for (int i = 0; i < activeItems.length; i++) ...[
              _buildKunjunganCard(
                activeItems[i],
                isBerlangsung: isBerlangsungActive,
                kategoriProvider: kategoriProvider,
              ),
              if (i != activeItems.length - 1) const SizedBox(height: 20),
            ],
          ],
        ],
      ),
    );
  }
}
