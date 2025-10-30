import 'package:e_hrm/contraints/colors.dart';
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
    this.backgroundColor, // <-- Ditambahkan
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

  /// Ditambahkan: Warna background untuk Card (opsional)
  final Color? backgroundColor;

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

    // --- Logika cardBorder LAMA dihapus, dipindahkan ke builder ---

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

          // --- DIUBAH: Menggunakan FormField builder ---
          // Ini agar kita bisa mengontrol border Card saat error,
          // membuatnya konsisten dengan AgendaSelectionField
          FormField<T>(
            validator: widget.validator ?? _defaultValidator,
            autovalidateMode: widget.autovalidateMode,
            initialValue: widget.value,
            builder: (FormFieldState<T> state) {
              // Logika border didefinisikan di dalam builder
              final BorderSide errorBorder = BorderSide(
                color: AppColors.errorColor, // Gunakan warna error
                width: 1.0,
              );
              final BorderSide defaultBorder = widget.borderColor != null
                  ? BorderSide(
                      color: widget.borderColor!,
                      width: widget.borderWidth,
                    )
                  : BorderSide.none;

              return SizedBox(
                height: widget.height,
                child: Card(
                  // Ditambahkan: Menerapkan background color
                  color: widget.backgroundColor,
                  elevation: widget.elevation,
                  margin: EdgeInsets.zero, // Penting agar pas
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    // Diubah: Logika border dinamis berdasarkan state error
                    side: state.hasError ? errorBorder : defaultBorder,
                  ),
                  child: Padding(
                    // Padding tetap sama
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    // Diubah: Menggunakan Row manual untuk prefix dan DropdownButton
                    child: Row(
                      children: [
                        // Tampilkan prefix icon jika ada
                        if (widget.prefixIcon != null)
                          _buildPrefixWithDivider(widget.prefixIcon),

                        // DropdownButton dibungkus Expanded
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<T>(
                              value: state.value, // Gunakan value dari state
                              items: widget.items,
                              onChanged: (T? newValue) {
                                state.didChange(
                                  newValue,
                                ); // Update state FormField
                                if (widget.onChanged != null) {
                                  widget.onChanged!(
                                    newValue,
                                  ); // Panggil callback eksternal
                                }
                              },
                              isExpanded: true,
                              hint: Text(
                                widget.hintText ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              // Style untuk item yang dipilih
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: AppColors.textDefaultColor,
                                  fontSize: 14, // Sesuaikan jika perlu
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- DIUBAH: Helper prefix icon disesuaikan agar bekerja di dalam Row ---
  // (Menggunakan padding dan MainAxisSize.min, bukan SizedBox fixed width)
  Widget _buildPrefixWithDivider(IconData? icon) {
    if (icon == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 8.0), // Beri jarak ke kanan
      child: Row(
        mainAxisSize: MainAxisSize.min, // Agar row tidak mengambil lebar penuh
        children: [
          Icon(
            icon,
            color: AppColors.primaryColor,
          ), // Sesuaikan warna ikon jika perlu
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
