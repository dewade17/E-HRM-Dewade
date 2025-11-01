import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/widget/recipient_cuti.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormPengajuanCuti extends StatefulWidget {
  const FormPengajuanCuti({super.key});

  @override
  State<FormPengajuanCuti> createState() => _FormPengajuanCutiState();
}

class _FormPengajuanCutiState extends State<FormPengajuanCuti> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController keperluanController = TextEditingController();
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalMasukController = TextEditingController();

  // FIX: Deklarasi variabel status untuk tanggal cuti
  DateTime? _tanggalMulai;
  DateTime? _tanggalMasuk;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: const RecipientCuti(),
            ),
            const SizedBox(height: 20),
            TextFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Keperluan',
              controller: keperluanController,
              hintText: 'Tulis Keperluan Cuti...',
              isRequired: true,
              prefixIcon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
              maxLines: 3, // Perbolehkan multiline
            ),
            SizedBox(height: 20),
            DatePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Tanggal Mulai Cuti',
              controller: tanggalMulaiController,
              initialDate: _tanggalMulai,
              onDateChanged: (date) => setState(() => _tanggalMulai = date),
              isRequired: true,
            ),
            SizedBox(height: 20),
            DatePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Tanggal Masuk Cuti',
              controller: tanggalMasukController,
              initialDate: _tanggalMasuk,
              onDateChanged: (date) => setState(() => _tanggalMasuk = date),
              isRequired: true,
            ),
            SizedBox(height: 20),
            TextFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Keperluan',
              controller: keperluanController,
              hintText: 'Handover Pekerjaan (min. 50 kata)',
              isRequired: true,
              prefixIcon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
              maxLines: 5, // Perbolehkan multiline
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  "Kirim",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
