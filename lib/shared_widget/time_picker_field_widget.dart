import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget reusable yang sangat dapat dikustomisasi untuk memilih satu waktu (jam dan menit)
/// Didesain agar konsisten dengan widget lain di folder shared_widget.
class TimePickerFieldWidget extends StatefulWidget {
  const TimePickerFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.validator,
    this.onChanged,
    this.initialTime,
    this.prefixIcon = Icons.access_time,
    this.width = 350,
    this.isRequired = false,
    this.elevation = 3,
    this.borderRadius = 12,
  });

  /// Teks label di atas field.
  final String label;

  /// Controller untuk mengelola teks di dalam field.
  final TextEditingController controller;

  /// Placeholder saat field kosong.
  final String? hintText;

  /// Fungsi validator untuk form.
  final String? Function(String?)? validator;

  /// Callback yang dipanggil dengan nilai TimeOfDay saat waktu berubah.
  final ValueChanged<TimeOfDay?>? onChanged;

  /// Nilai waktu awal.
  final TimeOfDay? initialTime;

  /// Ikon yang ditampilkan di prefix.
  final IconData? prefixIcon;

  /// Lebar keseluruhan komponen.
  final double? width;

  /// Menandakan apakah field ini wajib diisi (menampilkan tanda bintang).
  final bool isRequired;

  /// Properti UI untuk Card.
  final double elevation;
  final double borderRadius;

  @override
  State<TimePickerFieldWidget> createState() => _TimePickerFieldWidgetState();
}

class _TimePickerFieldWidgetState extends State<TimePickerFieldWidget> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _setInitialValue(widget.initialTime);
  }

  @override
  void didUpdateWidget(covariant TimePickerFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTime != oldWidget.initialTime) {
      _setInitialValue(widget.initialTime);
    }
  }

  void _setInitialValue(TimeOfDay? time) {
    setState(() {
      _selectedTime = time;
      widget.controller.text = _manualFmt(time);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged?.call(_selectedTime);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Pilih ${widget.label}',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            // Mengatur skema warna utama
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
              // Warna untuk tombol "OK" dan header
              primary: AppColors.primaryColor,
            ),
            // Mengatur warna tombol "OK" dan "BATAL" (keduanya TextButton)
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.primaryColor, // Warna teks untuk "OK" dan "BATAL"
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        widget.controller.text = _manualFmt(picked);
      });
      widget.onChanged?.call(picked);
    }
  }

  String _manualFmt(TimeOfDay? t) {
    if (t == null) return '';
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildPrefixWithDivider(IconData? icon) {
    if (icon == null) return const SizedBox.shrink();

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextFormField(
                controller: widget.controller,
                readOnly: true,
                onTap: _pickTime,
                validator: widget.validator,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? '--:--',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  prefixIcon: _buildPrefixWithDivider(widget.prefixIcon),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
