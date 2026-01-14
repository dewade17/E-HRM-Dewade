// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pocket_money/pocket_money.dart' as dto;
import 'package:e_hrm/providers/pocket_money/pocket_money_provider.dart';
import 'package:e_hrm/screens/users/finance/pocket_money/detail_pocket_money/detail_pocket_money_screen.dart';
import 'package:e_hrm/screens/users/finance/pocket_money/riwayat_pocket_money/widget/calendar_riwayat_pocket_money.dart';
import 'package:e_hrm/shared_widget/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentRiwayatPocketMoney extends StatefulWidget {
  const ContentRiwayatPocketMoney({super.key});

  @override
  State<ContentRiwayatPocketMoney> createState() =>
      _ContentRiwayatPocketMoneyState();
}

class _ContentRiwayatPocketMoneyState extends State<ContentRiwayatPocketMoney> {
  static const int _perPage = 100;
  static const String _filterAllLabel = 'Semua';
  static const List<String> _itemsStatus = <String>[
    _filterAllLabel,
    'Menunggu',
    'Disetujui',
    'Ditolak',
  ];

  DateTime? _selectedDay;
  String _selectedValuekategori = _filterAllLabel;
  String _selectedValueStatus = _filterAllLabel;

  final DateFormat _headerDateFmt = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  final DateFormat _cardDateFmt = DateFormat('dd MMM yyyy', 'id_ID');
  final NumberFormat _rupiahFmt = NumberFormat.decimalPattern('id_ID');

  Future<void> _applyDateFilter(
    DateTime? day,
    PocketMoneyProvider provider,
  ) async {
    if (day == null) {
      setState(() => _selectedDay = null);
      provider.setFilters(tanggalFrom: null, tanggalTo: null, resetList: true);
      await provider.refresh(perPage: _perPage);
      return;
    }

    final normalized = DateTime(day.year, day.month, day.day);
    final current = _selectedDay == null
        ? null
        : DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

    // tap tanggal yang sama => clear filter
    if (current != null &&
        current.year == normalized.year &&
        current.month == normalized.month &&
        current.day == normalized.day) {
      setState(() => _selectedDay = null);
      provider.setFilters(tanggalFrom: null, tanggalTo: null, resetList: true);
      await provider.refresh(perPage: _perPage);
      return;
    }

    setState(() => _selectedDay = normalized);
    provider.setFilters(
      tanggalFrom: normalized,
      tanggalTo: normalized,
      resetList: true,
    );
    await provider.refresh(perPage: _perPage);
  }

  List<String> _buildKategoriItems(List<dto.Data> items) {
    final kategoriSet = <String>{};

    for (final item in items) {
      final name = item.kategoriKeperluan.namaKeperluan.trim();
      if (name.isNotEmpty) kategoriSet.add(name);
    }

    if (_selectedValuekategori != _filterAllLabel) {
      kategoriSet.add(_selectedValuekategori);
    }

    final kategoriList = kategoriSet.toList()..sort();
    return <String>[_filterAllLabel, ...kategoriList];
  }

  List<dto.Data> _filterItems(
    List<dto.Data> items, {
    required String kategori,
    required String status,
  }) {
    final normalizedKategori = kategori.trim().toLowerCase();
    final normalizedStatus = status.trim().toLowerCase();
    final normalizedAll = _filterAllLabel.toLowerCase();

    return items.where((item) {
      final kategoriName = item.kategoriKeperluan.namaKeperluan
          .trim()
          .toLowerCase();
      final statusLabel = _statusLabel(item.status).trim().toLowerCase();

      final matchKategori =
          normalizedKategori == normalizedAll ||
          kategoriName == normalizedKategori;
      final matchStatus =
          normalizedStatus == normalizedAll || statusLabel == normalizedStatus;

      return matchKategori && matchStatus;
    }).toList();
  }

  void _onFilterChanged({String? jenis, String? status}) {
    setState(() {
      if (jenis != null) _selectedValuekategori = jenis;
      if (status != null) _selectedValueStatus = status;
    });
  }

