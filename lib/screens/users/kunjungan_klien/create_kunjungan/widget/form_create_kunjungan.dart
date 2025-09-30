import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/time_picker_field_widget.dart';
import 'package:flutter/material.dart';

class FormCreateKunjungan extends StatefulWidget {
  const FormCreateKunjungan({super.key});

  @override
  State<FormCreateKunjungan> createState() => _FormCreateKunjunganState();
}

class _FormCreateKunjunganState extends State<FormCreateKunjungan> {
  String? _selectedJenisKunjungan;
  final TextEditingController calendarController = TextEditingController();
  final TextEditingController jamMulaiController = TextEditingController();
  final List<String> _opsiKunjungan = [
    'Kunjungan Rutin',
    'Kunjungan Darurat',
    'Kunjungan Baru',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        child: Column(
          children: [
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  DropdownFieldWidget<String>(
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
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedJenisKunjungan != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pilihan Anda: $_selectedJenisKunjungan',
                            ),
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
                    child: const Text('Simpan'),
                  ),
                  DatePickerFieldWidget(
                    label: "Pilih Tanggal",
                    controller: calendarController,
                    width: 200,
                  ),
                  TimePickerFieldWidget(
                    label: "Jam mulai",
                    controller: jamMulaiController,
                    width: 200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
