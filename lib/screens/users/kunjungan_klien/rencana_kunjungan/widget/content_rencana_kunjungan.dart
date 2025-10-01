import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/create_kunjungan/create_kunjungan_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/calendar_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentRencanaKunjungan extends StatefulWidget {
  const ContentRencanaKunjungan({super.key});

  @override
  State<ContentRencanaKunjungan> createState() =>
      _ContentRencanaKunjunganState();
}

class _ContentRencanaKunjunganState extends State<ContentRencanaKunjungan> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: CalendarKunjungan(),
          ),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.textDefaultColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  color: Colors.black12,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.album_outlined,
                    color: AppColors.menuColor,
                    size: 12,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Selasa, 30 september 2025",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentColor,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  color: Colors.black12,
                ),
              ],
            ),

            child: Column(
              children: [
                SizedBox(height: 50),
                //text ini muncul jika kondisi rencana kunjungan kosong
                Text(
                  "Rencana kunjungan kamu masih kosong, \nsilahkan masukkan jadwal kunjungan kamu",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hintColor,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                //content dibawah ini muncul ketika ada rencana kunjungan yang dibuat status diproses 
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            "Sosilasasi", //kategori.kunjungan
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.message),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Keterangan Kategori",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textDefaultColor,
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorColor,
                                foregroundColor: AppColors.menuColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {},
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(),
                                  child: Text(
                                    "Mulai", //untuk merubah status menjadi berlangsung, mengambil jam_checkin, start_latitude, start_longitude
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month),
                            SizedBox(width: 10),
                            Text("7 September 2025"),
                            SizedBox(width: 20),
                            Icon(Icons.access_time),

                            Text(" 08.00 - 11.00 WITA"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 50),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateKunjunganScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 240,
                    height: 50,
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_rounded),
                          SizedBox(width: 10),
                          Text(
                            "Jadwalkan Kunjungan",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
