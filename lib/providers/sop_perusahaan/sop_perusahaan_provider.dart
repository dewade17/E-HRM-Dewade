import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:e_hrm/dto/sop_perusahaan/sop_perushaan.dart' as sop_dto;
import 'package:e_hrm/dto/sop_perusahaan/pinned_sop.dart';

class SopPerusahaanProvider extends ChangeNotifier {
  SopPerusahaanProvider();

  final ApiService _api = ApiService();

  bool loadingSop = false;
  String? errorSop;

  List<sop_dto.Item> sopItems = <sop_dto.Item>[];
  int sopTotal = 0;

  bool loadingPinned = false;
  bool mutatingPin = false;
  String? errorPinned;

  List<PinnedSopDto> pinnedItems = <PinnedSopDto>[];
  final Set<String> pinnedSopIds = <String>{};

  Future<bool> fetchAllSop({
    String? search,
    String? kategoriId,
    bool includeDeleted = false,
    bool deletedOnly = false,
    String orderBy = 'created_at',
    String sort = 'desc',
  }) async {
    loadingSop = true;
    errorSop = null;
    notifyListeners();

    var success = true;

    try {
      final qp = <String, String>{
        'all': 'true',
        'includeDeleted': includeDeleted ? 'true' : 'false',
        'deletedOnly': deletedOnly ? 'true' : 'false',
      };

      final trimmedSearch = (search ?? '').trim();
      if (trimmedSearch.isNotEmpty) qp['search'] = trimmedSearch;

      final trimmedKategori = (kategoriId ?? '').trim();
      if (trimmedKategori.isNotEmpty) qp['id_kategori_sop'] = trimmedKategori;

      final trimmedOrderBy = orderBy.trim();
      if (trimmedOrderBy.isNotEmpty) qp['orderBy'] = trimmedOrderBy;

      final trimmedSort = sort.trim().toLowerCase();
      qp['sort'] = trimmedSort == 'asc' ? 'asc' : 'desc';

      final uri = Uri.parse(
        Endpoints.sopPerusahaan,
      ).replace(queryParameters: qp);
      final res = await _api.fetchDataPrivate(uri.toString());

      final rawItems = res['items'];
      final items = rawItems is List
          ? rawItems
                .map<sop_dto.Item>(
                  (e) => sop_dto.Item.fromJson(_sanitizeSopItemJson(e)),
                )
                .toList()
          : <sop_dto.Item>[];

      final totalRaw = res['total'];
      final total = totalRaw is num ? totalRaw.toInt() : items.length;

      sopItems = items;
      sopTotal = total;
    } catch (e) {
      success = false;
      errorSop = e.toString();
    } finally {
      loadingSop = false;
      notifyListeners();
    }

    return success;
  }

  Future<bool> fetchPinnedSop() async {
    loadingPinned = true;
    errorPinned = null;
    notifyListeners();

    var success = true;

    try {
      final res = await _api.fetchDataPrivate(Endpoints.favouritePinSop);

      final rawData = res['data'];
      final rows = rawData is List ? rawData : const <dynamic>[];

      final parsed = <PinnedSopDto>[];
      final ids = <String>{};

      for (final r in rows) {
        final p = PinnedSopDto.fromAny(r);
        parsed.add(p);
        if (p.idSop.isNotEmpty) ids.add(p.idSop);
      }

      pinnedItems = parsed;
      pinnedSopIds
        ..clear()
        ..addAll(ids);
    } catch (e) {
      success = false;
      errorPinned = e.toString();
    } finally {
      loadingPinned = false;
      notifyListeners();
    }

    return success;
  }

  bool isPinned(String sopId) => pinnedSopIds.contains(sopId.trim());

  Future<bool> pinSop(String idSop) async {
    final sopId = idSop.trim();
    if (sopId.isEmpty) {
      errorPinned = 'id_sop kosong.';
      notifyListeners();
      return false;
    }

    mutatingPin = true;
    errorPinned = null;
    notifyListeners();

    var success = true;

    try {
      final res = await _api.postDataPrivate(Endpoints.favouritePinSop, {
        'id_sop': sopId,
      });
      final raw = res['data'];

      if (raw != null) {
        final dto = PinnedSopDto.fromAny(raw);

        pinnedSopIds.add(sopId);

        final idx = pinnedItems.indexWhere((x) => x.idSop == sopId);
        if (idx >= 0) {
          pinnedItems[idx] = dto;
        } else {
          pinnedItems = <PinnedSopDto>[dto, ...pinnedItems];
        }
      } else {
        pinnedSopIds.add(sopId);
      }
    } catch (e) {
      success = false;
      errorPinned = e.toString();
    } finally {
      mutatingPin = false;
      notifyListeners();
    }

    return success;
  }

  Future<bool> unpinSop(String idSop) async {
    final sopId = idSop.trim();
    if (sopId.isEmpty) {
      errorPinned = 'id_sop kosong.';
      notifyListeners();
      return false;
    }

    mutatingPin = true;
    errorPinned = null;
    notifyListeners();

    var success = true;

    try {
      final uri = Uri.parse(
        Endpoints.favouritePinSop,
      ).replace(queryParameters: {'id_sop': sopId});
      await _api.deleteDataPrivate(uri.toString());

      pinnedSopIds.remove(sopId);
      pinnedItems = pinnedItems.where((x) => x.idSop != sopId).toList();
    } catch (e) {
      success = false;
      errorPinned = e.toString();
    } finally {
      mutatingPin = false;
      notifyListeners();
    }

    return success;
  }

  void clearErrors() {
    errorSop = null;
    errorPinned = null;
    notifyListeners();
  }

  void reset() {
    loadingSop = false;
    errorSop = null;
    sopItems = <sop_dto.Item>[];
    sopTotal = 0;

    loadingPinned = false;
    mutatingPin = false;
    errorPinned = null;
    pinnedItems = <PinnedSopDto>[];
    pinnedSopIds.clear();

    notifyListeners();
  }

  static const String _fallbackIsoUtc = '1970-01-01T00:00:00.000Z';

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _sanitizeKategoriJson(dynamic raw) {
    final m = _asMap(raw);
    return <String, dynamic>{
      'id_kategori_sop': (m['id_kategori_sop'] ?? '').toString(),
      'nama_kategori': (m['nama_kategori'] ?? '').toString(),
    };
  }

  Map<String, dynamic> _sanitizeSopItemJson(dynamic raw) {
    final m = _asMap(raw);

    String s(dynamic v) => (v == null) ? '' : v.toString();
    String iso(dynamic v) {
      if (v == null) return _fallbackIsoUtc;
      final str = v.toString().trim();
      return str.isEmpty ? _fallbackIsoUtc : str;
    }

    final kategori = _sanitizeKategoriJson(m['kategori_sop']);

    return <String, dynamic>{
      'id_sop_karyawan': s(m['id_sop_karyawan']),
      'nama_dokumen': s(m['nama_dokumen']),
      'lampiran_sop_url': s(m['lampiran_sop_url']),
      'deskripsi': s(m['deskripsi']),
      'id_kategori_sop': s(m['id_kategori_sop']),
      'created_by_snapshot_nama_pengguna': s(
        m['created_by_snapshot_nama_pengguna'],
      ),
      'created_at': iso(m['created_at']),
      'updated_at': iso(m['updated_at']),
      'deleted_at': m['deleted_at'],
      'kategori_sop': kategori,
    };
  }
}
