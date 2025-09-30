import "package:e_hrm/contraints/colors.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class TextFieldKunjungan extends StatefulWidget {
  const TextFieldKunjungan({
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
  });

  /// Teks label di atas field (contoh: "Email", "Password")
  final String label;

  /// Controller teks
  final TextEditingController controller;

  /// Placeholder
  final String? hintText;

  /// Mode password: aktifkan tombol show/hide
  final bool isPassword;

  /// Status awal untuk obscure password
  final bool initialObscure;

  /// Tipe keyboard (jika null dan bukan password, akan coba diset otomatis)
  final TextInputType? keyboardType;

  /// Validator custom (kalau null, ada default: email/password basic)
  final String? Function(String?)? validator;

  /// onChanged (opsional)
  final ValueChanged<String>? onChanged;

  /// Ikon di prefix (mis. Icons.alternate_email_rounded / Icons.lock_outline_rounded)
  final IconData? prefixIcon;

  /// Warna border luar field (opsional)
  final Color? borderColor;

  /// Ketebalan border (default 1.0)
  final double borderWidth;

  /// Tampilkan tanda wajib (*) pada label
  final bool isRequired;

  /// Warna indikator wajib (default merah)
  final Color? requiredIndicatorColor;

  /// Lebar komponen keseluruhan (default 350)
  final double? width;

  /// Tinggi field opsional
  final double? height;

  /// Tampilan
  final double elevation;
  final double borderRadius;

  /// Autovalidate (opsional)
  final AutovalidateMode? autovalidateMode;

  @override
  State<TextFieldKunjungan> createState() => _TextFieldKunjunganState();
}

class _TextFieldKunjunganState extends State<TextFieldKunjungan> {
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
        (isPwd ? TextInputType.visiblePassword : TextInputType.emailAddress);

    final TextStyle baseLabelStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDefaultColor,
      ),
    );

    final Color requiredColor =
        widget.requiredIndicatorColor ?? AppColors.errorColor;

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
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: kb,
                  obscureText: isPwd ? _obscure : false,
                  autovalidateMode: widget.autovalidateMode,
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
                    suffixIcon: isPwd
                        ? IconButton(
                            tooltip: _obscure ? 'Tampilkan' : 'Sembunyikan',
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(() {
                              _obscure = !_obscure;
                            }),
                          )
                        : null,
                  ),
                  validator: widget.validator ?? _defaultValidator(isPwd, kb),
                  onChanged: widget.onChanged,
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

  String? Function(String?) _defaultValidator(bool isPwd, TextInputType kb) {
    return (value) {
      final String v = value?.trim() ?? '';

      if (widget.isRequired && v.isEmpty) {
        return '${widget.label} tidak boleh kosong';
      }

      if (!isPwd && kb == TextInputType.emailAddress && v.isNotEmpty) {
        final RegExp emailPattern = RegExp(
          r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
        );
        if (!emailPattern.hasMatch(v)) {
          return 'Format email tidak valid';
        }
      }

      if (isPwd && v.isNotEmpty && v.length < 6) {
        return 'Password minimal 6 karakter';
      }

      return null;
    };
  }
}
