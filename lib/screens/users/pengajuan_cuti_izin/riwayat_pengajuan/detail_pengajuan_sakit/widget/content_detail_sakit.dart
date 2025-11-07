import 'package:e_hrm/contraints/colors.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentDetailSakit extends StatefulWidget {
  const ContentDetailSakit({super.key});

  @override
  State<ContentDetailSakit> createState() => _ContentDetailSakitState();
}

class _ContentDetailSakitState extends State<ContentDetailSakit> {
  // Key untuk mengukur tinggi blok konten step "MULAI"
  final GlobalKey _mulaiKey = GlobalKey();
  double _mulaiBlockHeight = 40; // default fallback

  @override
  void initState() {
    super.initState();
    // Hitung tinggi konten setelah first frame dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TAMBAHKAN DELAY SINGKAT:
      // Beri waktu 50ms agar semua child widget (Wrap, RichText)
      // di dalam _mulaiKey selesai di-layout dengan stabil.
      Future.delayed(const Duration(milliseconds: 50), () {
        // Cek 'mounted' LAGI setelah delay, karena widget bisa saja
        // sudah di-dispose selagi menunggu.
        if (!mounted) return;

        final ctx = _mulaiKey.currentContext;
        if (ctx != null) {
          final size = ctx.size;
          if (size != null && size.height > 0) {
            // Cek apakah tingginya benar-benar berubah sebelum setState
            // untuk menghindari build loop yang tidak perlu.
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

  @override
  Widget build(BuildContext context) {
    // Styles lokal yang dipakai berulang
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
    final mentionStyle = GoogleFonts.poppins(
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w600,
    );
    final normalStyle = GoogleFonts.poppins(
      fontSize: 13,
      color: const Color(0xFF2D3748),
      height: 1.5,
    );

    // Spasi kecil antar konten step dan garis
    const double _gapAfterMulaiContent = 16;
    final double _lineHeightBetweenSteps =
        _mulaiBlockHeight + _gapAfterMulaiContent;

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
                "Kategori: Demam",
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
        ),
        const SizedBox(height: 10),
        // Tanggal Pengajuan
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "07 September 2025, 09:00",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.hintColor,
              ),
            ),
          ),
        ),

        // === KOTAK DETAIL PUTIH (Timeline, Bukti, Approver) ===
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
                // === TIMELINE: EasyStepper (VERTIKAL) + Konten di kanan ===
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wajib dalam Row saat vertical (sesuai dokumentasi)
                    // Stepper hanya menampilkan icon & garis; label+konten kita letakkan di sisi kanan.
                    SizedBox(
                      width: 36, // lebar kolom untuk stepper
                      child: EasyStepper(
                        activeStep: 1, // step "SELESAI" dianggap aktif
                        direction: Axis.vertical,
                        showTitle: false,
                        internalPadding: 0,
                        stepRadius: 10,
                        borderThickness: 0.8,
                        // Warna & ukuran garis antar step
                        lineStyle: LineStyle(
                          lineType: LineType.normal,
                          lineThickness: 2,
                          defaultLineColor: AppColors.errorColor,
                          finishedLineColor: AppColors.errorColor,
                          activeLineColor: AppColors.errorColor,
                          lineLength:
                              _lineHeightBetweenSteps, // disamakan dengan tinggi konten "MULAI"
                        ),
                        steps: [
                          // Step 0 - MULAI
                          EasyStep(
                            icon: const Icon(
                              Icons.check_circle,
                              color: AppColors.errorColor,
                              size: 20,
                            ),
                            // Untuk memastikan garis match tinggi konten "MULAI", override dengan customLineWidget
                            customLineWidget: Container(
                              width: 2,
                              height: _lineHeightBetweenSteps,
                              color: AppColors.errorColor,
                            ),
                          ),
                          // Step 1 - SELESAI
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

                    // Konten tiap step
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Konten untuk "MULAI" ---
                          Container(
                            key: _mulaiKey,
                            // top label "MULAI" dan tanggal + box handover
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("MULAI", style: labelStyle),
                                const SizedBox(height: 6),
                                Text("07 September 2025", style: dateStyle),
                                const SizedBox(height: 8),

                                // Handover Box (biru)
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

                                      // Chip Mention
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          // Chip 1
                                          Container(
                                            padding: const EdgeInsets.symmetric(
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
                                                  child: Text(
                                                    "M",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Manik Mahardika",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    ),
                                                    Text(
                                                      "Content 1",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Chip 2
                                          Container(
                                            padding: const EdgeInsets.symmetric(
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
                                                  child: Text(
                                                    "P",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Putri Indah",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    ),
                                                    Text(
                                                      "Direktur",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Deskripsi Handover
                                      RichText(
                                        text: TextSpan(
                                          style: normalStyle,
                                          children: [
                                            const TextSpan(
                                              text: "handover piket ke ",
                                            ),
                                            TextSpan(
                                              text: "@Ngurah Manik Mahardika",
                                              style: mentionStyle,
                                            ),
                                            const TextSpan(text: " mebantos "),
                                            const TextSpan(
                                              text:
                                                  "titen, handover tim checking ke ",
                                            ),
                                            TextSpan(
                                              text: "@PutriIndah",
                                              style: mentionStyle,
                                            ),
                                            const TextSpan(
                                              text:
                                                  " kemudian di pass ke tim rekrutmen ya, sisa pekerjaan seperti email akan di respon hari berikutnya dan recruitment sudah selesai sehari sebelum tanggal due date",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: _gapAfterMulaiContent),

                          // --- Konten untuk "SELESAI" ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("SELESAI", style: labelStyle),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  "08 September 2025",
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
                  child: Image.asset(
                    'lib/assets/image/menu_home/kunjungan.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
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

                // Chip Approver 1 (disetujui)
                Builder(
                  builder: (context) {
                    final isApproved = true; // "disetujui"
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: textColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Ayu HR",
                                style: GoogleFonts.poppins(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Chip Approver 2 (menunggu)
                Builder(
                  builder: (context) {
                    final isApproved = false; // "menunggu"
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: textColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Mesy",
                                style: GoogleFonts.poppins(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Chip Approver 3 (menunggu)
                Builder(
                  builder: (context) {
                    final isApproved = false; // "menunggu"
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: textColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Putu Astina",
                                style: GoogleFonts.poppins(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
