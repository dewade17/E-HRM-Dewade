// lib/screens/auth/login/login_screen.dart
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/auth/login.dart' as dto;
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/screens/auth/login/widget/button_login.dart';
import 'package:e_hrm/screens/auth/login/widget/form_login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  void _onToggle() => setState(() => _obscureText = !_obscureText);

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    if (!formKey.currentState!.validate()) return;

    final payload = dto.Login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    await auth.login(context, payload); // navigasi dikelola di provider
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthProvider, bool>((p) => p.loading);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 70),
                Text(
                  "WELCOME",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryColor,
                    shadows: const [
                      Shadow(
                        offset: Offset(-4, 3),
                        blurRadius: 0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 70),
                Image.asset(
                  'lib/assets/image/woman_desk.png',
                  width: 390,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                FormLogin(
                  emailController: emailController,
                  passwordController: passwordController,
                  obscureText: _obscureText,
                  onToggle: _onToggle,
                  formKey: formKey,
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/reset-password');
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text("Ubah kata sandi?"),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ButtonLogin(loading: loading, onPressed: _handleLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
