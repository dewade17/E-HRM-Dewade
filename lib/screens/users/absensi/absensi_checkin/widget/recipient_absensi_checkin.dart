import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipientAbsensiCheckin extends StatefulWidget {
  const RecipientAbsensiCheckin({super.key});

  @override
  State<RecipientAbsensiCheckin> createState() =>
      _RecipientAbsensiCheckinState();
}

class _RecipientAbsensiCheckinState extends State<RecipientAbsensiCheckin> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        color: AppColors.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 360,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.textColor,
                  borderRadius: BorderRadius.circular(15), // pill
                ),

                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 120,
                      child: Card(
                        color: AppColors.accentColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Supervisi",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                // aksi tambah
                              },
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.backgroundColor,
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Chip nama
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
              child: Wrap(
                alignment: WrapAlignment.start, // ⬅️ mulai dari kiri
                spacing: 8,
                runSpacing: 8,
                children: [
                  Card(
                    color: AppColors.accentColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // ⬅️ chip selebar konten
                        children: [
                          Text(
                            "users",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDefaultColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: AppColors.accentColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // ⬅️ chip selebar konten
                        children: [
                          Text(
                            "users",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDefaultColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
