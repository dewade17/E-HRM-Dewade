import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_tukar_hari/pengajuan_tukar_hari.dart'
    as dto;
import 'package:e_hrm/utils/mention_parser.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ContentDetailIzinTukarHari extends StatelessWidget {
  final dto.Data data;

  const ContentDetailIzinTukarHari({super.key, required this.data});

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('dd MMMM yyyy', 'id_ID').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final totalHari = data.pairs.length;

    // --- Styles ---
    final headerStyle = GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.textDefaultColor,
    );
    final labelStyle = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade600,
    );
    final valueStyle = GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textDefaultColor,
    );
    final normalStyle = GoogleFonts.poppins(
      fontSize: 13,
      color: const Color(0xFF2D3748),
      height: 1.5,
    );

    final String handoverDesc = MentionParser.convertMarkupToDisplay(
      data.handover,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // === 1. KOTAK INFO HEADER ===
        Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kategori: ${data.kategori}", style: headerStyle),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "Total : $totalHari Pasang Hari",
                    style: valueStyle.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // === 2. DETAIL UMUM (Tanggal Buat & Keperluan) ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Diajukan pada:", style: labelStyle),
              Text(
                _fmtDate(data.createdAt),
                style: valueStyle.copyWith(color: AppColors.hintColor),
              ),
              const SizedBox(height: 12),
              Text("Keperluan:", style: labelStyle),
              Text(data.keperluan, style: normalStyle),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // === 3. HANDOVER SECTION (Dipisah agar rapi) ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.people_alt_outlined,
                    size: 18,
                    color: AppColors.secondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Handover Pekerjaan",
                    style: headerStyle.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // List User yang di-tag
                    if (data.handoverUsers.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: data.handoverUsers.map((ho) {
                          final user = ho.user;
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundImage: (user.fotoProfilUser.isNotEmpty)
                                  ? NetworkImage(user.fotoProfilUser)
                                  : null,
                              child: (user.fotoProfilUser.isEmpty)
                                  ? Text(
                                      user.namaPengguna.isNotEmpty
                                          ? user.namaPengguna[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(fontSize: 10),
                                    )
                                  : null,
                            ),
                            label: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user.namaPengguna,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  user.departement?.namaDepartement ?? '-',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.all(4),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                    ],
                    Text(handoverDesc, style: normalStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // === 4. LIST TANGGAL (PAIRS) ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.date_range_rounded,
                size: 18,
                color: AppColors.secondaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                "Rincian Tanggal Tukar",
                style: headerStyle.copyWith(color: AppColors.secondaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Render list pairs
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.pairs.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 12),
          itemBuilder: (ctx, index) {
            final pair = data.pairs[index];
            return _buildPairCard(pair, index + 1, labelStyle, valueStyle);
          },
        ),

        const SizedBox(height: 24),

        // === 5. BUKTI & APPROVAL ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bukti Pengajuan", style: headerStyle),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (data.lampiranIzinTukarHariUrl.isNotEmpty)
                    ? Image.network(
                        data.lampiranIzinTukarHariUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180,
                        errorBuilder: (ctx, err, stack) => _buildErrorImage(),
                      )
                    : _buildNoAttachment(),
              ),
              const SizedBox(height: 24),
              Text("Status Persetujuan", style: headerStyle),
              const SizedBox(height: 10),
              if (data.approvals.isEmpty)
                Text(
                  "Belum ada data persetujuan",
                  style: normalStyle.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Column(
                  children: data.approvals.map((approval) {
                    return _buildApprovalCard(approval);
                  }).toList(),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildPairCard(
    dto.Pair pair,
    int number,
    TextStyle labelStyle,
    TextStyle valueStyle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Pair
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Text(
              "Tukar Hari : $number",
              style: labelStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Kolom Hari Izin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.errorColor, // Merah untuk Izin
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text("Hari Izin", style: labelStyle),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmtDate(pair.hariIzin),
                        style: valueStyle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Ikon Panah
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                // Kolom Hari Pengganti
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Hari Pengganti", style: labelStyle),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.succesColor, // Hijau pengganti
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmtDate(pair.hariPengganti),
                        style: valueStyle.copyWith(fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(dto.Approval approval) {
    final decision = approval.decision.toLowerCase();
    bool isApproved = decision == 'approved' || decision == 'disetujui';
    bool isRejected = decision == 'rejected' || decision == 'ditolak';

    final Color bgColor = isApproved
        ? AppColors.succesColor
        : isRejected
        ? AppColors.errorColor
        : Colors.grey.shade200;

    final Color txtColor = (isApproved || isRejected)
        ? Colors.white
        : AppColors.textDefaultColor;

    final String displayLabel = (approval.approver != null)
        ? approval.approver!.namaPengguna
        : (approval.approverRole != null && approval.approverRole!.isNotEmpty)
        ? approval.approverRole!
        : "Approver";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.person, color: txtColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayLabel,
                    style: GoogleFonts.poppins(
                      color: txtColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (approval.note != null && approval.note!.isNotEmpty)
                    Text(
                      "Note: ${approval.note}",
                      style: GoogleFonts.poppins(
                        color: txtColor.withOpacity(0.9),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            if (approval.decidedAt != null)
              Text(
                _fmtDate(approval.decidedAt),
                style: GoogleFonts.poppins(color: txtColor, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      height: 180,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildNoAttachment() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Text(
        "Tidak ada lampiran",
        style: GoogleFonts.poppins(color: Colors.grey),
      ),
    );
  }
}
