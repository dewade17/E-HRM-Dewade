import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/departements/departements.dart';
import 'package:e_hrm/screens/users/finance/reimburse/add_reimburse/widget/department_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DepartmentSelectionField extends StatelessWidget {
  const DepartmentSelectionField({
    super.key,
    required this.label,
    this.selectedDepartment,
    required this.onDepartmentSelected,
    this.hintText = 'Pilih departemen...',
    this.prefixIcon = Icons.business,
    this.isRequired = false,
    this.validator,
    this.autovalidateMode,
    this.width = 350,
    this.elevation = 3,
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  final String label;
  final Departements? selectedDepartment;
  final ValueChanged<Departements?> onDepartmentSelected;
  final String hintText;
  final IconData? prefixIcon;
  final bool isRequired;
  final FormFieldValidator<Departements>? validator;
  final AutovalidateMode? autovalidateMode;
  final double? width;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
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

    final String displayText = selectedDepartment?.namaDepartement ?? '';
    final bool hasSelection = selectedDepartment != null;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          FormField<Departements>(
            builder: (FormFieldState<Departements> state) {
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
                    builder: (_) => DepartmentSelectionSheet(
                      initialSelectedId: selectedDepartment?.idDepartement,
                      onDepartmentSelected: (selected) {
                        state.didChange(selected);
                        onDepartmentSelected(selected);
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(borderRadius),
                child: Card(
                  color: backgroundColor,
                  elevation: elevation,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: state.hasError ? errorBorder : defaultBorder,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        if (prefixIcon != null)
                          _buildPrefixWithDivider(prefixIcon),
                        Expanded(
                          child: Text(
                            hasSelection ? displayText : hintText,
                            style: TextStyle(
                              fontSize: 14,
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
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
            validator: validator,
            autovalidateMode: autovalidateMode,
            initialValue: selectedDepartment,
          ),
        ],
      ),
    );
  }

  Widget _buildPrefixWithDivider(IconData? icon) {
    if (icon == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
