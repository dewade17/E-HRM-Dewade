// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/payment/payment.dart' as dto;
import 'package:e_hrm/providers/payment/payment_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentDetailPayment extends StatefulWidget {
  final String idPayment;
  final dto.Data? initialData;

  const ContentDetailPayment({
    super.key,
    required this.idPayment,
    this.initialData,
  });

  @override
  State<ContentDetailPayment> createState() => _ContentDetailPaymentState();
}

class _ContentDetailPaymentState extends State<ContentDetailPayment> {
  final DateFormat _dateFmt = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  final NumberFormat _rupiahFmt = NumberFormat.decimalPattern('id_ID');

  String _formatRupiah(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return raw.trim().isEmpty ? '-' : raw;
    final value = int.tryParse(digits);
    if (value == null) return raw.trim().isEmpty ? '-' : raw;
    return 'Rp ${_rupiahFmt.format(value)}';
  }

  String _statusLabel(String? status) {
    final s = (status ?? '').trim().toLowerCase();
    switch (s) {
      case 'pending':
      case 'menunggu':
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
        return (status ?? '').trim().isEmpty ? '-' : status!.trim();
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

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    if (text.isEmpty) return '-';
    if (text.toLowerCase() == 'null' || text.toLowerCase() == 'undefined') {
      return '-';
    }
    return text;
  }

  Widget _rowLabelValue({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              value.trim().isEmpty ? '-' : value.trim(),
              textAlign:
                  TextAlign.end, // Mengatur teks agar tetap rapi di sisi kanan
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemRow({required String name, required String harga}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              name.trim().isEmpty ? '-' : name.trim(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            _formatRupiah(harga),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        final dto.Data? providerDetail =
            provider.detail?.idPayment == widget.idPayment
            ? provider.detail
            : null;

        final dto.Data? data = providerDetail ?? widget.initialData;

        if (provider.detailLoading && data == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.detailError != null && data == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Text(
                  provider.detailError ?? 'Gagal memuat detail payment.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<PaymentProvider>().fetchDetail(
                        widget.idPayment,
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ),
              ],
            ),
          );
        }

        final tanggalText = data != null ? _dateFmt.format(data.tanggal) : '-';

        final kategori = (data?.kategoriKeperluan.namaKeperluan ?? '-').trim();
        final statusText = _statusLabel(data?.status);

        final keterangan = (data?.keterangan ?? '-').trim();
        final metode = (data?.metodePembayaran ?? '-').trim();

        final nomorRek = (data?.nomorRekening ?? '').trim();
        final pemilik = (data?.namaPemilikRekening ?? '').trim();
        final bank = (data?.jenisBank ?? '').trim();

        final nominal = (data?.nominalPembayaran ?? '-').trim();

        final approvals = data?.approvals ?? <dto.Approval>[];
        final statusApproved = _isApprovedStatus(data?.status);
        final statusRejected = _isRejectedStatus(data?.status);
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
            final url = approval.buktiApprovalPaymentUrl.trim();
            if (_isApprovedStatus(approval.decision) && url.isNotEmpty) {
              proofUrl = url;
              break;
            }
          }
          if (proofUrl.isEmpty) {
            for (final approval in approvals) {
              final url = approval.buktiApprovalPaymentUrl.trim();
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
                      kategori.isEmpty ? '-' : kategori,
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
            _rowLabelValue(label: "Keterangan", value: keterangan),
            const SizedBox(height: 10),
            _rowLabelValue(label: "Metode Pembayaran", value: metode),
            const SizedBox(height: 10),

            _rowLabelValue(
              label: "Nomor Rekening",
              value: nomorRek.isEmpty ? '-' : nomorRek,
            ),
            const SizedBox(height: 10),
            _rowLabelValue(
              label: "Nama Pemilik Rekening",
              value: pemilik.isEmpty ? '-' : pemilik,
            ),
            const SizedBox(height: 10),
            _rowLabelValue(
              label: "Nama Bank",
              value: bank.isEmpty ? '-' : bank,
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text("Detail Pengeluaran"),
            ),
            const SizedBox(height: 10),

            // Payment tidak punya list item, jadi kita tampilkan 1 baris nominal (layout tetap sama)
            _itemRow(name: "Nominal Pembayaran", harga: nominal),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: const Divider(thickness: 1, color: Colors.black87),
            ),

            _rowLabelValue(label: "Total", value: _formatRupiah(nominal)),

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
                          errorBuilder: (_, _, _) => Image.asset(
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
