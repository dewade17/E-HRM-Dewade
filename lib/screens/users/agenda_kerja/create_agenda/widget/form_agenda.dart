// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/agenda_kerja/create_agenda/widget/calendar_create_agenda.dart';
import 'package:e_hrm/screens/users/agenda_kerja/create_agenda/widget/time_create_agenda.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormAgenda extends StatefulWidget {
  const FormAgenda({super.key});

  @override
  State<FormAgenda> createState() => _FormAgendaState();
}

class _FormAgendaState extends State<FormAgenda> {
  final deskripsiController = TextEditingController();
  final calendarController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final List<String> _statusOptions = const [
      'Ditunda',
      'Selesai',
      'Diproses',
    ];

    // Nilai terpilih
    String _selectedStatus = 'Diproses';

    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(height: 25),
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' Deskripsi Pekerjaan',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextFormField(
                      controller: deskripsiController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tulis deskripsi…',
                        floatingLabelAlignment: FloatingLabelAlignment.start,
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Icon(Icons.comment),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Masukkan alasan' : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          CalendarCreateAgenda(calendarController: calendarController),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' Jam Mulai & Selesai',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TimeCreateAgenda(
                  onChanged: (mulai, selesai) {
                    // simpan ke provider / form state di sini
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' Status',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Pilih status',
                    hintStyle: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.backgroundColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.menuColor,
                        width: 1.6,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  items: _statusOptions
                      .map(
                        (s) => DropdownMenuItem<String>(
                          value: s,
                          child: Text(
                            s,
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _selectedStatus = val);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              //submitPekerjaan
            },
            child: Card(
              elevation: 5,
              color: AppColors.primaryColor,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 70),
                child: Text(
                  "Simpan Pekerjaan",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
