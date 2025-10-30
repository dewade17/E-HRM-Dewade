import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/agenda/agenda.dart';
import 'package:e_hrm/screens/users/agenda_kerja/widget/agenda_selection_sheet.dart'; // <-- Import sheet
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgendaSelectionField extends StatelessWidget {
  const AgendaSelectionField({
    super.key,
    required this.label,
    this.selectedAgenda,
    required this.onAgendaSelected,
    this.hintText = 'Pilih agenda...',
    this.prefixIcon = Icons.list_alt, // Ganti ikon jika perlu
    this.isRequired = false,
    this.validator,
    this.autovalidateMode,
    this.width = 350,
    this.elevation = 3,
    this.borderRadius = 12,
    // Ditambahkan: Properti baru
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  final String label;
  final AgendaItem? selectedAgenda; // Item Agenda yang dipilih
  final ValueChanged<AgendaItem?>
  onAgendaSelected; // Callback saat item dipilih
  final String hintText;
  final IconData? prefixIcon;
  final bool isRequired;
  final FormFieldValidator<AgendaItem>?
  validator; // Validator menerima AgendaItem?
  final AutovalidateMode? autovalidateMode;
  final double? width;
  final double elevation;
  final double borderRadius;

  // Ditambahkan: Properti kustom untuk background dan border
  /// Warna background untuk Card (opsional)
  final Color? backgroundColor;

  /// Warna border luar field (opsional)
  final Color? borderColor;

  /// Ketebalan border (default 1.0)
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final baseLabelStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDefaultColor,
      ),
    );

    final String displayText =
        selectedAgenda?.namaAgenda ?? 'Agenda Tanpa Nama';
    final bool hasSelection = selectedAgenda != null;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label dengan tanda bintang jika wajib
          Text.rich(
            TextSpan(
              children: [
                if (isRequired)
                  TextSpan(
                    text: '* ',
                    style: baseLabelStyle.copyWith(color: AppColors.errorColor),
                  ),
                TextSpan(text: label, style: baseLabelStyle),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Menggunakan FormField untuk integrasi validasi
          FormField<AgendaItem>(
            builder: (FormFieldState<AgendaItem> state) {
              // Diubah: Logika border dipindahkan ke sini
              final BorderSide errorBorder = const BorderSide(
                color: Colors.red,
                width: 1.0,
              );

              final BorderSide defaultBorder = borderColor != null
                  ? BorderSide(color: borderColor!, width: borderWidth)
                  : BorderSide.none;

              return InkWell(
                onTap: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AgendaSelectionSheet(
                      initialSelectedId: selectedAgenda?.idAgenda,
                      onAgendaSelected: (selected) {
                        state.didChange(selected); // Update state FormField
                        onAgendaSelected(
                          selected,
                        ); // Panggil callback eksternal
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(borderRadius),
                child: Card(
                  // Ditambahkan: Menerapkan background color
                  color: backgroundColor,
                  elevation: elevation,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    // Diubah: Logika border diperbarui
                    // Prioritaskan error border, jika tidak, gunakan border kustom
                    side: state.hasError ? errorBorder : defaultBorder,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16, // Sesuaikan padding vertikal
                    ),
                    child: Row(
                      children: [
                        // Prefix Icon dengan divider
                        if (prefixIcon != null)
                          _buildPrefixWithDivider(prefixIcon),
                        // Teks Agenda Terpilih atau Hint Text
                        Expanded(
                          child: Text(
                            hasSelection ? displayText : hintText,
                            style: TextStyle(
                              fontSize: 14, // Sesuaikan ukuran font
                              color: hasSelection
                                  ? AppColors.textDefaultColor
                                  : Colors.grey.shade600,
                              fontStyle: hasSelection
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Ikon dropdown di akhir
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
            validator: validator, // Gunakan validator yang diberikan
            autovalidateMode: autovalidateMode,
            initialValue: selectedAgenda, // Nilai awal untuk validator
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat prefix icon dengan divider
  Widget _buildPrefixWithDivider(IconData? icon) {
    if (icon == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 8.0), // Beri jarak ke kanan
      child: Row(
        mainAxisSize: MainAxisSize.min, // Agar row tidak mengambil lebar penuh
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
