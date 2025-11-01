// lib/screens/users/pengajuan_cuti_izin.dart/riwayat_pengajuan/detail_pengajuan_cuti/widget/content_detail_cuti.dart

// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentDetailCuti extends StatelessWidget {
  /// Ini adalah widget UI statis yang dibuat berdasarkan gambar referensi.
  /// Tidak ada model data yang diperlukan.
  const ContentDetailCuti({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // --- KOTAK INFO BIRU ---
        _buildTopInfoBox(context),
        const SizedBox(height: 20),
        // --- KOTAK DETAIL PUTIH ---
        _buildMainDetailsBox(context),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Membangun kotak info biru di bagian atas (Kategori & Durasi)
  Widget _buildTopInfoBox(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kategori: Demam",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDefaultColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.textColor, // Latar belakang putih
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              "Total : 1 Hari",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDefaultColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun kotak detail putih (Timeline, Bukti, Approver)
  Widget _buildMainDetailsBox(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: AppColors.textColor.withOpacity(0.9),
        border: Border.all(color: AppColors.secondaryColor.withOpacity(0.5)),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanggal Pengajuan
            Text(
              "07 September 2025, 09:00",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // --- TIMELINE KUSTOM BARU ---
            _buildCustomTimeline(context),
            const SizedBox(height: 20),

            // --- Bukti Pengajuan ---
            Text(
              "Bukti Pengajuan",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDefaultColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildBuktiImage(context),
            const SizedBox(height: 20),

            // --- Status Persetujuan ---
            Text(
              "Status Persetujuan",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDefaultColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildApproverList(context),
          ],
        ),
      ),
    );
  }

  /// Membangun timeline kustom untuk Mulai dan Selesai
  Widget _buildCustomTimeline(BuildContext context) {
    final dateStyle = GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textDefaultColor,
    );
    final labelStyle = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Baris MULAI ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom Ikon
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("MULAI", style: labelStyle),
                const SizedBox(height: 2),
                const Icon(Icons.check_circle, color: AppColors.errorColor),
              ],
            ),
            const SizedBox(width: 12),
            // Kolom Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("07 September 2025", style: dateStyle),
                  const SizedBox(height: 8),
                  _buildHandoverBox(context),
                ],
              ),
            ),
          ],
        ),

        // --- Garis Vertikal ---
        Padding(
          padding: const EdgeInsets.only(
            left:
                11, // Setengah dari lebar ikon (24 / 2) - setengah lebar garis (2 / 2)
            top: 4,
            bottom: 4,
          ),
          child: Container(
            height: 40, // Tinggi garis antar step
            width: 2,
            color: AppColors.errorColor,
          ),
        ),

        // --- Baris SELESAI ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom Ikon
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppColors.errorColor),
                const SizedBox(height: 2),
                Text("SELESAI", style: labelStyle),
              ],
            ),
            const SizedBox(width: 12),
            // Kolom Konten
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0), // Meluruskan teks
                child: Text("08 September 2025", style: dateStyle),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Membangun kotak biru untuk detail handover
  Widget _buildHandoverBox(BuildContext context) {
    // Teks deskripsi dengan styling mention
    final mentionStyle = GoogleFonts.poppins(
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w600,
    );
    final normalStyle = GoogleFonts.poppins(
      fontSize: 13,
      color: const Color(0xFF2D3748), // Teks abu-abu tua
      height: 1.5,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF8FE), // Biru muda
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBEE3F8)), // Border biru
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Handover Pekerjaan:",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C5282), // Biru tua
            ),
          ),
          const SizedBox(height: 8),

          // --- Chip Mention ---
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMentionChip(context, "Manik Mahardika", "Content 1"),
              _buildMentionChip(context, "Putri Indah", "Direktur"),
            ],
          ),

          // --- Deskripsi Handover ---
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: normalStyle,
              children: [
                const TextSpan(text: "handover piket ke "),
                TextSpan(text: "@Ngurah Manik Mahardika", style: mentionStyle),
                const TextSpan(text: " mebantos "),
                TextSpan(text: "titen, handover tim checking ke "),
                TextSpan(text: "@PutriIndah", style: mentionStyle),
                const TextSpan(
                  text:
                      " kemudian di pass ke tim rekrutmen ya, sisa pekerjaan seperti email akan di respon hari berikutnya dan recruitment sudah selesai sehari sebelum tanggal due date",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk chip mention di dalam handover box
  Widget _buildMentionChip(BuildContext context, String name, String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                role,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper untuk menampilkan gambar bukti
  Widget _buildBuktiImage(BuildContext context) {
    // Gunakan placeholder atau gambar aset yang ada
    // 'lib/assets/image/menu_home/kunjungan.png' adalah aset yang ada
    // yang menampilkan sekelompok orang, mirip dengan gambar referensi.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'lib/assets/image/menu_home/kunjungan.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180, // Beri tinggi agar tidak terlalu besar
        // Jika Anda ingin placeholder:
        // child: Container(
        //   height: 180,
        //   width: double.infinity,
        //   color: Colors.grey.shade200,
        //   alignment: Alignment.center,
        //   child: const Icon(Icons.image, size: 50, color: Colors.grey),
        // ),
      ),
    );
  }

  /// Helper untuk membangun daftar status approver
  Widget _buildApproverList(BuildContext context) {
    return Column(
      children: [
        _buildApproverChip(context, name: "Ayu HR", status: "disetujui"),
        _buildApproverChip(context, name: "Mesy", status: "menunggu"),
        _buildApproverChip(context, name: "Putu Astina", status: "menunggu"),
      ],
    );
  }

  /// Helper untuk chip status approver (hijau/abu-abu)
  Widget _buildApproverChip(
    BuildContext context, {
    required String name,
    required String status,
  }) {
    final statusLC = status.toLowerCase();
    final isApproved = statusLC == 'approved' || statusLC == 'disetujui';

    final Color backgroundColor = isApproved
        ? AppColors.succesColor
        : Colors.grey.shade200;
    final Color textColor = isApproved
        ? Colors.white
        : AppColors.textDefaultColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.person, color: textColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            Column()
          ],
        ),
      ),
    );
  }
}
