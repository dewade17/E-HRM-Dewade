import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Widget input tanggal yang dapat digunakan kembali dengan tampilan modern.
/// Membuka dialog pemilih tanggal (datepicker) saat ditekan.
class DatePickerFieldWidget extends StatefulWidget {
  const DatePickerFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.initialDate,
    this.onDateChanged,
    this.dateFormat =
        'dd MMMM yyyy', // Format default yang lebih ramah pengguna
    this.firstDate,
    this.lastDate,
    this.hintText,
    this.prefixIcon = Icons.calendar_today,
    this.isRequired = false,
    this.width = 350,
    this.elevation = 3,
    this.borderRadius = 12,
  });

  /// Teks label di atas field.
  final String label;

  /// Controller untuk menampilkan tanggal yang dipilih.
  final TextEditingController controller;

  /// Tanggal awal yang ditampilkan saat widget pertama kali dibuat.
  final DateTime? initialDate;

  /// Callback yang dipanggil saat tanggal berubah.
  final ValueChanged<DateTime?>? onDateChanged;

  /// Format tanggal yang akan ditampilkan (contoh: 'dd/MM/yyyy').
  final String dateFormat;

  /// Tanggal paling awal yang bisa dipilih.
  final DateTime? firstDate;

  /// Tanggal paling akhir yang bisa dipilih.
  final DateTime? lastDate;

  /// Teks placeholder.
  final String? hintText;

  /// Ikon di sebelah kiri.
  final IconData? prefixIcon;

  /// Menandakan apakah field ini wajib diisi.
  final bool isRequired;

  /// Lebar widget.
  final double? width;

  /// Efek bayangan (elevation) pada Card.
  final double elevation;

  /// Radius sudut pada Card.
  final double borderRadius;

  @override
  State<DatePickerFieldWidget> createState() => _DatePickerFieldWidgetState();
}

class _DatePickerFieldWidgetState extends State<DatePickerFieldWidget> {
  DateTime? _selectedDate;
  late final DateFormat _dateFormatter;

  @override
  void initState() {
    super.initState();
    _dateFormatter = DateFormat(widget.dateFormat, 'id_ID');
    _updateDate(widget.initialDate, notify: false);
  }

  @override
  void didUpdateWidget(covariant DatePickerFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      // PERBAIKAN: Gunakan addPostFrameCallback untuk menunda update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateDate(widget.initialDate);
        }
      });
    }
    if (widget.dateFormat != oldWidget.dateFormat) {
      _dateFormatter = DateFormat(widget.dateFormat, 'id_ID');
      _updateControllerText();
    }
  }

  void _updateDate(DateTime? newDate, {bool notify = true}) {
    setState(() {
      _selectedDate = newDate;
    });
    _updateControllerText();
    if (notify) {
      widget.onDateChanged?.call(_selectedDate);
    }
  }

  void _updateControllerText() {
    if (_selectedDate != null) {
      widget.controller.text = _dateFormatter.format(_selectedDate!);
    } else {
      widget.controller.clear();
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        // Kustomisasi tema date picker agar sesuai dengan tema aplikasi
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textDefaultColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(fontSize: 20),
              titleLarge: TextStyle(fontSize: 16),
              bodyLarge: TextStyle(fontSize: 14),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _updateDate(picked);
    }
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
                    style: baseLabelStyle.copyWith(color: AppColors.errorColor),
                  ),
                TextSpan(text: widget.label, style: baseLabelStyle),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: widget.elevation,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: widget.controller,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? 'Pilih tanggal...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      prefixIcon: widget.prefixIcon != null
                          ? _buildPrefixWithDivider(widget.prefixIcon!)
                          : null,
                    ),
                    validator: (value) {
                      if (widget.isRequired &&
                          (value == null || value.isEmpty)) {
                        return '${widget.label} tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefixWithDivider(IconData icon) {
    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryColor),
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
