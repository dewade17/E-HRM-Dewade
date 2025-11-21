// lib/utils/mention_parser.dart
import 'dart:core';

/// Kelas utilitas untuk menangani parsing markup mention.
/// Pola yang diharapkan: @[__Nama Tampilan__](__ID_PENGGUNA__)
class MentionParser {
  // Pola: @[__DISPLAY_NAME__](__ID__)
  // group(1) = @
  // group(2) = DISPLAY_NAME
  // group(3) = ID
  static final RegExp _mentionMarkupRegex = RegExp(
    r'([@#])\[__(.*?)__\]\(__(.*?)__\)',
  );

  // Regex untuk memvalidasi apakah sebuah string adalah UUID
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  /// Memeriksa apakah sebuah string terlihat seperti UUID.
  static bool _looksLikeUuid(String value) {
    return _uuidRegex.hasMatch(value.trim());
  }

  /// Memilih ID terbaik dari dua grup yang ditangkap regex.
  /// Ini untuk menangani jika ID dan display name tertukar.
  static String _pickBestMentionId(String displayName, String id) {
    // Bersihkan karakter "__" yang mungkin terbawa
    final String a = id.trim().replaceAll(RegExp(r'_'), '');
    final String b = displayName.trim().replaceAll(RegExp(r'_'), '');

    final bool aIsUuid = _looksLikeUuid(a);
    final bool bIsUuid = _looksLikeUuid(b);

    if (aIsUuid) return a; // Prioritaskan ID (dari group 3)
    if (bIsUuid) return b; // Fallback jika ID ada di group 2

    // Fallback jika tidak ada UUID
    if (a.isNotEmpty && !a.contains(' ')) return a;
    if (b.isNotEmpty && !b.contains(' ')) return b;
    return a.isNotEmpty ? a : b;
  }

  /// Mengekstrak semua ID pengguna yang unik dari teks markup handover.
  static List<String> extractMentionedUserIds(String markup) {
    if (markup.isEmpty) return const <String>[];

    final Set<String> ids = <String>{};
    for (final match in _mentionMarkupRegex.allMatches(markup)) {
      final String candidate = _pickBestMentionId(
        match.group(2) ?? '', // display name
        match.group(3) ?? '', // id
      );
      if (candidate.isNotEmpty) {
        ids.add(candidate);
      }
    }
    return ids.toList(growable: false);
  }

  /// Mengonversi teks markup (e.g., @[__Nama__](__ID__)) menjadi teks tampilan (e.g., @Nama).
  static String convertMarkupToDisplay(String markup) {
    if (markup.isEmpty) return '';
    return markup.replaceAllMapped(_mentionMarkupRegex, (match) {
      final String trigger = match.group(1) ?? ''; // @ atau #

      final String display = match.group(3) ?? '';

      return '$trigger$display';
    });
  }
}
