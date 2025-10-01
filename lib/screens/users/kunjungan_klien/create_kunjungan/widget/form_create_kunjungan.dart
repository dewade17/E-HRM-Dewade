import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:e_hrm/shared_widget/time_picker_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormCreateKunjungan extends StatefulWidget {
  const FormCreateKunjungan({super.key});

  @override
  State<FormCreateKunjungan> createState() => _FormCreateKunjunganState();
}

class _FormCreateKunjunganState extends State<FormCreateKunjungan> {
  String? _selectedJenisKunjungan;
  final TextEditingController calendarkunjunganController =
      TextEditingController();
  final TextEditingController jamMulaiController = TextEditingController();
  final TextEditingController jamSelesaiController = TextEditingController();
  final TextEditingController keterangankunjungancontroller =
      TextEditingController();

  final List<String> _opsiKunjungan = [
    'Kunjungan Rutin',
    'Kunjungan Darurat',
    'Kunjungan Baru',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 338,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.backgroundColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Form(
          child: Column(
            children: [
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    DropdownFieldWidget<String>(
                      width: 290,
                      prefixIcon: Icons.add_box_outlined,
                      label: "Jenis Kunjungan",
                      hintText: "Pilih jenis kunjungan...",
                      value: _selectedJenisKunjungan,
                      items: _opsiKunjungan.map((String jenis) {
                        return DropdownMenuItem<String>(
                          value: jenis,
                          child: Text(jenis),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedJenisKunjungan = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Anda harus memilih jenis kunjungan.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      width: 290,
                      prefixIcon: Icons.message,
                      maxLines: 3,
                      label: "Keterangan",
                      controller: keterangankunjungancontroller,
                    ),
                    const SizedBox(height: 20),
                    DatePickerFieldWidget(
                      label: "Pilih Tanggal",
                      controller: calendarkunjunganController,
                      width: 290,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TimePickerFieldWidget(
                          label: "Jam mulai",
                          controller: jamMulaiController,
                          width: 135,
                        ),
                        TimePickerFieldWidget(
                          label: "Jam selesai",
                          controller: jamSelesaiController,
                          width: 135,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  elevation: 2,
                ),
                onPressed: () {
                  if (_selectedJenisKunjungan != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pilihan Anda: $_selectedJenisKunjungan'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Silakan pilih jenis kunjungan terlebih dahulu.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
