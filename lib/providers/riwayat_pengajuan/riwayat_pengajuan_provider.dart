import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pengajuan_cuti/pengajuan_cuti.dart' as cuti;
import 'package:e_hrm/dto/pengajuan_izin_jam/pengajuan_izin_jam.dart'
    as izin_jam;
import 'package:e_hrm/dto/pengajuan_sakit/pengajuan_sakit.dart' as sakit;
import 'package:e_hrm/dto/pengajuan_tukar_hari/pengajuan_tukar_hari.dart'
    as tukar_hari;
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';

enum RiwayatPengajuanType { cuti, izinJam, tukarHari, sakit }

class RiwayatPengajuanItem {
  const RiwayatPengajuanItem({
    required this.id,
    required this.jenisPengajuan,
    required this.status,
    required this.type,
    this.tanggalMulai,
    this.tanggalBerakhir,
    this.originalData,
  });

  final String id;
  final String jenisPengajuan;
  final String status;
  final RiwayatPengajuanType type;
  final DateTime? tanggalMulai;
  final DateTime? tanggalBerakhir;
  final Object? originalData;

  String get displayJenis =>
      jenisPengajuan.isNotEmpty ? jenisPengajuan : _defaultJenisLabel(type);

  RiwayatPengajuanType get resolvedType =>
      _detectTypeFromJenis(jenisPengajuan) ?? type;

  cuti.Data? get cutiData =>
      originalData is cuti.Data ? originalData as cuti.Data : null;
  izin_jam.Data? get izinJamData =>
      originalData is izin_jam.Data ? originalData as izin_jam.Data : null;
  tukar_hari.Data? get tukarHariData =>
      originalData is tukar_hari.Data ? originalData as tukar_hari.Data : null;
  sakit.Data? get sakitData =>
      originalData is sakit.Data ? originalData as sakit.Data : null;

  static String _defaultJenisLabel(RiwayatPengajuanType type) {
    switch (type) {
      case RiwayatPengajuanType.cuti:
        return 'Cuti';
      case RiwayatPengajuanType.izinJam:
        return 'Izin jam';
      case RiwayatPengajuanType.tukarHari:
        return 'Tukar Hari';
      case RiwayatPengajuanType.sakit:
        return 'Sakit';
    }
  }

  static RiwayatPengajuanType? _detectTypeFromJenis(String? jenis) {
    if (jenis == null || jenis.isEmpty) return null;
    final normalized = jenis.toLowerCase();

    if (normalized.contains('cuti')) return RiwayatPengajuanType.cuti;
    if (normalized.contains('izin jam')) return RiwayatPengajuanType.izinJam;
    if (normalized.contains('tukar')) return RiwayatPengajuanType.tukarHari;
    if (normalized.contains('sakit')) return RiwayatPengajuanType.sakit;

    return null;
  }
}

class RiwayatPengajuanProvider extends ChangeNotifier {
  RiwayatPengajuanProvider();

  final ApiService _api = ApiService();

  bool loading = false;
  String? error;
  List<RiwayatPengajuanItem> items = <RiwayatPengajuanItem>[];

  String? _statusFilter;
  String? _jenisFilter;

