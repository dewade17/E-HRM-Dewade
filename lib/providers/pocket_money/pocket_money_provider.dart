import 'dart:convert';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/pocket_money/pocket_money.dart' as dto;
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PocketMoneyProvider extends ChangeNotifier {
  PocketMoneyProvider();

  final ApiService _api = ApiService();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  // ============================ Endpoints ============================

  String get _listEndpoint => Endpoints.pocketMoney;
  String _detailEndpoint(String id) => Endpoints.pocketMoneyDetail(id);

  // ============================ List State ============================

  bool loading = false;
  String? error;

  final List<dto.Data> items = <dto.Data>[];
  dto.Meta? meta;

  int page = 1;
  int perPage = 20;

  // Filters
  String? status; // pending | disetujui | ditolak
  String? idDepartement;
  String? idUser;
  String? q;
  bool all = false;
  DateTime? tanggalFrom;
  DateTime? tanggalTo;

  bool get canLoadMore {
    final m = meta;
    if (m == null) return false;
    return m.page < m.totalPages;
  }

  // ============================ Public Helpers ============================

  void reset() {
    loading = false;
    error = null;
    items.clear();
    meta = null;
    page = 1;
    notifyListeners();
  }

  void setFilters({
    String? status,
    String? idDepartement,
    String? idUser,
    String? q,
    bool? all,
    DateTime? tanggalFrom,
    DateTime? tanggalTo,
    bool resetList = true,
  }) {
    this.status = status;
    this.idDepartement = idDepartement;
    this.idUser = idUser;
    this.q = q;
    if (all != null) this.all = all;

    this.tanggalFrom = tanggalFrom;
    this.tanggalTo = tanggalTo;

    if (resetList) {
      reset();
    } else {
      notifyListeners();
    }
  }

  Future<bool> refresh({int? perPage}) async {
    reset();
    return fetch(page: 1, perPage: perPage ?? this.perPage, append: false);
  }

  Future<bool> loadMore() async {
    if (loading) return false;
    if (!canLoadMore) return false;

    final nextPage = (meta?.page ?? page) + 1;
    return fetch(page: nextPage, perPage: perPage, append: true);
  }

  Future<bool> fetch({int? page, int? perPage, bool append = false}) async {
    var requestedPage = page ?? this.page;
    if (requestedPage < 1) requestedPage = 1;

    var requestedPerPage = perPage ?? this.perPage;
    if (requestedPerPage < 1) requestedPerPage = 1;
    if (requestedPerPage > 100) requestedPerPage = 100;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(_listEndpoint).replace(
        queryParameters: _buildQueryParameters(requestedPage, requestedPerPage),
      );

      final Map<String, dynamic> response = await _api.fetchDataPrivate(
        uri.toString(),
      );

      final dto.Meta? parsedMeta = _parseMeta(response['meta']);
      final List<dto.Data> parsedItems = _parseList(response['data']);

      if (!append) {
        items
          ..clear()
          ..addAll(parsedItems);
      } else {
        for (final it in parsedItems) {
          _upsertItem(it);
        }
      }

      meta = parsedMeta;
      this.page = parsedMeta?.page ?? requestedPage;
      this.perPage = parsedMeta?.perPage ?? requestedPerPage;

      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Map<String, String> _buildQueryParameters(int page, int perPage) {
    final qp = <String, String>{
      'page': page.toString(),
      'perPage': perPage.toString(),
    };

    final normalizedStatus = (status ?? '').trim().toLowerCase();
    if (normalizedStatus.isNotEmpty) qp['status'] = normalizedStatus;

    if (all) qp['all'] = 'true';

    final dept = (idDepartement ?? '').trim();
    if (dept.isNotEmpty) qp['id_departement'] = dept;

    final user = (idUser ?? '').trim();
    if (user.isNotEmpty) qp['id_user'] = user;

    final query = (q ?? '').trim();
    if (query.isNotEmpty) qp['q'] = query;

    if (tanggalFrom != null) {
      qp['tanggal_from'] = _dateFormatter.format(tanggalFrom!);
    }
    if (tanggalTo != null) {
      qp['tanggal_to'] = _dateFormatter.format(tanggalTo!);
    }

    return qp;
  }

  void _upsertItem(dto.Data item) {
    final index = items.indexWhere(
      (it) => it.idPocketMoney == item.idPocketMoney,
    );
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
  }

  // ============================ Detail State ============================

  dto.Data? detail;
  bool detailLoading = false;
  String? detailError;

  Future<dto.Data?> fetchDetail(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;

    detailLoading = true;
    detailError = null;
    notifyListeners();

    try {
      final Map<String, dynamic> response = await _api.fetchDataPrivate(
        _detailEndpoint(trimmed),
      );

      final dto.Data? parsed = _parseSingle(response['data']);
      detail = parsed;

      detailLoading = false;
      if (parsed != null) _upsertItem(parsed);

      notifyListeners();
      return parsed;
    } catch (e) {
      detailLoading = false;
      detailError = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============================ Save/Delete State ============================

  bool saving = false;
  String? saveMessage;
  String? saveError;

  bool deleting = false;
  String? deleteError;

  void _startSaving() {
    saving = true;
    saveMessage = null;
    saveError = null;
    notifyListeners();
  }

  // ============================ CREATE ============================

  Future<dto.Data?> createPocketMoney({
    String? idDepartement,
    String? idKategoriKeperluan,
    required DateTime tanggal,
    required String metodePembayaran,
    String? keterangan,
    String? nomorRekening,
    String? namaPemilikRekening,
    String? jenisBank,
    String? buktiPembayaranUrl,
    http.MultipartFile? buktiPembayaranFile,
    List<Map<String, dynamic>>? items,
    String? totalPengeluaran,
    ApproversPengajuanProvider? approversProvider,
    List<Map<String, dynamic>>? approvals, // pass [] untuk clear
    Map<String, dynamic>? additionalFields,
  }) async {
    _startSaving();

    final payload = <String, dynamic>{
      'tanggal': _dateFormatter.format(tanggal),
      'metode_pembayaran': metodePembayaran.trim(),
    };

    final dept = (idDepartement ?? '').trim();
    if (dept.isNotEmpty) payload['id_departement'] = dept;

    final kategori = (idKategoriKeperluan ?? '').trim();
    if (kategori.isNotEmpty) payload['id_kategori_keperluan'] = kategori;

    if (keterangan != null) payload['keterangan'] = keterangan;

    if (nomorRekening != null) payload['nomor_rekening'] = nomorRekening;
    if (namaPemilikRekening != null)
      payload['nama_pemilik_rekening'] = namaPemilikRekening;
    if (jenisBank != null) payload['jenis_bank'] = jenisBank;

    if (buktiPembayaranUrl != null)
      payload['bukti_pembayaran_url'] = buktiPembayaranUrl;

    final normalizedItems = _normalizeItems(items);
    if (normalizedItems != null) payload['items'] = jsonEncode(normalizedItems);

    final total = _normalizeMoneyOrNull(totalPengeluaran);
    if (total != null) payload['total_pengeluaran'] = total;

    if (additionalFields != null) payload.addAll(additionalFields);

    final List<http.MultipartFile> files = <http.MultipartFile>[];
    if (buktiPembayaranFile != null) files.add(buktiPembayaranFile);

    final List<Map<String, dynamic>> approvalList =
        approvals ?? _buildApprovalsFromProvider(approversProvider);

    final bool approvalsExplicit =
        approvals != null || approversProvider != null;
    if (approvalsExplicit) payload['approvals'] = jsonEncode(approvalList);

    try {
      final Map<String, dynamic> response = await _api.postFormDataPrivate(
        _listEndpoint,
        payload,
        files: files.isEmpty ? null : files,
      );

      final dto.Data? created = _parseSingle(response['data']);
      if (created != null) _upsertItem(created);

      saveMessage =
          response['message']?.toString() ?? 'Berhasil membuat pocket money.';
      saving = false;
      notifyListeners();
      return created;
    } catch (e) {
      saving = false;
      saveError = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============================ UPDATE ============================

  Future<dto.Data?> updatePocketMoney(
    String id, {
    DateTime? tanggal,
    String? keterangan,
    String? idKategoriKeperluan,
    String? metodePembayaran,
    String? nomorRekening,
    String? namaPemilikRekening,
    String? jenisBank,
    String? buktiPembayaranUrl,
    http.MultipartFile? buktiPembayaranFile,
    List<Map<String, dynamic>>? items,
    String? totalPengeluaran,
    ApproversPengajuanProvider? approversProvider,
    List<Map<String, dynamic>>? approvals, // pass [] untuk clear
    Map<String, dynamic>? additionalFields,
  }) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    _startSaving();

    final payload = <String, dynamic>{};

    if (tanggal != null) payload['tanggal'] = _dateFormatter.format(tanggal);
    if (keterangan != null) payload['keterangan'] = keterangan;

    if (idKategoriKeperluan != null) {
      payload['id_kategori_keperluan'] = idKategoriKeperluan;
    }

    if (metodePembayaran != null)
      payload['metode_pembayaran'] = metodePembayaran;
    if (nomorRekening != null) payload['nomor_rekening'] = nomorRekening;
    if (namaPemilikRekening != null) {
      payload['nama_pemilik_rekening'] = namaPemilikRekening;
    }
    if (jenisBank != null) payload['jenis_bank'] = jenisBank;

    if (buktiPembayaranUrl != null)
      payload['bukti_pembayaran_url'] = buktiPembayaranUrl;

    final normalizedItems = _normalizeItems(items);
    if (normalizedItems != null) payload['items'] = jsonEncode(normalizedItems);

    if (totalPengeluaran != null) {
      final total = _normalizeMoneyOrNull(totalPengeluaran);
      if (total != null) payload['total_pengeluaran'] = total;
    }

    if (additionalFields != null) payload.addAll(additionalFields);

    final List<http.MultipartFile> files = <http.MultipartFile>[];
    if (buktiPembayaranFile != null) files.add(buktiPembayaranFile);

    final List<Map<String, dynamic>> approvalList =
        approvals ?? _buildApprovalsFromProvider(approversProvider);

    final bool approvalsExplicit =
        approvals != null || approversProvider != null;
    if (approvalsExplicit) payload['approvals'] = jsonEncode(approvalList);

    try {
      final Map<String, dynamic> response = await _api.putFormDataPrivate(
        _detailEndpoint(trimmedId),
        payload,
        files: files.isEmpty ? null : files,
      );

      final dto.Data? updated = _parseSingle(response['data']);
      if (updated != null) {
        _upsertItem(updated);
        if (detail?.idPocketMoney == updated.idPocketMoney) detail = updated;
      }

      saveMessage =
          response['message']?.toString() ??
          'Berhasil memperbarui pocket money.';
      saving = false;
      notifyListeners();
      return updated;
    } catch (e) {
      saving = false;
      saveError = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============================ DELETE ============================

  Future<bool> deletePocketMoney(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return false;

    deleting = true;
    deleteError = null;
    notifyListeners();

    try {
      final Map<String, dynamic> response = await _api.deleteDataPrivate(
        _detailEndpoint(trimmedId),
      );

      items.removeWhere((it) => it.idPocketMoney == trimmedId);
      if (detail?.idPocketMoney == trimmedId) detail = null;

      deleting = false;
      notifyListeners();
      return response['ok'] == true;
    } catch (e) {
      deleting = false;
      deleteError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================ Approvals Helpers ============================

  List<Map<String, dynamic>> _buildApprovalsFromProvider(
    ApproversPengajuanProvider? provider,
  ) {
    if (provider == null) return <Map<String, dynamic>>[];
    final selected = provider.selectedUsers
        .where((u) => u.idUser.trim().isNotEmpty)
        .toList(growable: false);
    if (selected.isEmpty) return <Map<String, dynamic>>[];

    return List<Map<String, dynamic>>.generate(selected.length, (index) {
      final user = selected[index];
      final role = (user.role).trim().toUpperCase();
      return <String, dynamic>{
        'approver_user_id': user.idUser,
        'approver_role': role,
        'level': index + 1,
      };
    });
  }

  // ============================ Items/Money Helpers ============================

  List<Map<String, dynamic>>? _normalizeItems(
    List<Map<String, dynamic>>? items,
  ) {
    if (items == null) return null; // not supplied
    if (items.isEmpty) return <Map<String, dynamic>>[];

    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      final nama =
          (it['nama_item_pocket_money'] ?? it['nama_item'] ?? it['nama'] ?? '')
              .toString()
              .trim();
      if (nama.isEmpty)
        throw ArgumentError('items[$i].nama_item_pocket_money wajib diisi.');

      final harga = _normalizeMoneyOrNull(it['harga']);
      if (harga == null)
        throw ArgumentError('items[$i].harga wajib berupa angka.');

      out.add(<String, dynamic>{
        'nama_item_pocket_money': nama,
        'harga': harga,
      });
    }
    return out;
  }

  String? _normalizeMoneyOrNull(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    final cleaned = raw
        .replaceAll('Rp', '')
        .replaceAll('rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '');

    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) return null;
    if (parsed < 0) return null;

    return parsed.toStringAsFixed(2);
  }

  // ============================ Parsing Helpers ============================

  dto.Meta? _parseMeta(dynamic raw) {
    if (raw == null) return null;
    if (raw is dto.Meta) return raw;
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('page') && raw.containsKey('totalPages')) {
        return dto.Meta.fromJson(raw);
      }
      for (final v in raw.values) {
        final parsed = _parseMeta(v);
        if (parsed != null) return parsed;
      }
    }
    if (raw is Map) return _parseMeta(Map<String, dynamic>.from(raw));
    return null;
  }

  List<dto.Data> _parseList(dynamic raw) {
    if (raw == null) return <dto.Data>[];
    if (raw is List) {
      final out = <dto.Data>[];
      for (final entry in raw) {
        final parsed = _parseSingle(entry);
        if (parsed != null) out.add(parsed);
      }
      return out;
    }
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data')) return _parseList(raw['data']);
      for (final v in raw.values) {
        final parsed = _parseList(v);
        if (parsed.isNotEmpty) return parsed;
      }
    }
    if (raw is Map) return _parseList(Map<String, dynamic>.from(raw));
    return <dto.Data>[];
  }

  dto.Data? _parseSingle(dynamic raw) {
    if (raw == null) return null;
    if (raw is dto.Data) return raw;

    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('id_pocket_money')) {
        final normalized = _normalizeDataJson(raw);
        return dto.Data.fromJson(normalized);
      }
      for (final v in raw.values) {
        final parsed = _parseSingle(v);
        if (parsed != null) return parsed;
      }
    }

    if (raw is Map) return _parseSingle(Map<String, dynamic>.from(raw));
    if (raw is List) {
      for (final v in raw) {
        final parsed = _parseSingle(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  Map<String, dynamic> _normalizeDataJson(Map<String, dynamic> json) {
    final nowIso = DateTime.now().toIso8601String();
    final normalized = <String, dynamic>{...json};

    String safeStr(dynamic v) => v == null ? '' : v.toString();
    int safeInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      final parsed = int.tryParse(v?.toString() ?? '');
      return parsed ?? fallback;
    }

    String safeIsoDate(dynamic v, {required String fallback}) {
      final s = v?.toString();
      if (s == null || s.trim().isEmpty || s.trim().toLowerCase() == 'null')
        return fallback;
      return s;
    }

    normalized['id_kategori_keperluan'] = safeStr(
      normalized['id_kategori_keperluan'],
    );
    normalized['keterangan'] = safeStr(normalized['keterangan']);
    normalized['total_pengeluaran'] = safeStr(normalized['total_pengeluaran']);
    normalized['metode_pembayaran'] = safeStr(normalized['metode_pembayaran']);
    normalized['nomor_rekening'] = safeStr(normalized['nomor_rekening']);
    normalized['nama_pemilik_rekening'] = safeStr(
      normalized['nama_pemilik_rekening'],
    );
    normalized['jenis_bank'] = safeStr(normalized['jenis_bank']);
    normalized['bukti_pembayaran_url'] = safeStr(
      normalized['bukti_pembayaran_url'],
    );
    normalized['status'] = safeStr(normalized['status']);
    normalized['current_level'] = safeInt(normalized['current_level'], 0);

    normalized['tanggal'] = safeIsoDate(
      normalized['tanggal'],
      fallback: nowIso,
    );
    normalized['created_at'] = safeIsoDate(
      normalized['created_at'],
      fallback: nowIso,
    );
    normalized['updated_at'] = safeIsoDate(
      normalized['updated_at'],
      fallback: nowIso,
    );

    final dept = normalized['departement'];
    if (dept is Map) {
      normalized['departement'] = <String, dynamic>{
        'id_departement': safeStr(dept['id_departement']),
        'nama_departement': safeStr(dept['nama_departement']),
      };
    } else {
      normalized['departement'] = <String, dynamic>{
        'id_departement': '',
        'nama_departement': '',
      };
    }

    final kategori = normalized['kategori_keperluan'];
    if (kategori is Map) {
      normalized['kategori_keperluan'] = <String, dynamic>{
        'id_kategori_keperluan': safeStr(kategori['id_kategori_keperluan']),
        'nama_keperluan': safeStr(kategori['nama_keperluan']),
      };
    } else {
      normalized['kategori_keperluan'] = <String, dynamic>{
        'id_kategori_keperluan': '',
        'nama_keperluan': '',
      };
    }

    final rawItems = normalized['items'];
    if (rawItems is List) {
      normalized['items'] = rawItems
          .where((e) => e != null)
          .map((e) {
            if (e is Map) {
              return <String, dynamic>{
                'id_pocket_money_item': safeStr(e['id_pocket_money_item']),
                'nama_item_pocket_money': safeStr(e['nama_item_pocket_money']),
                'harga': safeStr(e['harga']),
              };
            }
            return <String, dynamic>{
              'id_pocket_money_item': '',
              'nama_item_pocket_money': '',
              'harga': '0.00',
            };
          })
          .toList(growable: false);
    } else {
      normalized['items'] = <dynamic>[];
    }

    final rawApprovals = normalized['approvals'];
    if (rawApprovals is List) {
      normalized['approvals'] = rawApprovals
          .where((e) => e != null)
          .map((e) {
            if (e is Map) {
              final approver = e['approver'];
              final approverJson = approver is Map
                  ? <String, dynamic>{
                      'id_user': safeStr(approver['id_user']),
                      'nama_pengguna': safeStr(approver['nama_pengguna']),
                      'email': safeStr(approver['email']),
                      'role': safeStr(approver['role']),
                      'foto_profil_user': approver['foto_profil_user'],
                    }
                  : <String, dynamic>{
                      'id_user': '',
                      'nama_pengguna': '',
                      'email': '',
                      'role': '',
                      'foto_profil_user': null,
                    };

              return <String, dynamic>{
                'id_approval_pocket_money': safeStr(
                  e['id_approval_pocket_money'],
                ),
                'id_pocket_money': safeStr(e['id_pocket_money']),
                'level': safeInt(e['level'], 0),
                'approver_user_id': safeStr(e['approver_user_id']),
                'approver_role': safeStr(e['approver_role']),
                'decision': safeStr(e['decision']).isEmpty
                    ? 'pending'
                    : safeStr(e['decision']),
                'decided_at': safeIsoDate(e['decided_at'], fallback: nowIso),
                'note': safeStr(e['note']),
                'bukti_approval_pocket_money_url': safeStr(
                  e['bukti_approval_pocket_money_url'],
                ),
                'approver': approverJson,
              };
            }
            return <String, dynamic>{
              'id_approval_pocket_money': '',
              'id_pocket_money': safeStr(normalized['id_pocket_money']),
              'level': 0,
              'approver_user_id': '',
              'approver_role': '',
              'decision': 'pending',
              'decided_at': nowIso,
              'note': '',
              'bukti_approval_pocket_money_url': '',
              'approver': <String, dynamic>{
                'id_user': '',
                'nama_pengguna': '',
                'email': '',
                'role': '',
                'foto_profil_user': null,
              },
            };
          })
          .toList(growable: false);
    } else {
      normalized['approvals'] = <dynamic>[];
    }

    return normalized;
  }
}
