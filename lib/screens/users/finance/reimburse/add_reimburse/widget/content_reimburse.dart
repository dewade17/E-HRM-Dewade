import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/departements/departements.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/department_selection_field.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';

class ContentReimburse extends StatefulWidget {
  const ContentReimburse({super.key});

  @override
  State<ContentReimburse> createState() => _ContentReimburseState();
}

class _ContentReimburseState extends State<ContentReimburse> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  // State untuk departemen yang dipilih
  Departements? _selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            SizedBox(height: 20),
            DepartmentSelectionField(
              label: "Departemen",
              hintText: "Pilih Departemen...",
              selectedDepartment: _selectedDepartment,
              backgroundColor: Colors.white, // Sesuaikan dengan style design
              borderColor: AppColors.hintColor,
              onDepartmentSelected: (selected) {
                setState(() {
                  _selectedDepartment = selected;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Departemen wajib dipilih';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            DatePickerFieldWidget(
              label: "Tanggal",
              borderColor: AppColors.hintColor,
              controller: tanggalController,
            ),
            SizedBox(height: 20),
            TextFieldWidget(
              label: "Keterangan",
              controller: keteranganController,
              hintText: "Masukkan Deskripsi ...",
              maxLines: 3,
              backgroundColor: Colors.white,
              borderColor: AppColors.hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