  Future<void> fetch({String? status, String? jenis}) async {
    _statusFilter = _normalizeStatus(status);
    _jenisFilter = jenis;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final List<RiwayatPengajuanItem> results = <RiwayatPengajuanItem>[];
      final String? statusParam = _statusFilter;

      if (_shouldLoadType(RiwayatPengajuanType.cuti)) {
        results.addAll(await _fetchCuti(statusParam));
      }
      if (_shouldLoadType(RiwayatPengajuanType.izinJam)) {
        results.addAll(await _fetchIzinJam(statusParam));
      }
      if (_shouldLoadType(RiwayatPengajuanType.tukarHari)) {
        results.addAll(await _fetchTukarHari(statusParam));
      }
      if (_shouldLoadType(RiwayatPengajuanType.sakit)) {
        results.addAll(await _fetchSakit(statusParam));
      }

      results.sort((a, b) {
        final DateTime aDate =
            a.tanggalMulai ??
            a.tanggalBerakhir ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bDate =
            b.tanggalMulai ??
            b.tanggalBerakhir ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      items = results;
    } catch (e) {
      error = e.toString();
      items = <RiwayatPengajuanItem>[];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  bool _shouldLoadType(RiwayatPengajuanType type) {
    final jenis = _jenisFilter?.toLowerCase();
    if (jenis == null || jenis.isEmpty || jenis == 'semua') return true;

    switch (type) {
      case RiwayatPengajuanType.cuti:
        return jenis.contains('cuti');
      case RiwayatPengajuanType.izinJam:
        return jenis.contains('izin jam');
      case RiwayatPengajuanType.tukarHari:
        return jenis.contains('tukar');
      case RiwayatPengajuanType.sakit:
        return jenis.contains('sakit');
    }
  }

  Future<List<RiwayatPengajuanItem>> _fetchCuti(String? status) async {
    final uri = Uri.parse(Endpoints.pengajuanCuti).replace(
      queryParameters: <String, String>{
        'page': '1',
        'perPage': '50',
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final Map<String, dynamic> response = await _api.fetchDataPrivate(
      uri.toString(),
    );

    final List<dynamic> rawItems =
        (response['data'] as List<dynamic>?) ?? <dynamic>[];
    return rawItems
        .map((dynamic entry) {
          if (entry is cuti.Data) return entry;
          if (entry is Map<String, dynamic>) return cuti.Data.fromJson(entry);
          return cuti.Data.fromJson(Map<String, dynamic>.from(entry as Map));
        })
        .map(_mapCutiToRiwayat)
        .toList(growable: false);
  }

  Future<List<RiwayatPengajuanItem>> _fetchIzinJam(String? status) async {
    final uri = Uri.parse(Endpoints.pengajuanIzinJam).replace(
      queryParameters: <String, String>{
        'page': '1',
        'pageSize': '50',
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final Map<String, dynamic> response = await _api.fetchDataPrivate(
      uri.toString(),
    );

    final List<dynamic> rawItems =
        (response['data'] as List<dynamic>?) ?? <dynamic>[];
    return rawItems
        .map((dynamic entry) {
          if (entry is izin_jam.Data) return entry;
          if (entry is Map<String, dynamic>)
            return izin_jam.Data.fromJson(entry);
          return izin_jam.Data.fromJson(
            Map<String, dynamic>.from(entry as Map),
          );
        })
        .map(_mapIzinJamToRiwayat)
        .toList(growable: false);
  }

  Future<List<RiwayatPengajuanItem>> _fetchTukarHari(String? status) async {
    final uri = Uri.parse(Endpoints.pengajuanIzinTukarHari).replace(
      queryParameters: <String, String>{
        'page': '1',
        'perPage': '50',
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final Map<String, dynamic> response = await _api.fetchDataPrivate(
      uri.toString(),
    );

    final List<dynamic> rawItems =
        (response['data'] as List<dynamic>?) ?? <dynamic>[];
    return rawItems
        .map((dynamic entry) {
          if (entry is tukar_hari.Data) return entry;
          if (entry is Map<String, dynamic>)
            return tukar_hari.Data.fromJson(entry);
          return tukar_hari.Data.fromJson(
            Map<String, dynamic>.from(entry as Map),
          );
        })
        .map(_mapTukarHariToRiwayat)
        .toList(growable: false);
  }

  Future<List<RiwayatPengajuanItem>> _fetchSakit(String? status) async {
    final uri = Uri.parse(Endpoints.pengajuanSakit).replace(
      queryParameters: <String, String>{
        'page': '1',
        'pageSize': '50',
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final Map<String, dynamic> response = await _api.fetchDataPrivate(
      uri.toString(),
    );

    final List<dynamic> rawItems =
        (response['data'] as List<dynamic>?) ?? <dynamic>[];
    return rawItems
        .map((dynamic entry) {
          if (entry is sakit.Data) return entry;
          if (entry is Map<String, dynamic>) return sakit.Data.fromJson(entry);
          return sakit.Data.fromJson(Map<String, dynamic>.from(entry as Map));
        })
        .map(_mapSakitToRiwayat)
        .toList(growable: false);
  }

  RiwayatPengajuanItem _mapCutiToRiwayat(cuti.Data data) {
    final DateTime? startDate =
        data.tanggalCuti ??
        (data.tanggalList.isNotEmpty ? data.tanggalList.first : null);
    final DateTime? endDate =
        data.tanggalSelesai ??
        (data.tanggalList.isNotEmpty ? data.tanggalList.last : startDate);
    return RiwayatPengajuanItem(
      id: data.idPengajuanCuti,
      jenisPengajuan: data.jenisPengajuan,
      status: data.status,
      type: RiwayatPengajuanType.cuti,
      tanggalMulai: startDate,
      tanggalBerakhir: endDate,
      originalData: data,
    );
  }

  RiwayatPengajuanItem _mapIzinJamToRiwayat(izin_jam.Data data) {
    return RiwayatPengajuanItem(
      id: data.idPengajuanIzinJam,
      jenisPengajuan: data.jenisPengajuan,
      status: data.status,
      type: RiwayatPengajuanType.izinJam,
      tanggalMulai: data.tanggalIzin,
      tanggalBerakhir: data.tanggalPengganti ?? data.tanggalIzin,
      originalData: data,
    );
  }

  RiwayatPengajuanItem _mapTukarHariToRiwayat(tukar_hari.Data data) {
    final tukar_hari.Pair? firstPair = data.pairs.isNotEmpty
        ? data.pairs.first
        : null;
    return RiwayatPengajuanItem(
      id: data.idIzinTukarHari,
      jenisPengajuan: data.jenisPengajuan,
      status: data.status,
      type: RiwayatPengajuanType.tukarHari,
      tanggalMulai: firstPair?.hariIzin,
      tanggalBerakhir: firstPair?.hariPengganti ?? firstPair?.hariIzin,
      originalData: data,
    );
  }

  RiwayatPengajuanItem _mapSakitToRiwayat(sakit.Data data) {
    return RiwayatPengajuanItem(
      id: data.idPengajuanIzinSakit,
      jenisPengajuan: data.jenisPengajuan,
      status: data.status,
      type: RiwayatPengajuanType.sakit,
      tanggalMulai: data.tanggalPengajuan,
      tanggalBerakhir: data.tanggalPengajuan,
      originalData: data,
    );
  }

  String? _normalizeStatus(String? status) {
    if (status == null) return null;
    final lower = status.toLowerCase();
    if (lower.contains('semua')) return null;
    if (lower.contains('menunggu')) return 'pending';
    if (lower.contains('disetujui')) return 'disetujui';
    if (lower.contains('ditolak')) return 'ditolak';
    return status;
  }
}
