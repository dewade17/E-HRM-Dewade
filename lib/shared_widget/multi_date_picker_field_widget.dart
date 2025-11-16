// lib/shared_widget/multi_date_picker_field_widget.dart
import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Widget input yang dapat digunakan kembali untuk memilih BEBERAPA tanggal.
/// Menampilkan tanggal yang dipilih sebagai Chip.
class MultiDatePickerFieldWidget extends StatefulWidget {
  const MultiDatePickerFieldWidget({
    super.key,
    required this.label,
    required this.initialDates,
    required this.onDatesChanged,
    this.dateFormat = 'dd MMMM yyyy',
    this.hintText = 'Pilih tanggal...',
    this.prefixIcon = Icons.calendar_today,
    this.addButtonIcon = Icons.add_circle_outline,
    this.addButtonTooltip = 'Tambah Tanggal Cuti',
    this.isRequired = false,
    this.validator,
    this.autovalidateMode,
    this.width = 350,
    this.elevation = 3,
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    // --- Properti Kuota ---
    this.maxSelectableDates,
    this.maxDatesErrorMessage = 'Jumlah tanggal sudah mencapai batas kuota.',
    this.quotaDisplayLabel,
    this.quotaLabelColor = AppColors.textDefaultColor,
  });

  /// Teks label di atas field.
  final String label;

  /// Daftar tanggal yang sudah dipilih (dikelola oleh state parent).
  final List<DateTime> initialDates;

  /// Callback yang dipanggil saat daftar tanggal berubah.
  final ValueChanged<List<DateTime>> onDatesChanged;

  /// Format tanggal untuk Chip.
  final String dateFormat;

  /// Teks placeholder saat belum ada tanggal.
  final String hintText;

  /// Ikon di prefix (tidak digunakan saat ini, tapi disiapkan).
  final IconData? prefixIcon;

  /// Ikon untuk tombol tambah.
  final IconData addButtonIcon;

  /// Tooltip untuk tombol tambah.
  final String addButtonTooltip;

  /// Menandakan apakah field ini wajib diisi.
  final bool isRequired;

  /// Validator untuk FormField (menerima List<DateTime>).
  final String? Function(List<DateTime>?)? validator;

  /// Mode autovalidasi untuk FormField.
  final AutovalidateMode? autovalidateMode;

  /// Properti UI
  final double? width;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  /// Properti Kuota
  /// Jumlah maksimal tanggal yang bisa dipilih (null = tak terbatas).
  final int? maxSelectableDates;

  /// Pesan error saat kuota habis.
  final String maxDatesErrorMessage;

  /// Teks yang ditampilkan di bawah field (misal: "Sisa kuota: 5 hari").
  final String? quotaDisplayLabel;

  /// Warna untuk teks kuota.
  final Color quotaLabelColor;

  @override
  State<MultiDatePickerFieldWidget> createState() =>
      _MultiDatePickerFieldWidgetState();
}

class _MultiDatePickerFieldWidgetState
    extends State<MultiDatePickerFieldWidget> {
  // State lokal tidak lagi dibutuhkan karena dikelola parent
  // List<DateTime> _selectedDates = [];
  late final DateFormat _dateFormatter;

  @override
  void initState() {
    super.initState();
    _dateFormatter = DateFormat(widget.dateFormat, 'id_ID');
    // _selectedDates = List<DateTime>.from(widget.initialDates)..sort();
  }

  // Helper untuk menampilkan SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? AppColors.errorColor
              : AppColors.succesColor,
        ),
      );
  }

  // Aksi saat tombol tambah ditekan
  Future<void> _handlePickDate(FormFieldState<List<DateTime>> state) async {
    final currentDates = List<DateTime>.from(state.value ?? []);

    // Cek kuota sebelum membuka date picker
    if (widget.maxSelectableDates != null &&
        currentDates.length >= widget.maxSelectableDates!) {
      _showSnackBar(widget.maxDatesErrorMessage, isError: true);
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDates.lastOrNull ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        // Kustomisasi tema date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textDefaultColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!currentDates.contains(picked)) {
        currentDates.add(picked);
        currentDates.sort();
        // Update state FormField dan panggil callback parent
        state.didChange(currentDates);
        widget.onDatesChanged(currentDates);
      } else {
        _showSnackBar('Tanggal sudah dipilih.', isError: true);
      }
    }
  }

  // Aksi saat chip dihapus
  void _removeDate(DateTime date, FormFieldState<List<DateTime>> state) {
    final currentDates = List<DateTime>.from(state.value ?? []);
    currentDates.remove(date);
    // Update state FormField dan panggil callback parent
    state.didChange(currentDates);
    widget.onDatesChanged(currentDates);
  }

  @override
  Widget build(BuildContext context) {
    final baseLabelStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDefaultColor,
      ),
    );

    // Cek apakah kuota masih ada
    bool canSelectMore = true;
    if (widget.maxSelectableDates != null) {
      canSelectMore = widget.initialDates.length < widget.maxSelectableDates!;
    }

    return SizedBox(
      width: widget.width,
      child: FormField<List<DateTime>>(
        autovalidateMode: widget.autovalidateMode,
        initialValue: widget.initialDates,
        validator:
            widget.validator ??
            (value) {
              if (widget.isRequired && (value == null || value.isEmpty)) {
                return '${widget.label} tidak boleh kosong';
              }
              return null;
            },
        builder: (FormFieldState<List<DateTime>> state) {
          final bool hasError = state.hasError;
          final Color effectiveBorderColor = hasError
              ? AppColors.errorColor
              : (widget.borderColor ?? AppColors.textDefaultColor);
          final Color effectiveBackgroundColor =
              widget.backgroundColor ?? Colors.white;
          final List<DateTime> currentDates = state.value ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Label
              Text.rich(
                TextSpan(
                  children: [
                    if (widget.isRequired)
                      TextSpan(
                        text: '* ',
                        style: baseLabelStyle.copyWith(
                          color: AppColors.errorColor,
                        ),
                      ),
                    TextSpan(text: widget.label, style: baseLabelStyle),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 2. Konten (Card)
              Card(
                elevation: widget.elevation,
                margin: EdgeInsets.zero,
                color: effectiveBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  side: BorderSide(
                    color: effectiveBorderColor,
                    width: widget.borderWidth,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Daftar Chip tanggal
                        Expanded(
                          child: currentDates.isEmpty
                              ? Text(
                                  widget.hintText,
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : Wrap(
                                  spacing: 6.0,
                                  runSpacing: 6.0,
                                  children: currentDates.map((date) {
                                    return Chip(
                                      label: Text(
                                        _dateFormatter.format(date),
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      onDeleted: () => _removeDate(date, state),
                                      deleteIconColor: Colors.red.shade700,
                                      backgroundColor: AppColors.accentColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                        // Tombol Tambah
                        IconButton(
                          icon: Icon(
                            widget.addButtonIcon,
                            color: canSelectMore
                                ? AppColors.secondaryColor
                                : Colors.grey,
                          ),
                          onPressed: canSelectMore
                              ? () => _handlePickDate(state)
                              : null,
                          tooltip: widget.addButtonTooltip,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Teks Kuota (di bawah Card)
              if (widget.quotaDisplayLabel != null &&
                  widget.quotaDisplayLabel!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.quotaDisplayLabel!,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: widget.quotaLabelColor,
                        ),
                      ),
                    ),
                  ),
                ),

              // 4. Teks Error (di bawah teks kuota)
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
