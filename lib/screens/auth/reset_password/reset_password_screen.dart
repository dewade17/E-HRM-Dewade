// ignore_for_file: use_build_context_synchronously

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/auth/reset_password_provider.dart';
import 'package:e_hrm/screens/auth/reset_password/widget/button_get_token.dart';
import 'package:e_hrm/screens/auth/reset_password/widget/button_reset_password.dart';
import 'package:e_hrm/screens/auth/reset_password/widget/form_get_token.dart';
import 'package:e_hrm/screens/auth/reset_password/widget/form_reset_password.dart';
import 'package:e_hrm/screens/auth/reset_password/widget/header_content_password.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Pisahkan key untuk masing-masing form
  final _formGetTokenKey = GlobalKey<FormState>();
  final _formResetKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final tokenController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscureText = true;
  bool _loadingRequest = false;
  bool _loadingConfirm = false;

  void _onToggle() => setState(() => _obscureText = !_obscureText);

  @override
  void dispose() {
    emailController.dispose();
    tokenController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.errorColor : AppColors.succesColor,
      ),
    );
  }

  Future<void> _handleRequestToken() async {
    FocusScope.of(context).unfocus();
    if (!(_formGetTokenKey.currentState?.validate() ?? false)) return;

    final provider = context.read<ResetPasswordProvider>();
    setState(() => _loadingRequest = true);
    final ok = await provider.requestToken(emailController.text);
    setState(() => _loadingRequest = false);

    final msg = provider.message ?? provider.error ?? '';
    if (msg.isNotEmpty) _showSnack(msg, error: !ok);
  }

  Future<void> _handleConfirmReset() async {
    FocusScope.of(context).unfocus();
    if (!(_formResetKey.currentState?.validate() ?? false)) return;

    final provider = context.read<ResetPasswordProvider>();
    setState(() => _loadingConfirm = true);
    final ok = await provider.confirmReset(
      otp: tokenController.text,
      newPassword: passwordController.text,
    );
    setState(() => _loadingConfirm = false);

    final msg = provider.message ?? provider.error ?? '';
    if (msg.isNotEmpty) _showSnack(msg, error: !ok);

    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const HeaderContentPassword(),

                // ===== Form minta OTP =====
                const SizedBox(height: 40),
                FormGetToken(
                  emailController: emailController,
                  formKey: _formGetTokenKey,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: ButtonGetToken(
                      loading: _loadingRequest,
                      onPressed: _handleRequestToken,
                    ),
                  ),
                ),

                // ===== Form reset password (OTP + password) =====
                FormResetPassword(
                  formKey: _formResetKey,
                  tokenController: tokenController,
                  passwordController: passwordController,
                  obscureText: _obscureText,
                  onToggle: _onToggle,
                ),
                SizedBox(height: 20),
                ButtonResetPassword(
                  loading: _loadingConfirm,
                  onPressed: _handleConfirmReset,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
