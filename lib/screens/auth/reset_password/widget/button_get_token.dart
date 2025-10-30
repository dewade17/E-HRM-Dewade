// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';

class ButtonGetToken extends StatefulWidget {
  final bool loading;
  final VoidCallback onPressed;
  final int cooldownSeconds;

  const ButtonGetToken({
    super.key,
    required this.loading,
    required this.onPressed,
    this.cooldownSeconds = 15,
  });

  @override
  State<ButtonGetToken> createState() => _ButtonGetTokenState();
}

class _ButtonGetTokenState extends State<ButtonGetToken> {
  Timer? _timer;
  int _remaining = 0;

  bool get _coolingDown => _remaining > 0;

  void _startCooldown() {
    setState(() => _remaining = widget.cooldownSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _remaining--;
        if (_remaining <= 0) t.cancel();
      });
    });
  }

  void _handlePressed() {
    if (widget.loading || _coolingDown) return;
    widget.onPressed();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.loading || _coolingDown;

    return SizedBox(
      width: 130,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: disabled ? null : _handlePressed,
        child: widget.loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                _coolingDown
                    ? "Kirim lagi (${_remaining}detik)"
                    : "Kirim Token",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.accentColor,
                ),
              ),
      ),
    );
  }
}
