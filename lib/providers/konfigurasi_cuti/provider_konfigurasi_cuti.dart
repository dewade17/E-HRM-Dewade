// lib/providers/konfigurasi_cuti/provider_konfigurasi_cuti.dart
import 'package:flutter/foundation.dart';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/konfigurasi_cuti/konfigurasi_cuti.dart'
    as konfigurasi;
import 'package:e_hrm/services/api_services.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';

class KonfigurasiCutiProvider extends ChangeNotifier {
  KonfigurasiCutiProvider();

  final ApiService _api = ApiService();

  static const List<String> availableMonths = <String>[
    'JANUARI',
    'FEBRUARI',
    'MARET',
    'APRIL',
    'MEI',
    'JUNI',
    'JULI',
    'AGUSTUS',
    'SEPTEMBER',
    'OKTOBER',
    'NOVEMBER',
    'DESEMBER',
  ];

  static final Set<String> _validMonths = Set<String>.from(availableMonths);

  static final Map<String, int> _monthOrder = <String, int>{
    for (int index = 0; index < availableMonths.length; index++)
      availableMonths[index]: index,
  };

  bool loading = false;
  String? error;

  List<konfigurasi.Data> items = <konfigurasi.Data>[];
  konfigurasi.Meta? meta;
  String? statusCuti;

  String? _lastUserId;
  final List<String> _lastMonths = <String>[];
  final Map<String, konfigurasi.Data> _byMonth = <String, konfigurasi.Data>{};

  List<String> get monthNames => List<String>.unmodifiable(availableMonths);
  List<String> get currentMonths => List<String>.unmodifiable(_lastMonths);
  String? get currentUserId => _lastUserId;
  int get total => meta?.total ?? items.length;
  bool get hasFilter => _lastMonths.isNotEmpty;

  Map<String, konfigurasi.Data> get dataByMonth =>
      Map<String, konfigurasi.Data>.unmodifiable(_byMonth);

  konfigurasi.Data? findByMonth(String month) {
    final normalized = month.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    return _byMonth[normalized];
  }

  bool isValidMonth(String value) =>
      _validMonths.contains(value.trim().toUpperCase());

  // --- LOGIKA BARU PINDAHAN DARI FORM (SARAN #2) ---

  /// Menghitung total kuota yang tersedia (cuti + tabung jika aktif)
  /// Mengembalikan null jika data belum dimuat.
  int? get availableQuota {
    if (items.isEmpty) return null;

    final latestData = items.last;
    final String rawStatus = statusCuti?.trim().toLowerCase() ?? '';
    final bool statusActive = rawStatus == 'aktif';

    int available = latestData.koutaCuti;
    if (statusActive) {
      available += latestData.cutiTabung;
    }
    return available;
  }

  /// Menghitung sisa kuota berdasarkan kuota tersedia dan jumlah hari yang dipilih.
  /// [selectedDaysCount] = jumlah hari yang *saat ini* dipilih di form.
  /// [reducesQuota] = apakah kategori yang dipilih mengurangi kuota?
  int? getRemainingQuota({
    required int selectedDaysCount,
    required bool reducesQuota,
  }) {
    final currentAvailable = availableQuota;
    if (currentAvailable == null) return null; // Belum tahu kuota
    if (!reducesQuota)
      return currentAvailable; // Kategori tidak mengurangi kuota

    final int remaining = currentAvailable - selectedDaysCount;
    return remaining > 0 ? remaining : 0;
  }

  // --- AKHIR LOGIKA BARU ---

  Future<bool> fetch({String? idUser, Iterable<String>? months}) async {
    final resolvedUserId = await _resolveUserId(idUser);
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      error =
          'ID pengguna tidak ditemukan. Pastikan sudah login sebelum memuat konfigurasi cuti.';
      notifyListeners();
      return false;
    }

