// lib/shared_widget/text_field_widget.dart

import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum ValidationType { none, email, password }

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.initialObscure = true,
    this.keyboardType,
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
    this.maxLines = 1,
    this.validationType = ValidationType.none,
    this.backgroundColor,
    this.enabled = true,
    this.readOnly = false, // ✅ NEW
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool isPassword;
  final bool initialObscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Color? borderColor;
  final double borderWidth;
  final bool isRequired;
  final Color? requiredIndicatorColor;
  final double? width;
  final double? height;
  final double elevation;
  final double borderRadius;
  final AutovalidateMode? autovalidateMode;
  final int maxLines;
  final ValidationType validationType;
  final Color? backgroundColor;
  final bool enabled;

  // ✅ NEW: field tetap bisa focus/copy tapi tidak bisa edit
  final bool readOnly;

  final List<TextInputFormatter>? inputFormatters;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword ? widget.initialObscure : false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isPwd = widget.isPassword;

    final TextInputType kb =
        widget.keyboardType ??
        (widget.validationType == ValidationType.email
            ? TextInputType.emailAddress
            : TextInputType.text);

    final TextStyle baseLabelStyle = GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: widget.enabled
            ? AppColors.textDefaultColor
            : Colors.grey.shade500,
      ),
    );

    final Color requiredColor =
        widget.requiredIndicatorColor ?? AppColors.errorColor;

    final BorderSide cardBorder = widget.borderColor != null
        ? BorderSide(color: widget.borderColor!, width: widget.borderWidth)
        : BorderSide.none;

    final bool isReadOnlyEffective = widget.readOnly || !widget.enabled;

    final fieldTextStyle = TextStyle(
      color: widget.enabled ? AppColors.textDefaultColor : Colors.grey.shade600,
    );
    final hintStyle = TextStyle(
      color: widget.enabled ? Colors.grey.shade400 : Colors.grey.shade300,
      fontStyle: FontStyle.italic,
    );

    final Color cardColor = !widget.enabled
        ? Colors.grey.shade100
        : (widget.backgroundColor ?? Colors.white);

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
              color: cardColor,
              elevation: widget.elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                side: cardBorder,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: kb,
                  obscureText: isPwd ? _obscure : false,
                  autovalidateMode: widget.autovalidateMode,
                  maxLines: isPwd ? 1 : widget.maxLines,

                  enabled: widget.enabled,
                  readOnly: isReadOnlyEffective, // ✅ FIX

                  style: fieldTextStyle,
                  inputFormatters: widget.inputFormatters,

                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    prefixIcon: widget.prefixIcon != null
                        ? _buildPrefixWithDivider(widget.prefixIcon)
                        : null,
                    suffixIcon: isPwd
                        ? IconButton(
                            tooltip: _obscure ? 'Tampilkan' : 'Sembunyikan',
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: widget.enabled
                                ? () => setState(() => _obscure = !_obscure)
                                : null,
                          )
                        : null,
                  ),
                  validator: widget.validator ?? _defaultValidator(),
                  onChanged: isReadOnlyEffective ? null : widget.onChanged,
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
    final iconColor = widget.enabled
        ? AppColors.secondTextColor
        : Colors.grey.shade400;

    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor),
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

  String? Function(String?) _defaultValidator() {
    return (value) {
      final String v = value?.trim() ?? '';
      if (widget.isRequired && v.isEmpty) {
        return '${widget.label} tidak boleh kosong';
      }
      if (v.isEmpty) return null;

      switch (widget.validationType) {
        case ValidationType.email:
          final RegExp emailPattern = RegExp(
            r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
          );
          if (!emailPattern.hasMatch(v)) return 'Format email tidak valid';
          break;
        case ValidationType.password:
          if (v.length < 6) return 'Password minimal 6 karakter';
          break;
        case ValidationType.none:
          break;
      }
      return null;
    };
  }
}
