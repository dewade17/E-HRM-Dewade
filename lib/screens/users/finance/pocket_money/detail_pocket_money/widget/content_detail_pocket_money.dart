import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pocket_money/pocket_money.dart' as dto;
import 'package:e_hrm/providers/pocket_money/pocket_money_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentDetailPocketMoney extends StatefulWidget {
  final String idPocketMoney;

  const ContentDetailPocketMoney({super.key, required this.idPocketMoney});

  @override
  State<ContentDetailPocketMoney> createState() =>
      _ContentDetailPocketMoneyState();
}

class _ContentDetailPocketMoneyState extends State<ContentDetailPocketMoney> {
  final DateFormat _dateFmt = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  final NumberFormat _rupiahFmt = NumberFormat.decimalPattern('id_ID');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PocketMoneyProvider>();
      final current = provider.detail;
      if (current == null || current.idPocketMoney != widget.idPocketMoney) {
        provider.fetchDetail(widget.idPocketMoney);
      }
    });
  }

  dto.Data? _pickData(PocketMoneyProvider provider) {
    final d = provider.detail;
    if (d != null && d.idPocketMoney == widget.idPocketMoney) return d;

    for (final it in provider.items) {
      if (it.idPocketMoney == widget.idPocketMoney) return it;
    }
    return null;
  }

  String _statusLabel(String? status) {
    final s = (status ?? '').trim().toLowerCase();
    switch (s) {
      case 'pending':
        return 'Menunggu';
      case 'disetujui':
      case 'approved':
      case 'approve':
        return 'Disetujui';
      case 'ditolak':
      case 'rejected':
      case 'reject':
        return 'Ditolak';
      default:
        return (status ?? '-').toString();
    }
  }

  bool _isApprovedStatus(String? status) {
    final s = (status ?? '').trim().toLowerCase();
    return s == 'disetujui' || s == 'approved' || s == 'approve';
  }

  bool _isRejectedStatus(String? status) {
    final s = (status ?? '').trim().toLowerCase();
    return s == 'ditolak' || s == 'rejected' || s == 'reject';
  }

  String _formatRupiah(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return raw;
    final value = int.tryParse(digits);
    if (value == null) return raw;
    return 'Rp ${_rupiahFmt.format(value)}';
  }

  String _safeText(dynamic v) {
    if (v == null) return '-';
    final s = v.toString().trim();
    if (s.isEmpty) return '-';
    if (s.toLowerCase() == 'null' || s.toLowerCase() == 'undefined') return '-';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PocketMoneyProvider>(
      builder: (context, provider, _) {
        final data = _pickData(provider);

        if (provider.detailLoading && data == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    'Memuat detail...',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.detailError != null && data == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: Text(
                provider.detailError ?? 'Gagal memuat detail pocket money.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (data == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: Text(
                'Data pocket money tidak ditemukan.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final tanggalText = _dateFmt.format(data.tanggal);
        final statusText = _statusLabel(data.status);
        final title = (data.kategoriKeperluan.namaKeperluan).trim().isNotEmpty
            ? data.kategoriKeperluan.namaKeperluan.trim()
            : (data.keterangan.trim().isNotEmpty
                  ? data.keterangan.trim()
                  : '-');
        final approvals = data.approvals;
        final statusApproved = _isApprovedStatus(data.status);
        final statusRejected = _isRejectedStatus(data.status);
        bool isRejected = statusRejected;
        bool isApproved = statusApproved;

        if (!statusApproved && !statusRejected) {
          isRejected = approvals.any(
            (approval) => _isRejectedStatus(approval.decision),
          );
          isApproved =
              !isRejected &&
              approvals.any((approval) => _isApprovedStatus(approval.decision));
        }

        final statusBackgroundColor = isApproved
            ? AppColors.succesColor
            : isRejected
            ? AppColors.errorColor
            : Colors.white;
        final statusBorderColor = isApproved
            ? AppColors.succesColor
            : isRejected
            ? AppColors.errorColor
            : Colors.grey.shade300;
        String proofUrl = '';
        String rejectionNote = '';

        if (isApproved) {
          for (final approval in approvals) {
            final url = approval.buktiApprovalPocketMoneyUrl.trim();
            if (_isApprovedStatus(approval.decision) && url.isNotEmpty) {
              proofUrl = url;
              break;
            }
          }
          if (proofUrl.isEmpty) {
            for (final approval in approvals) {
              final url = approval.buktiApprovalPocketMoneyUrl.trim();
              if (url.isNotEmpty) {
                proofUrl = url;
                break;
              }
            }
          }
        } else if (isRejected) {
          for (final approval in approvals) {
            if (_isRejectedStatus(approval.decision)) {
              rejectionNote = approval.note.trim();
              break;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  tanggalText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 350,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackgroundColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: statusBorderColor),
                      ),
                      child: Text(
                        "Status : $statusText",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isRejected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Note",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _safeText(rejectionNote),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Menjaga label tetap di atas jika teks panjang
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Keterangan",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Menggunakan Expanded agar teks tidak overflow ke samping
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      _safeText(data.keterangan),
                      textAlign: TextAlign.end, // Mengatur teks rata kanan
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Metode Pembayaran",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Menggunakan Expanded agar nama yang panjang bisa turun ke bawah (wrap)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      _safeText(data.metodePembayaran),
                      textAlign: TextAlign.end,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Nomor Rekening",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    _safeText(data.nomorRekening),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Nama Pemilik Rekening",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    _safeText(data.namaPemilikRekening),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Jenis Bank",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    _safeText(data.jenisBank),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text("Detail Pengeluaran"),
            ),
            const SizedBox(height: 10),

            if (data.items.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "-",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "-",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: data.items
                    .map((it) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                _safeText(it.namaItemPocketMoney),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                _formatRupiah(it.harga),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(growable: false),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: const Divider(thickness: 1, color: Colors.black87),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Total",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    _formatRupiah(data.totalPengeluaran),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            if (isApproved)
              proofUrl.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          proofUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'lib/assets/image/finance/empty.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  : Image.asset('lib/assets/image/finance/empty.png')
            else if (!isRejected)
              Image.asset('lib/assets/image/finance/empty.png'),
          ],
        );
      },
    );
  }
}
