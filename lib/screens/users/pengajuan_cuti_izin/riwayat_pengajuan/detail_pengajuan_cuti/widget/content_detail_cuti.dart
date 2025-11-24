import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as dto;
import 'package:e_hrm/utils/mention_parser.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:intl/intl.dart';

class ContentDetailCuti extends StatefulWidget {
  final dto.Data data;

  const ContentDetailCuti({super.key, required this.data});

  @override
  State<ContentDetailCuti> createState() => _ContentDetailCutiState();
}

class _ContentDetailCutiState extends State<ContentDetailCuti> {
  final GlobalKey _mulaiKey = GlobalKey();
  double _mulaiBlockHeight = 40;

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

  String _fmtTime(DateTime? d) {
    if (d == null) return '';
    return DateFormat('HH:mm', 'id_ID').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    final int totalHari = data.tanggalList.isNotEmpty
        ? data.tanggalList.length
        : 1;

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

    const double gapAfterMulaiContent = 16;
    final double lineHeightBetweenSteps =
        _mulaiBlockHeight + gapAfterMulaiContent;

    final DateTime? tglMulai =
        data.tanggalCuti ??
        (data.tanggalList.isNotEmpty ? data.tanggalList.first : null);
    final DateTime? tglSelesai =
        data.tanggalSelesai ??
        (data.tanggalList.isNotEmpty ? data.tanggalList.last : null);

    final String handoverDescription = MentionParser.convertMarkupToDisplay(
      data.handover,
    );

    return Column(
      children: [
        const SizedBox(height: 20),
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
                "Kategori: ${data.kategoriCuti.namaKategori}",
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
        Padding(
          // UBAH DARI 0 MENJADI 20 AGAR SEJAJAR
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
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
        ),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          lineLength: lineHeightBetweenSteps,
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
                              height: lineHeightBetweenSteps,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            key: _mulaiKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("MULAI", style: labelStyle),
                                const SizedBox(height: 6),
                                Text(_fmtDate(tglMulai), style: dateStyle),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBF8FE),
                                    borderRadius: BorderRadius.circular(8),
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
                                          color: const Color(0xFF2C5282),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
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
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                    backgroundImage:
                                                        (user
                                                            .fotoProfilUser
                                                            .isNotEmpty)
                                                        ? NetworkImage(
                                                            user.fotoProfilUser,
                                                          )
                                                        : null,
                                                    child:
                                                        (user
                                                            .fotoProfilUser
                                                            .isEmpty)
                                                        ? Text(
                                                            user
                                                                    .namaPengguna
                                                                    .isNotEmpty
                                                                ? user.namaPengguna[0]
                                                                      .toUpperCase()
                                                                : '?',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          )
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          user.namaPengguna,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                        ),
                                                        Text(
                                                          user
                                                                  .departement
                                                                  ?.namaDepartement ??
                                                              '-',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 10,
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
                                        handoverDescription,
                                        style: normalStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: gapAfterMulaiContent),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("SELESAI", style: labelStyle),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  _fmtDate(tglSelesai),
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
                const SizedBox(height: 20),
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
                  child: (data.lampiranCutiUrl.isNotEmpty)
                      ? Image.network(
                          data.lampiranCutiUrl,
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
                          loadingBuilder: (ctx, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            );
                          },
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
                Text(
                  "Status Persetujuan",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDefaultColor,
                  ),
                ),
                const SizedBox(height: 10),
                if (data.approvals.isEmpty)
                  Text(
                    "Belum ada data persetujuan",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
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

                      final String displayLabel = (approval.approver != null)
                          ? approval.approver!.namaPengguna
                          : (approval.approverRole != null)
                          ? approval.approverRole!.name
                          : "Approver";

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
                                      displayLabel,
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
