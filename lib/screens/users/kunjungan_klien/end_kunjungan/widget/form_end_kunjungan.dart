import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/mark_me_map.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/recipient_kunjungan.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormEndKunjungan extends StatefulWidget {
  const FormEndKunjungan({super.key});

  @override
  State<FormEndKunjungan> createState() => _FormEndKunjunganState();
}

class _FormEndKunjunganState extends State<FormEndKunjungan> {
  final TextEditingController latitudeEndcontroller = TextEditingController();
  final TextEditingController longitudeEndcontroller = TextEditingController();
  final TextEditingController keterangankunjungancontroller =
      TextEditingController();
  String? _selectedJenisKunjungan;

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
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    MarkMeMap(
                      latitudeController: latitudeEndcontroller,
                      longitudeController: longitudeEndcontroller,
                    ),
                    FormField<bool>(
                      validator: (_) {
                        if (latitudeEndcontroller.text.isEmpty ||
                            longitudeEndcontroller.text.isEmpty) {
                          return 'Silakan tandai lokasi terlebih dulu.';
                        }
                        return null;
                      },
                      builder: (state) {
                        if (state.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              state.errorText!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextFieldWidget(
                width: 300,
                prefixIcon: Icons.message,
                maxLines: 3,
                label: "Keterangan",
                controller: keterangankunjungancontroller,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 5,
                  ),
                  child: Text(
                    "Laporan Ke",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(10, 0, 10, 0),
                child: RecipientKunjungan(),
              ),
              SizedBox(height: 20),
              DropdownFieldWidget<String>(
                width: 300,
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
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Bukti Kunjungan",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
              ),

              // image.aseets lampiran_kunjungan_url
              SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  foregroundColor: AppColors.menuColor,
                ),
                onPressed: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Selesai",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
