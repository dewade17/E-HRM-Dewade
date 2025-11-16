// Lokasi: lib/shared_widget/kategori_izin_jam_selection_field.dart

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/pengajuan_izin_jam/kategori_izin_jam.dart' as dto;
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_jam/widget/kategori_izin_jam_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget FormField khusus untuk memilih Kategori Izin Jam.
/// Dibuat berdasarkan referensi KategoriCutiSelectionField.
class KategoriIzinJamSelectionField extends StatelessWidget {
  const KategoriIzinJamSelectionField({
    super.key,
    required this.label,
    this.selectedKategori, // Menerima objek dto.Data
    required this.onKategoriSelected, // Callback mengembalikan dto.Data
    this.hintText = 'Pilih kategori izin jam...',
    this.prefixIcon = Icons.category_outlined, // Mengganti ikon
    this.isRequired = false,
    this.validator, // Validator menerima dto.Data?
    this.autovalidateMode,
    this.width = 350,
    this.elevation = 3,
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  final String label;
  final dto.Data? selectedKategori;
  final ValueChanged<dto.Data?> onKategoriSelected;
  final String hintText;
  final IconData? prefixIcon;
  final bool isRequired;
  final FormFieldValidator<dto.Data>? validator;
  final AutovalidateMode? autovalidateMode;
  final double? width;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final baseLabelStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDefaultColor,
      ),
    );

    // Tampilkan nama kategori jika ada
    final String displayText = selectedKategori?.namaKategori ?? '';
    final bool hasSelection = selectedKategori != null;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text.rich(
            TextSpan(
              children: [
                if (isRequired)
                  TextSpan(
                    text: '* ',
                    style: baseLabelStyle.copyWith(color: AppColors.errorColor),
                  ),
                TextSpan(text: label, style: baseLabelStyle),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // FormField untuk validasi
          FormField<dto.Data>(
            builder: (FormFieldState<dto.Data> state) {
              final BorderSide errorBorder = const BorderSide(
                color: Colors.red,
                width: 1.0,
              );

              final BorderSide defaultBorder = borderColor != null
                  ? BorderSide(color: borderColor!, width: borderWidth)
                  : BorderSide.none;

              return InkWell(
                // Di sinilah 'onTap' digunakan dengan benar, di dalam InkWell
                onTap: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    // Menggunakan KategoriIzinJamSelectionSheet
                    builder: (_) => KategoriIzinJamSelectionSheet(
                      // Menggunakan idKategoriIzinJam
                      initialSelectedId: selectedKategori?.idKategoriIzinJam,
                      onKategoriSelected: (selected) {
                        state.didChange(selected);
                        onKategoriSelected(selected);
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(borderRadius),
                child: Card(
                  color: backgroundColor,
                  elevation: elevation,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: state.hasError ? errorBorder : defaultBorder,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        if (prefixIcon != null)
                          _buildPrefixWithDivider(prefixIcon),
                        Expanded(
                          child: Text(
                            hasSelection ? displayText : hintText,
                            style: TextStyle(
                              fontSize: 14,
                              color: hasSelection
                                  ? AppColors.textDefaultColor
                                  : Colors.grey.shade600,
                              fontStyle: hasSelection
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
            validator: validator,
            autovalidateMode: autovalidateMode,
            initialValue: selectedKategori,
          ),
        ],
      ),
    );
  }

  // Helper prefix icon
  Widget _buildPrefixWithDivider(IconData? icon) {
    if (icon == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.secondTextColor), // Sesuaikan warna ikon
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 1,
            height: 24,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
