import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CatatanAbsensiCheckin extends StatefulWidget {
  const CatatanAbsensiCheckin({super.key});

  @override
  State<CatatanAbsensiCheckin> createState() => _CatatanAbsensiCheckinState();
}

class _CatatanAbsensiCheckinState extends State<CatatanAbsensiCheckin> {
  final TextEditingController catatanController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  get onToggle => null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Catatan",
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ),
          ),
        ),
        Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(
                          controller: catatanController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Tulis catatan…',
                            floatingLabelAlignment:
                                FloatingLabelAlignment.start,
                            alignLabelWithHint: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Icon(Icons.comment),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close_outlined),
                              onPressed: onToggle,
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Masukkan catatan'
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          //TODO Akan increment textformfield catatan
                        },
                        child: SizedBox(
                          width: 150,
                          height: 50,
                          child: Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle),
                                SizedBox(width: 10),
                                Text(
                                  "Pekerjaan",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDefaultColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
