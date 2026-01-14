import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DatePickerFieldWidget extends StatefulWidget {
  const DatePickerFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.initialDate,
    this.onDateChanged,
    this.dateFormat = 'dd MMMM yyyy',
    this.firstDate,
    this.lastDate,
    this.hintText,
    this.prefixIcon = Icons.calendar_today,
    this.isRequired = false,
    this.width = 350,
    this.elevation = 3,
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    // TAMBAHKAN INI: Parameter validator
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final DateTime? initialDate;
  final ValueChanged<DateTime?>? onDateChanged;
  final String dateFormat;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hintText;
  final IconData? prefixIcon;
  final bool isRequired;
  final double? width;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  // TAMBAHKAN INI: Definisi variabel validator
  final String? Function(String?)? validator;

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateDate(widget.initialDate);
        }
      });
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

  Future<void> _pickDate(
    BuildContext context,
    FormFieldState<String> state,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
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
      state.didChange(widget.controller.text);
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

          FormField<String>(
            initialValue: widget.controller.text,
            // LOGIKA VALIDASI DIPERBAIKI:
            // Menggunakan validator dari widget jika ada, jika tidak gunakan logika isRequired
            validator:
                widget.validator ??
                (value) {
                  if (widget.isRequired && (value == null || value.isEmpty)) {
                    return '${widget.label} tidak boleh kosong';
                  }
                  return null;
                },
            builder: (FormFieldState<String> state) {
              // Sinkronisasi manual jika controller diubah dari luar
              if (widget.controller.text != state.value) {
                // Defer update to avoid build phase errors
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && state.mounted) {
                    state.didChange(widget.controller.text);
                  }
                });
              }

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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: widget.elevation,
                    margin: EdgeInsets.zero,
                    color: widget.backgroundColor ?? Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      side: state.hasError ? errorBorder : defaultBorder,
                    ),
                    child: InkWell(
                      onTap: () => _pickDate(context, state),
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
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              prefixIcon: widget.prefixIcon != null
                                  ? _buildPrefixWithDivider(widget.prefixIcon!)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Menampilkan pesan error di bawah field jika validasi gagal
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 5),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(
                          color: AppColors.errorColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
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
          Icon(icon, color: AppColors.secondTextColor),
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
