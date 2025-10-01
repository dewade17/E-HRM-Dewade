import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/detail_kunjungan_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/end_kunjungan/end_kunjungan_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/calendar_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentDaftarKunjungan extends StatefulWidget {
  const ContentDaftarKunjungan({super.key});

  @override
  State<ContentDaftarKunjungan> createState() => _ContentDaftarKunjunganState();
}

class _ContentDaftarKunjunganState extends State<ContentDaftarKunjungan> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CalendarKunjungan(),
          SizedBox(height: 20),
          Row(
            //dapat memilih melihat status selesai dan berlangsung
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 150,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(child: Text("Berlangsung")),
              ),
              Container(
                width: 150,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(child: Text("Selesai")),
              ),
            ],
          ),
          SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textColor,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                    border: const Border(
                      top: BorderSide(color: AppColors.primaryColor, width: 1),
                      left: BorderSide(color: AppColors.primaryColor, width: 5),
                      right: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            width: 100,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image, //lampiran_kunjungan_url
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kunjungan Rutin Pelanggan",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "30 Sep 2025",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textDefaultColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "09:46 - --:-- WITA",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textDefaultColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EndKunjunganScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Selesaikan Kunjungan",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.errorColor,
                                        decoration: TextDecoration.underline,
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
                ),
              ),
              // jika sedang berlangsung
              Positioned(
                top: 0,
                bottom: 0,
                right: 25.0,
                child: Transform.translate(
                  offset: const Offset(20, 0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.hintColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.autorenew_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textColor,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                    border: const Border(
                      top: BorderSide(color: AppColors.primaryColor, width: 1),
                      left: BorderSide(color: AppColors.primaryColor, width: 5),
                      right: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            width: 100,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Follow Up Prospek",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "29 Sep 2025",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textDefaultColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "14:00 - 15:30 WITA",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textDefaultColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DetailKunjunganScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Detail Kunjungan",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textDefaultColor,
                                        decoration: TextDecoration.underline,
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
                ),
              ),
              //jika sudah selesai
              Positioned(
                top: 0,
                bottom: 0,
                right: 25.0,
                child: Transform.translate(
                  offset: const Offset(20, 0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
