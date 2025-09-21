// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 30, //horizontal
      runSpacing: 20, //vertikal
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/agenda-kerja');
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.textColor, AppColors.backgroundColor],
                  ),
                  shape: BoxShape.circle,
                  // color: AppColors.secondaryColor.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2), // warna shadow
                      blurRadius: 8, // seberapa blur
                      offset: Offset(0, 4), // posisi shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Icon(Icons.wallet_travel_rounded),
              ),
              SizedBox(height: 10),
              Text(
                "Kunjungan",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/agenda-kerja');
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.textColor, AppColors.backgroundColor],
                  ),
                  shape: BoxShape.circle,
                  // color: AppColors.secondaryColor.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2), // warna shadow
                      blurRadius: 8, // seberapa blur
                      offset: Offset(0, 4), // posisi shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Icon(Icons.assignment_add),
              ),
              SizedBox(height: 10),
              Text(
                "Agenda \nKerja",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.textColor, AppColors.backgroundColor],
                ),
                shape: BoxShape.circle,
                // color: AppColors.secondaryColor.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // warna shadow
                    blurRadius: 8, // seberapa blur
                    offset: Offset(0, 4), // posisi shadow
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Icon(Icons.insert_invitation),
            ),
            SizedBox(height: 10),
            Text(
              "Cuti/izin",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDefaultColor,
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.textColor, AppColors.backgroundColor],
                ),
                shape: BoxShape.circle,
                // color: AppColors.secondaryColor.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // warna shadow
                    blurRadius: 8, // seberapa blur
                    offset: Offset(0, 4), // posisi shadow
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Icon(Icons.coffee_maker_outlined),
            ),
            SizedBox(height: 10),
            Text(
              "Jam \nIstirahat",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDefaultColor,
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.textColor, AppColors.backgroundColor],
                ),
                shape: BoxShape.circle,
                // color: AppColors.secondaryColor.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // warna shadow
                    blurRadius: 8, // seberapa blur
                    offset: Offset(0, 4), // posisi shadow
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Icon(Icons.more_time),
            ),
            SizedBox(height: 10),
            Text(
              "Lembur",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDefaultColor,
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.textColor, AppColors.backgroundColor],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // warna shadow
                    blurRadius: 8, // seberapa blur
                    offset: Offset(0, 4), // posisi shadow
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Icon(Icons.monetization_on_sharp),
            ),
            SizedBox(height: 10),
            Text(
              "Request \nPocket Money",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDefaultColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
