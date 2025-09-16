import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';

class AuthUtils {
  static Future<void> checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      bool isTokenExpired = JwtDecoder.isExpired(token);

      if (isTokenExpired) {
        // Token expired, hapus token dan arahkan ke login
        await prefs.remove('token');
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      // Jika token valid, arahkan ke home screen
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home-screen');
      }
    }
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && !JwtDecoder.isExpired(token);
  }

  static Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