  String _formatRupiah(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return raw;
    final value = int.tryParse(digits);
    if (value == null) return raw;
    return 'Rp. ${_rupiahFmt.format(value)}';
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
        return status?.toString() ?? '-';
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

  Color _statusBg(String? status) {
    final s = (status ?? '').trim().toLowerCase();
    switch (s) {
      case 'disetujui':
      case 'approved':
      case 'approve':
        return const Color(0xFFE8F5E9);
      case 'ditolak':
      case 'rejected':
      case 'reject':
        return const Color(0xFFFFEBEE);
      case 'pending':
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  Future<void> _deleteItem(dto.Data item) async {
    final provider = context.read<PocketMoneyProvider>();
    final ok = await provider.deletePocketMoney(item.idPocketMoney);

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.deleteError ?? 'Gagal menghapus pocket money.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pocket money berhasil dihapus.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildCard(dto.Data data) {
    final title = (data.kategoriKeperluan.namaKeperluan).trim().isEmpty
        ? (data.keterangan.trim().isEmpty ? '-' : data.keterangan.trim())
        : data.kategoriKeperluan.namaKeperluan.trim();

    final tanggal = _cardDateFmt.format(data.tanggal);
    final statusText = _statusLabel(data.status);
    final isFinalStatus =
        _isApprovedStatus(data.status) || _isRejectedStatus(data.status);
    final total = _formatRupiah(data.totalPengeluaran);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border(
            left: const BorderSide(color: AppColors.primaryColor, width: 5),
            top: const BorderSide(color: AppColors.primaryColor, width: 1),
            right: const BorderSide(color: AppColors.primaryColor, width: 1),
            bottom: const BorderSide(color: AppColors.primaryColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isFinalStatus) const SizedBox(width: 8),
                if (!isFinalStatus)
                  Consumer<PocketMoneyProvider>(
                    builder: (context, provider, _) {
                      final deleting = provider.deleting;
                      return InkWell(
                        onTap: deleting
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ConfirmationDialog(
                                    title: "Hapus Pocket Money?",
                                    subtitle:
                                        "Pengajuan pocket money ini akan dihapus.",
                                    confirmText: "Ya, Hapus",
                                    onConfirm: () async {
                                      Navigator.pop(context);
                                      await _deleteItem(data);
                                    },
                                  ),
                                );
                              },
                        customBorder: const CircleBorder(),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          radius: 15,
                          child: deleting
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.delete,
                                  color: Colors.black54,
                                  size: 16,
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tanggal,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: _statusBg(data.status),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_money_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          total,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPocketMoneyScreen(
                          idPocketMoney: data.idPocketMoney,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Feedback Pocket Money",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PocketMoneyProvider>(
      builder: (context, provider, _) {
        final kategoriItems = _buildKategoriItems(provider.items);
        final selectedKategori = kategoriItems.contains(_selectedValuekategori)
            ? _selectedValuekategori
            : _filterAllLabel;
        final selectedStatus = _itemsStatus.contains(_selectedValueStatus)
            ? _selectedValueStatus
            : _filterAllLabel;

        final filteredItems = _filterItems(
          provider.items,
          kategori: selectedKategori,
          status: selectedStatus,
        );

        final markerDates = filteredItems
            .map(
              (e) => DateTime(e.tanggal.year, e.tanggal.month, e.tanggal.day),
            )
            .toSet()
            .toList();

        final headerText = _selectedDay == null
            ? "Semua Tanggal"
            : _headerDateFmt.format(_selectedDay!);

        return Column(
          children: [
            CalendarRiwayatPocketMoney(
              selectedDay: _selectedDay,
              markerDates: markerDates,
              onDaySelected: (day) => _applyDateFilter(day, provider),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kategori",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedKategori,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _onFilterChanged(jenis: newValue);
                                }
                              },
                              items: kategoriItems
                                  .map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedStatus,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _onFilterChanged(status: newValue);
                                }
                              },
                              items: _itemsStatus.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.poppins(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  headerText,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (provider.loading && provider.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              )
            else if (provider.error != null && provider.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  provider.error ?? 'Terjadi kesalahan.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else if (provider.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Belum ada pengajuan pocket money.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else if (filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Tidak ada pocket money sesuai filter.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final data = filteredItems[index];
                  return _buildCard(data);
                },
              ),
          ],
        );
      },
    );
  }
}
