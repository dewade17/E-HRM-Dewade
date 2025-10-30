import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kategori_kunjungan.dart'; // <-- DTO Kategori Kunjungan
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/kategori_kunjungan_selection_sheet.dart'; // <-- Import sheet baru
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KategoriKunjunganSelectionField extends StatelessWidget {
  const KategoriKunjunganSelectionField({
    super.key,
    required this.label,
    this.selectedKategori, // Menerima objek KategoriKunjunganItem
    required this.onKategoriSelected, // Callback mengembalikan KategoriKunjunganItem
    this.hintText = 'Pilih jenis kunjungan...',
    this.prefixIcon = Icons.add_box_outlined, // Sesuaikan ikon jika perlu
    this.isRequired = false,
    this.validator, // Validator menerima KategoriKunjunganItem?
    this.autovalidateMode,
    this.width = 350,
    this.elevation = 3,
    this.borderRadius = 12,
    // Ditambahkan: Properti baru
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  final String label;
  final KategoriKunjunganItem? selectedKategori;
  final ValueChanged<KategoriKunjunganItem?> onKategoriSelected;
  final String hintText;
  final IconData? prefixIcon;
  final bool isRequired;
  final FormFieldValidator<KategoriKunjunganItem>? validator;
  final AutovalidateMode? autovalidateMode;
  final double? width;
  final double elevation;
  final double borderRadius;

  // Ditambahkan: Properti kustom untuk background dan border
  /// Warna background untuk Card (opsional)
  final Color? backgroundColor;

  /// Warna border luar field (opsional)
  final Color? borderColor;

  /// Ketebalan border (default 1.0)
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

    // Tampilkan nama kategori jika ada, jika tidak, kosongkan (akan menampilkan hintText)
    final String displayText = selectedKategori?.kategoriKunjungan ?? '';
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
          FormField<KategoriKunjunganItem>(
            builder: (FormFieldState<KategoriKunjunganItem> state) {
              // Diubah: Logika border dipindahkan ke sini
              final BorderSide errorBorder = const BorderSide(
                color: Colors.red,
                width: 1.0,
              );

              final BorderSide defaultBorder = borderColor != null
                  ? BorderSide(color: borderColor!, width: borderWidth)
                  : BorderSide.none;

              return InkWell(
                onTap: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => KategoriKunjunganSelectionSheet(
                      initialSelectedId: selectedKategori?.idKategoriKunjungan,
                      onKategoriSelected: (selected) {
                        state.didChange(selected);
                        onKategoriSelected(selected);
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(borderRadius),
                child: Card(
                  // Ditambahkan: Menerapkan background color
                  color: backgroundColor,
                  elevation: elevation,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    // Diubah: Logika border diperbarui
                    // Prioritaskan error border, jika tidak, gunakan border kustom
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
          Icon(icon),
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
