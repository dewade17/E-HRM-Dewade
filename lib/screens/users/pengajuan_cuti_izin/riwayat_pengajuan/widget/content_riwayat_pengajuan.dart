// ignore_for_file: deprecated_member_use
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as cuti;
import 'package:e_hrm/dto/pengajuan_izin_jam/pengajuan_izin_jam.dart'
    as izin_jam;
import 'package:e_hrm/dto/pengajuan_sakit/pengajuan_sakit.dart' as sakit;
import 'package:e_hrm/dto/pengajuan_tukar_hari/pengajuan_tukar_hari.dart'
    as tukar_hari;
import 'package:e_hrm/providers/riwayat_pengajuan/riwayat_pengajuan_provider.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_izin_tukar_hari/detail_pengajuan_izin_tukar_hari.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_pengajuan_cuti/detail_pengajuan_cuti.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_pengajuan_izin_jam/detail_pengajuan_izin_jam.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_pengajuan_sakit/detail_pengajuan_sakit.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/widget/calendar_riwayat_pengajuan.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_cuti/pengajuan_cuti_screen.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_jam/pengajuan_izin_jam_screen.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_sakit/pengajuan_izin_sakit_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentRiwayatPengajuan extends StatefulWidget {
  const ContentRiwayatPengajuan({super.key});

  @override
  State<ContentRiwayatPengajuan> createState() =>
      _ContentRiwayatPengajuanState();
}

class _ContentRiwayatPengajuanState extends State<ContentRiwayatPengajuan> {
  late final Map<
    RiwayatPengajuanType,
    Widget Function(RiwayatPengajuanItem item)
  >
  _detailRoutes;
  late final Map<
    RiwayatPengajuanType,
    Widget Function(RiwayatPengajuanItem item)
  >
  _editRoutes;
  final List<String> _itemsPengajuan = [
    'Semua',
    'Cuti',
    'Izin jam',
    'Sakit',
    'Tukar Hari',
  ];
  final List<String> _itemsStatus = [
    'Semua',
    'Menunggu',
    'Disetujui',
    'Ditolak',
  ];
  String? _selectedValuePengajuan;
  String? _selectedValueStatus;
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _detailRoutes = {
      RiwayatPengajuanType.cuti: (item) =>
          DetailPengajuanCuti(pengajuan: item.cutiData),
      RiwayatPengajuanType.izinJam: (item) =>
          DetailPengajuanIzinJam(pengajuan: item.izinJamData),
      RiwayatPengajuanType.tukarHari: (item) =>
          DetailPengajuanIzinTukarHari(pengajuan: item.tukarHariData),
      RiwayatPengajuanType.sakit: (item) =>
          DetailPengajuanSakit(pengajuan: item.sakitData),
    };

    _editRoutes = {
      RiwayatPengajuanType.cuti: (item) =>
          PengajuanCutiScreen(initialPengajuan: item.cutiData),
      RiwayatPengajuanType.izinJam: (item) =>
          PengajuanIzinJamScreen(initialPengajuan: item.izinJamData),
      RiwayatPengajuanType.tukarHari: (item) =>
          const PengajuanIzinTukarHariScreen(),
      RiwayatPengajuanType.sakit: (item) => const PengajuanIzinSakitScreen(),
    };
    _selectedValuePengajuan = _itemsPengajuan.first;
    _selectedValueStatus = _itemsStatus.first;
    _loadFuture = _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() {
    return context.read<RiwayatPengajuanProvider>().fetch(
      status: _selectedValueStatus,
      jenis: _selectedValuePengajuan,
    );
  }

  void _onFilterChanged({String? jenis, String? status}) {
    if (jenis != null) _selectedValuePengajuan = jenis;
    if (status != null) _selectedValueStatus = status;

    setState(() {
      _loadFuture = _fetchRiwayat();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('pending') || lower.contains('menunggu')) {
      return AppColors.primaryColor;
    }
    if (lower.contains('disetujui') || lower.contains('approve')) {
      return AppColors.succesColor;
    }
    if (lower.contains('ditolak') || lower.contains('reject')) {
      return AppColors.errorColor;
    }
    return AppColors.hintColor;
  }

  String _displayStatus(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('pending')) return 'Menunggu';
    if (lower.contains('disetujui')) return 'Disetujui';
    if (lower.contains('ditolak')) return 'Ditolak';
    return status;
  }

  void _openDetail(RiwayatPengajuanItem item) {
    final type = item.resolvedType;
    final builder = _detailRoutes[type];
    if (builder == null) return;

    Navigator.push(context, MaterialPageRoute(builder: (_) => builder(item)));
  }

