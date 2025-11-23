// lib/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/detail_izin_tukar_hari/widget/content_detail_izin_tukar_hari.dart

// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_tukar_hari/pengajuan_tukar_hari.dart'
    as dto;
import 'package:e_hrm/utils/mention_parser.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ContentDetailIzinTukarHari extends StatefulWidget {
  final dto.Data data;

  const ContentDetailIzinTukarHari({super.key, required this.data});

  @override
  State<ContentDetailIzinTukarHari> createState() =>
      _ContentDetailIzinTukarHariState();
}

class _ContentDetailIzinTukarHariState
    extends State<ContentDetailIzinTukarHari> {
  // Key untuk mengukur tinggi blok konten step "MULAI" (yang berisi Handover)
  final GlobalKey _mulaiKey = GlobalKey();
  double _mulaiBlockHeight = 40; // default fallback untuk item pertama

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        final ctx = _mulaiKey.currentContext;
        if (ctx != null) {
          final size = ctx.size;
          if (size != null && size.height > 0) {
            if ((_mulaiBlockHeight - size.height).abs() > 0.1) {
              setState(() {
                _mulaiBlockHeight = size.height;
              });
            }
          }
        }
      });
    });
  }

  String _fmtDate(DateTime? d, {String pattern = 'dd MMMM yyyy'}) {
    if (d == null) return '-';
    return DateFormat(pattern, 'id_ID').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final totalHari = data.pairs.length;

    // Styles
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
    final normalStyle = GoogleFonts.poppins(
      fontSize: 13,
      color: const Color(0xFF2D3748),
      height: 1.5,
    );

    // Spasi kecil antar konten step dan garis
    const double gapAfterMulaiContent = 16;
    // Tinggi garis untuk item pertama (yang ada handovernya)
    final double lineHeightFirst = _mulaiBlockHeight + gapAfterMulaiContent;
    // Tinggi garis untuk item selanjutnya (hanya tanggal, tanpa handover)
    const double lineHeightStandard = 50.0;

    final String handoverDesc = MentionParser.convertMarkupToDisplay(
      data.handover,
    );

    return Column(
      children: [
        const SizedBox(height: 20),

        // === KOTAK INFO BIRU (Kategori & Durasi) ===
        Container(
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
                "Kategori: ${data.kategori}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDefaultColor,
                ),
              ),
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
                  "Total : $totalHari Hari",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDefaultColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Tanggal Pengajuan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _fmtDate(data.createdAt, pattern: 'dd MMMM yyyy, HH:mm'),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.hintColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Keperluan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Keperluan :",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
              Text(
                data.keperluan,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ],
          ),
        ),

        // === KOTAK DETAIL PUTIH ===
        Container(
          width: 350,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === TIMELINE: Render semua Pairs ===
                // Loop untuk setiap pasangan tanggal tukar hari
                ...data.pairs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pair = entry.value;
                  final isFirst = index == 0;

                  // Gunakan tinggi dinamis hanya untuk item pertama yang memiliki HandoverBox
                  final double currentLineLength = isFirst
                      ? lineHeightFirst
                      : lineHeightStandard;

                  return Column(
                    children: [
                      if (index > 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(),
                        ), // Divider pemisah antar pair
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stepper
                          SizedBox(
                            width: 36,
                            child: EasyStepper(
                              activeStep: 1,
                              direction: Axis.vertical,
                              showTitle: false,
                              internalPadding: 0,
                              stepRadius: 10,
                              borderThickness: 0.8,
                              lineStyle: LineStyle(
                                lineType: LineType.normal,
                                lineThickness: 2,
                                defaultLineColor: AppColors.errorColor,
                                finishedLineColor: AppColors.errorColor,
                                activeLineColor: AppColors.errorColor,
                                lineLength: currentLineLength,
                              ),
                              steps: [
                                EasyStep(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: AppColors.errorColor,
                                    size: 20,
                                  ),
                                  customLineWidget: Container(
                                    width: 2,
                                    height: currentLineLength,
                                    color: AppColors.errorColor,
                                  ),
                                ),
                                const EasyStep(
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: AppColors.errorColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Konten
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- Bagian "Hari Izin" (Start) ---
                                Container(
                                  // Pasang key hanya pada item pertama untuk pengukuran HandoverBox
                                  key: isFirst ? _mulaiKey : null,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hari Izin ${index > 0 ? '(${index + 1})' : ''}",
                                        style: labelStyle,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _fmtDate(pair.hariIzin),
                                        style: dateStyle,
                                      ),
                                      const SizedBox(height: 8),

                                      // Handover Box (Hanya muncul di item pertama)
                                      if (isFirst)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEBF8FE),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFBEE3F8),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Handover Pekerjaan:",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(
                                                    0xFF2C5282,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),

                                              // Chip Mention
                                              if (data.handoverUsers.isNotEmpty)
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: data.handoverUsers.map((
                                                    ho,
                                                  ) {
                                                    final user = ho.user;
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .grey
                                                              .shade300,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 12,
                                                            backgroundColor:
                                                                Colors
                                                                    .grey
                                                                    .shade200,
                                                            backgroundImage:
                                                                user
                                                                    .fotoProfilUser
                                                                    .isNotEmpty
                                                                ? NetworkImage(
                                                                    user.fotoProfilUser,
                                                                  )
                                                                : null,
                                                            child:
                                                                user
                                                                    .fotoProfilUser
                                                                    .isEmpty
                                                                ? Text(
                                                                    user.namaPengguna.isNotEmpty
                                                                        ? user.namaPengguna[0]
                                                                              .toUpperCase()
                                                                        : '?',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  )
                                                                : null,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          // === PERBAIKAN DI SINI: Gunakan Flexible ===
                                                          Flexible(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  user.namaPengguna,
                                                                  maxLines:
                                                                      1, // Tambahan
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis, // Tambahan
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  user.role,
                                                                  maxLines:
                                                                      1, // Tambahan
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis, // Tambahan
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .black54,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),

                                              if (data.handoverUsers.isNotEmpty)
                                                const SizedBox(height: 8),

                                              Text(
                                                handoverDesc,
                                                style: normalStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: isFirst ? gapAfterMulaiContent : 20,
                                ), // Jarak sebelum "Selesai"
                                // --- Bagian "Hari Pengganti" (End) ---
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Hari Pengganti", style: labelStyle),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        _fmtDate(pair.hariPengganti),
                                        style: dateStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 20),

                // === Bukti Pengajuan ===
                Text(
                  "Bukti Pengajuan",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDefaultColor,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (data.lampiranIzinTukarHariUrl.isNotEmpty)
                      ? Image.network(
                          data.lampiranIzinTukarHariUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Text(
                            "Tidak ada lampiran",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // === Status Persetujuan ===
                Text(
                  "Status Persetujuan",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDefaultColor,
                  ),
                ),
                const SizedBox(height: 10),

                // List Approval Dinamis
                if (data.approvals.isEmpty)
                  Text(
                    "Belum ada data persetujuan",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Column(
                    children: data.approvals.map((approval) {
                      final decision = approval.decision.toLowerCase();
                      bool isApproved =
                          decision == 'approved' || decision == 'disetujui';
                      bool isRejected =
                          decision == 'rejected' || decision == 'ditolak';

                      final Color backgroundColor = isApproved
                          ? AppColors.succesColor
                          : isRejected
                          ? AppColors.errorColor
                          : Colors.grey.shade200;
                      final Color textColor = (isApproved || isRejected)
                          ? Colors.white
                          : AppColors.textDefaultColor;

                      final roleName = approval.approverRole ?? 'Approver';

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: textColor, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      roleName,
                                      style: GoogleFonts.poppins(
                                        color: textColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (approval.note != null &&
                                        approval.note!.isNotEmpty)
                                      Text(
                                        "Note: ${approval.note}",
                                        style: GoogleFonts.poppins(
                                          color: textColor.withOpacity(0.9),
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (approval.decidedAt != null)
                                Text(
                                  _fmtDate(
                                    approval.decidedAt,
                                    pattern: 'dd/MM',
                                  ),
                                  style: GoogleFonts.poppins(
                                    color: textColor,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
