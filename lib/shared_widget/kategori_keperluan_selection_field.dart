import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kategori_keperluan/kategori_keperluan.dart';
import 'package:e_hrm/screens/users/finance/widget/kategori_keperluan_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KategoriKeperluanSelectionField extends StatelessWidget {
  final String label;
  final Data? selectedKategori;
  final ValueChanged<Data?> onKategoriSelected;
  final String hintText;
  final bool isRequired;
  final FormFieldValidator<Data>? validator;

  // Parameter tambahan baru
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final double elevation;

  const KategoriKeperluanSelectionField({
    super.key,
    required this.label,
    this.selectedKategori,
    required this.onKategoriSelected,
    this.hintText = 'Pilih kategori...',
    this.isRequired = false,
    this.validator,
    // Inisialisasi parameter baru
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 12.0,
    this.elevation = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              if (isRequired)
                TextSpan(
                  text: '* ',
                  style: GoogleFonts.poppins(color: AppColors.errorColor),
                ),
              TextSpan(
                text: label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FormField<Data>(
          validator: validator,
          initialValue: selectedKategori,
          builder: (state) {
            // Logika border: Merah jika error, custom/hint jika normal
            final BorderSide errorBorder = const BorderSide(
              color: Colors.red,
              width: 1.0,
            );

            final BorderSide defaultBorder = BorderSide(
              color: borderColor ?? AppColors.hintColor,
              width: borderWidth,
            );

            return InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => KategoriKeperluanSelectionSheet(
                    initialSelectedId: selectedKategori?.idKategoriKeperluan,
                    onKategoriSelected: (selected) {
                      state.didChange(selected);
                      onKategoriSelected(selected);
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(borderRadius),
              child: Card(
                color: backgroundColor ?? Colors.white,
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
                      const Icon(
                        Icons.category,
                        color: AppColors.secondTextColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedKategori?.namaKeperluan ?? hintText,
                          style: TextStyle(
                            fontSize: 14,
                            color: selectedKategori != null
                                ? AppColors.textDefaultColor
                                : Colors.grey.shade600,
                            fontStyle: selectedKategori != null
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
        ),
      ],
    );
  }
}
