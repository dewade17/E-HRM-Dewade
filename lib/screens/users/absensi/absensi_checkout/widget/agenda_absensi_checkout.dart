import 'package:dotted_border/dotted_border.dart';
import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgendaAbsensiCheckout extends StatefulWidget {
  const AgendaAbsensiCheckout({super.key});

  @override
  State<AgendaAbsensiCheckout> createState() => _AgendaAbsensiCheckoutState();
}

class _AgendaAbsensiCheckoutState extends State<AgendaAbsensiCheckout> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Pekerjaan yang perlu anda proses hari ini (0)",
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Card(
            child: DottedBorder(
              options: CustomPathDottedBorderOptions(
                color: AppColors.accentColor,
                strokeWidth: 2,
                dashPattern: const [10, 5],
                padding: const EdgeInsets.all(12),
                customPath: (size) {
                  // Kotak tajam:
                  // return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

                  // Kotak rounded:
                  final rect = Rect.fromLTWH(0, 0, size.width, size.height);
                  const radius = Radius.circular(8);
                  return Path()
                    ..addRRect(RRect.fromRectAndRadius(rect, radius));
                },
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Tambahkan Pekerjaan Anda di hari ini",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDefaultColor,
                        ),
                      ),
                    ),
                    //muncul disini, dengan ui yang sama
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              //TODO Pergi ke agenda_screen, lalu agenda_screen bisa menjadi cheklist, lalu memilih agenda dan muncul diline 58
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
    );
  }
}