    late final List<String> normalizedMonths;
    try {
      normalizedMonths = _normalizeMonths(months ?? _lastMonths);
    } on ArgumentError catch (e) {
      error = e.message?.toString() ?? e.toString();
      notifyListeners();
      return false;
    }

    loading = true;
    error = null;
    notifyListeners();

    var success = true;
    try {
      final baseUri = Uri.parse(Endpoints.konfigurasiCuti(resolvedUserId));
      final uri = normalizedMonths.isEmpty
          ? baseUri
          : baseUri.replace(
              queryParameters: <String, String>{
                'bulan': normalizedMonths.join(','),
              },
            );

      final Map<String, dynamic> response = await _api.fetchDataPrivate(
        uri.toString(),
      );
      final konfigurasi.KonfigurasiCuti parsed =
          konfigurasi.KonfigurasiCuti.fromJson(response);

      if (!parsed.ok) {
        success = false;
        final dynamic message = response['message'];
        error = message is String && message.trim().isNotEmpty
            ? message.trim()
            : 'Gagal memuat konfigurasi cuti.';
      } else {
        final List<konfigurasi.Data> sortedData = List<konfigurasi.Data>.from(
          parsed.data,
        );
        sortedData.sort((konfigurasi.Data a, konfigurasi.Data b) {
          final int indexA =
              _monthOrder[a.bulan.trim().toUpperCase()] ??
              availableMonths.length;
          final int indexB =
              _monthOrder[b.bulan.trim().toUpperCase()] ??
              availableMonths.length;
          return indexA.compareTo(indexB);
        });

        items = sortedData;
        meta = parsed.meta;
        statusCuti = parsed.statusCuti;
        _lastUserId = resolvedUserId;
        _lastMonths
          ..clear()
          ..addAll(normalizedMonths);
        _byMonth
          ..clear()
          ..addEntries(
            sortedData.map(
              (konfigurasi.Data item) =>
                  MapEntry(item.bulan.trim().toUpperCase(), item),
            ),
          );
      }
    } catch (e) {
      success = false;
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }

    return success;
  }

  Future<bool> refresh() =>
      fetch(idUser: _lastUserId, months: List<String>.from(_lastMonths));

  Future<bool> applyMonthFilter(Iterable<String> months) =>
      fetch(idUser: _lastUserId, months: List<String>.from(months));

  Future<bool> setUser(String idUser) =>
      fetch(idUser: idUser, months: List<String>.from(_lastMonths));

  void reset() {
    loading = false;
    error = null;
    items = <konfigurasi.Data>[];
    meta = null;
    statusCuti = null;
    _lastUserId = null;
    _lastMonths.clear();
    _byMonth.clear();
    notifyListeners();
  }

  Future<String?> _resolveUserId(String? idUser) async {
    final String? trimmedProvided = idUser?.trim();
    if (trimmedProvided != null && trimmedProvided.isNotEmpty) {
      return trimmedProvided;
    }
    final String? cached = _lastUserId?.trim();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final String? stored = await loadUserIdFromPrefs();
    if (stored != null) {
      final String normalized = stored.trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }

  List<String> _normalizeMonths(Iterable<String> values) {
    final List<String> normalized = <String>[];
    final Set<String> seen = <String>{};

    for (final String value in values) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) continue;

      final String upper = trimmed.toUpperCase();
      if (!_validMonths.contains(upper)) {
        throw ArgumentError.value(
          value,
          'months',
          'Nilai bulan tidak valid. Gunakan salah satu dari ${availableMonths.join(', ')}.',
        );
      }
      if (seen.add(upper)) {
        normalized.add(upper);
      }
    }

    if (normalized.isEmpty) {
      return const <String>[];
    }

    final List<String> sorted = List<String>.from(normalized);
    sorted.sort((String a, String b) {
      final int indexA = _monthOrder[a] ?? availableMonths.length;
      final int indexB = _monthOrder[b] ?? availableMonths.length;
      return indexA.compareTo(indexB);
    });
    return sorted;
  }
}
