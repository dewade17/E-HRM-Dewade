import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika input kosong, kembalikan kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Bersihkan semua karakter selain angka
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Jika setelah dibersihkan ternyata kosong (misal user paste text), kembalikan kosong
    if (newText.isEmpty) return newValue;

    // 2. Format angka menjadi ribuan (contoh: 10000 -> 10.000)
    final String formatted = _formatNumber(newText);

    // 3. Kembalikan value baru dengan kursor diletakkan di paling akhir
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Fungsi helper regex untuk menambahkan titik setiap 3 digit
  String _formatNumber(String s) {
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
