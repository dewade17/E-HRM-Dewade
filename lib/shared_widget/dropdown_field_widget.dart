import 'package:e_hrm/contraints/colors.dart'; // Pastikan path ini benar
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownFieldWidget<T> extends StatefulWidget {
  const DropdownFieldWidget({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.hintText,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.borderColor,
    this.borderWidth = 1.0,
    this.isRequired = false,
    this.requiredIndicatorColor,
    this.width = 350,
    this.height,
    this.elevation = 3,
    this.borderRadius = 12,
    this.autovalidateMode,
  });

  /// Teks label di atas field (contoh: "Pilih Kategori")
  final String label;

  /// Daftar item yang akan ditampilkan dalam dropdown.
  final List<DropdownMenuItem<T>> items;

  /// Nilai yang sedang dipilih.
  final T? value;

  /// Placeholder saat belum ada nilai yang dipilih.
  final String? hintText;

  /// Validator custom.
  final String? Function(T?)? validator;

  /// Callback saat nilai berubah.
  final ValueChanged<T?>? onChanged;

  /// Ikon di prefix.
  final IconData? prefixIcon;

  /// Warna border luar field (opsional).
  final Color? borderColor;

  /// Ketebalan border (default 1.0).
  final double borderWidth;

  /// Tampilkan tanda wajib (*) pada label.
  final bool isRequired;

  /// Warna indikator wajib (default merah).
  final Color? requiredIndicatorColor;

  /// Lebar komponen keseluruhan (default 350).
  final double? width;

  /// Tinggi field opsional.
  final double? height;

  /// Tampilan.
  final double elevation;
  final double borderRadius;

  /// Autovalidate (opsional).
  final AutovalidateMode? autovalidateMode;

  @override
  State<DropdownFieldWidget<T>> createState() => _DropdownFieldWidgetState<T>();
}

class _DropdownFieldWidgetState<T> extends State<DropdownFieldWidget<T>> {
  @override
  Widget build(BuildContext context) {
    final TextStyle baseLabelStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDefaultColor, // Pastikan warna ini ada
      ),
    );

    final Color requiredColor =
        widget.requiredIndicatorColor ??
        AppColors.errorColor; // Pastikan warna ini ada

    final BorderSide cardBorder = widget.borderColor != null
        ? BorderSide(color: widget.borderColor!, width: widget.borderWidth)
        : BorderSide.none;

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: '* ',
                    style: baseLabelStyle.copyWith(color: requiredColor),
                  ),
                TextSpan(text: widget.label, style: baseLabelStyle),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: widget.height,
            child: Card(
              elevation: widget.elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                side: cardBorder,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<T>(
                  value: widget.value,
                  items: widget.items,
                  onChanged: widget.onChanged,
                  validator: widget.validator ?? _defaultValidator,
                  autovalidateMode: widget.autovalidateMode,
                  isExpanded: true, // Membuat dropdown memenuhi lebar Card
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    prefixIcon: widget.prefixIcon != null
                        ? _buildPrefixWithDivider(widget.prefixIcon)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefixWithDivider(IconData? icon) {
    if (icon == null) return const SizedBox.shrink();

    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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

  String? _defaultValidator(T? value) {
    if (widget.isRequired && value == null) {
      return '${widget.label} tidak boleh kosong';
    }
    return null;
  }
}
