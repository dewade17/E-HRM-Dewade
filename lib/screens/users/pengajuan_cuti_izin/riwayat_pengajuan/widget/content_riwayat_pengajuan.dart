// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_pengajuan_cuti/detail_pengajuan_cuti.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/widget/calendar_riwayat_pengajuan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentRiwayatPengajuan extends StatefulWidget {
  const ContentRiwayatPengajuan({super.key});

  @override
  State<ContentRiwayatPengajuan> createState() =>
      _ContentRiwayatPengajuanState();
}

class _ContentRiwayatPengajuanState extends State<ContentRiwayatPengajuan> {
  final List<String> _itemsPengajuan = [
    'Cuti',
    'Izin jam',
    'Sakit',
    'Tukar Hari',
  ];
  final List<String> _itemsStatus = ['Menunggu', 'Disetujui', 'Ditolak'];
  String? _selectedValuePengajuan;
  String? _selectedValueStatus;
  @override
  void initState() {
    super.initState();
    _selectedValuePengajuan = _itemsPengajuan.first;
    _selectedValueStatus = _itemsStatus.first;
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
                  setState(() {
                    _selectedValuePengajuan = newValue;
                  });
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
                  setState(() {
                    _selectedValueStatus = newValue;
                  });
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
        RiwayatItemCard(
          title: "Cuti",
          tanggalMulai: "Mulai : 10 Oktober 2025",
          tanggalBerakhir: "Berakhir : 10 Oktober 2025",
          statusText: "Menunggu",
          statusBackgroundColor: AppColors.hintColor.withOpacity(0.2),
          borderColor: AppColors.primaryColor, // Warna border "Menunggu"
          onEditPressed: () {},
          onDeletePressed: () {},
          onDetailPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailPengajuanCuti()),
            );
          },
        ),
        SizedBox(height: 12),
        RiwayatItemCard(
          title: "Izin Tukar Hari",
          tanggalMulai: "Mulai : 10 Oktober 2025",
          tanggalBerakhir: "Berakhir : 10 Oktober 2025",
          statusText: "Menunggu",
          statusBackgroundColor: AppColors.hintColor.withOpacity(0.2),
          borderColor: AppColors.primaryColor, // Warna border "Menunggu"
          onEditPressed: () {},
          onDeletePressed: () {},
          onDetailPressed: () {},
        ),

        SizedBox(height: 12), // Jarak antar kartu

        RiwayatItemCard(
          title: "Izin Jam",
          tanggalMulai: "Mulai : 09 Oktober 2025",
          tanggalBerakhir: "Berakhir : 09 Oktober 2025",
          statusText: "Disetujui",
          statusBackgroundColor: AppColors.succesColor.withOpacity(0.2),
          borderColor: AppColors.succesColor, // Warna border "Disetujui"
          onEditPressed: () {},
          onDeletePressed: () {},
          onDetailPressed: () {},
        ),

        SizedBox(height: 12), // Jarak antar kartu
        // 3. Contoh Status "Ditolak"
        RiwayatItemCard(
          title: "Sakit",
          tanggalMulai: "Mulai : 08 Oktober 2025",
          tanggalBerakhir: "Berakhir : 08 Oktober 2025",
          statusText: "Ditolak",
          statusBackgroundColor: AppColors.errorColor.withOpacity(0.2),
          borderColor: AppColors.errorColor, // Warna border "Ditolak"
          onEditPressed: () {},
          onDeletePressed: () {},
          onDetailPressed: () {},
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