  void _openEdit(RiwayatPengajuanItem item) {
    final type = item.resolvedType;
    final builder = _editRoutes[type];
    if (builder == null) return;

    Navigator.push(context, MaterialPageRoute(builder: (_) => builder(item)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarRiwayatPengajuan(),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],

                borderRadius: BorderRadius.circular(30.0),
              ),
              child: DropdownButton<String>(
                value: _selectedValuePengajuan,
                icon: const Icon(Icons.keyboard_arrow_down),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _onFilterChanged(jenis: newValue);
                  }
                },

                items: _itemsPengajuan.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],

                borderRadius: BorderRadius.circular(30.0),
              ),
              child: DropdownButton<String>(
                value: _selectedValueStatus,
                icon: const Icon(Icons.keyboard_arrow_down),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _onFilterChanged(status: newValue);
                  }
                },

                items: _itemsStatus.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            return Consumer<RiwayatPengajuanProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Column(
                    children: [
                      Text(
                        provider.error!,
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadFuture = _fetchRiwayat();
                          });
                        },
                        child: const Text('Muat ulang'),
                      ),
                    ],
                  );
                }

                if (provider.items.isEmpty) {
                  return Text(
                    'Belum ada riwayat pengajuan.',
                    style: GoogleFonts.poppins(
                      color: AppColors.textDefaultColor,
                    ),
                  );
                }

                return Column(
                  children: provider.items.map((item) {
                    final Color statusColor = _statusColor(item.status);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RiwayatItemCard(
                        title: item.displayJenis,
                        tanggalMulai:
                            'Mulai : ${_formatDate(item.tanggalMulai)}',
                        tanggalBerakhir:
                            'Berakhir : '
                            '${_formatDate(item.tanggalBerakhir ?? item.tanggalMulai)}',
                        statusText: _displayStatus(item.status),
                        statusBackgroundColor: statusColor.withOpacity(0.2),
                        borderColor: statusColor,
                        onEditPressed: () => _openEdit(item),
                        onDeletePressed: () {},
                        onDetailPressed: () => _openDetail(item),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Widget kustom untuk menampilkan satu item kartu pada daftar riwayat pengajuan.
class RiwayatItemCard extends StatelessWidget {
  final String title;
  final String tanggalMulai;
  final String tanggalBerakhir;
  final String statusText;
  final Color statusBackgroundColor;
  final Color borderColor;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onDetailPressed;

  const RiwayatItemCard({
    super.key,
    required this.title,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.statusText,
    required this.statusBackgroundColor,
    required this.borderColor,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Ini adalah kode Container Anda yang sudah dijadikan reusable
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
          left: BorderSide(color: borderColor, width: 5),
          right: BorderSide(color: borderColor, width: 1),
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Baris pertama (Judul dan Ikon Edit/Delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, // <-- Menggunakan parameter
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDefaultColor,
                ),
              ),

              // === PERUBAHAN DIMULAI DI SINI ===
              // Tampilkan tombol hanya jika status adalah "Menunggu"
              if (statusText == "Menunggu")
                Row(
                  children: [
                    // Membuat ikon bisa diklik
                    InkWell(
                      onTap: onEditPressed, // <-- Menggunakan parameter
                      customBorder: CircleBorder(),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.backgroundColor,
                        child: Icon(
                          Icons.edit,
                          color: AppColors.textColor,
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: onDeletePressed, // <-- Menggunakan parameter
                      customBorder: CircleBorder(),
                      child: CircleAvatar(
                        backgroundColor: AppColors.backgroundColor,
                        radius: 15,
                        child: Icon(
                          Icons.delete,
                          color: AppColors.textColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                )
              // Jika status BUKAN "Menunggu", tampilkan widget kosong
              else
                const SizedBox.shrink(),
              // === PERUBAHAN BERAKHIR DI SINI ===
            ],
          ),
          SizedBox(height: 20),

          // --- ROW KEDUA (MULAI) ---
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: 10),
                    Text(
                      tanggalMulai, // <-- Menggunakan parameter
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: statusBackgroundColor, // <-- Menggunakan parameter
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- ROW KETIGA (BERAKHIR) ---
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: 10),
                    Text(
                      tanggalBerakhir, // <-- Menggunakan parameter
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // Membuat teks "Detail" bisa diklik
              GestureDetector(
                onTap: onDetailPressed, // <-- Menggunakan parameter
                child: Text(
                  "Detail Pengajuan",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDefaultColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
