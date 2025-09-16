import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.all(Colors.grey),
        trackOutlineWidth: WidgetStateProperty.all(0.0),
        trackOutlineColor: WidgetStateProperty.all(Colors.grey),
        overlayColor: WidgetStateProperty.all(Colors.blue[100]),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.accentColor),
        ),
      ),
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 72.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          fontSize: 36.0,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(fontSize: 14.0, fontFamily: 'Poppins'),
        titleLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        titleMedium: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        titleSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: AppColors.textDefaultColor),
      ),
    );
  }
}
