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
    this.enabled = true,
    // Ditambahkan: Properti baru
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
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

  /// Menentukan apakah field bisa diedit/dipilih.
  final bool enabled;

  // Ditambahkan: Properti kustom untuk background dan border
  /// Warna background untuk Card (opsional).
  final Color? backgroundColor;

  /// Warna border luar field (opsional).
  final Color? borderColor;

  /// Ketebalan border (default 1.0).
  final double borderWidth;

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
    // Jika initialTime berubah ATAU status enabled berubah dari true ke false
    if (widget.initialTime != oldWidget.initialTime ||
        (oldWidget.enabled && !widget.enabled)) {
      _setInitialValue(widget.initialTime);
    }
    // Jika status enabled berubah dari false ke true dan controller kosong, coba set lagi
    else if (!oldWidget.enabled &&
        widget.enabled &&
        widget.controller.text.isEmpty) {
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

  // Diubah: Menerima FormFieldState untuk memvalidasi perubahan
  Future<void> _pickTime(FormFieldState<String> state) async {
    // <-- Cek flag enabled di sini
    if (!widget.enabled) return;

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
              primary: AppColors.secondaryColor,
            ),
            // Mengatur warna tombol "OK" dan "BATAL" (keduanya TextButton)
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors
                    .secondaryColor, // Warna teks untuk "OK" dan "BATAL"
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
      final String newTimeText = _manualFmt(picked);
      setState(() {
        _selectedTime = picked;
        widget.controller.text = newTimeText;
      });
      // Diubah: Beri tahu FormField tentang nilai baru
      state.didChange(newTimeText);
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
    // <-- Warna ikon jadi abu-abu jika disabled
    final iconColor = widget.enabled
        ? AppColors.secondTextColor
        : Colors.grey.shade400;

    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor), // <-- Gunakan warna dinamis
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
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        // <-- Warna label jadi abu-abu jika disabled
        color: widget.enabled
            ? AppColors.textDefaultColor
            : Colors.grey.shade500,
      ),
    );

    // <-- Warna teks field jadi abu-abu jika disabled
    final fieldTextStyle = TextStyle(
      color: widget.enabled ? AppColors.textDefaultColor : Colors.grey.shade600,
    );
    // <-- Warna hint jadi lebih terang jika disabled
    final hintStyle = TextStyle(
      color: widget.enabled ? Colors.grey.shade400 : Colors.grey.shade300,
      fontStyle: FontStyle.italic,
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

          // Diubah: Dibungkus dengan FormField untuk mengontrol border Card
          FormField<String>(
            validator: widget.validator,
            initialValue: widget.controller.text,
            builder: (FormFieldState<String> state) {
              // Sinkronkan state jika controller berubah (misal oleh _setInitialValue)
              if (widget.controller.text != state.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  state.didChange(widget.controller.text);
                });
              }

              // Tentukan border
              final BorderSide errorBorder = const BorderSide(
                color: AppColors.errorColor,
                width: 1.0,
              );
              final BorderSide defaultBorder = widget.borderColor != null
                  ? BorderSide(
                      color: widget.borderColor!,
                      width: widget.borderWidth,
                    )
                  : BorderSide.none;

              // Tentukan background color
              final Color bgColor = widget.enabled
                  ? (widget.backgroundColor ?? Colors.white)
                  : Colors.grey.shade100;

              return Card(
                elevation: widget.elevation,
                margin: EdgeInsets.zero,
                // Diubah: Terapkan background color dinamis
                color: bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  // Diubah: Terapkan border dinamis
                  side: state.hasError ? errorBorder : defaultBorder,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFormField(
                    controller: widget.controller,
                    readOnly: true,
                    // Diubah: Kirim state ke _pickTime
                    onTap: () => _pickTime(state),
                    validator: null, // Validator dipindahkan ke FormField
                    style: fieldTextStyle, // <-- Gunakan style dinamis
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? '--:--',
                      hintStyle: hintStyle, // <-- Gunakan hint style dinamis
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      prefixIcon: _buildPrefixWithDivider(widget.prefixIcon),
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
}
