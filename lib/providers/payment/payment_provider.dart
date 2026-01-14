import 'dart:convert';

import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/payment/payment.dart' as dto;
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider();

  final ApiService _api = ApiService();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  // ============================ List State ============================

  final List<dto.Data> items = <dto.Data>[];
  dto.Meta? meta;

  bool loading = false;
  String? error;

  int page = 1;
  int perPage = 20;

  // filters
  String? status; // pending | disetujui | ditolak
  String? idDepartement; // admin
  String? idUser; // admin
  String? q;
  bool all = false;

  DateTime? tanggalFrom;
  DateTime? tanggalTo;

  bool get canLoadMore {
    final m = meta;
    if (m == null) return false;
    return m.page < m.totalPages;
  }

  // ============================ Detail State ============================

  dto.Data? detail;
  bool detailLoading = false;
  String? detailError;

  // ============================ Save/Delete State ============================

  bool saving = false;
  String? saveMessage;
  String? saveError;

  bool deleting = false;
  String? deleteError;

  // ============================ Endpoints ============================

  String get _listEndpoint => Endpoints.payment;
  String _detailEndpoint(String id) => Endpoints.paymentDetail(id);

  // ============================ Filters ============================

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
      page = 1;
      meta = null;
      items.clear();
    }

    notifyListeners();
  }

  void reset() {
    loading = false;
    error = null;

    items.clear();
    meta = null;

    page = 1;
    perPage = 20;

    status = null;
    idDepartement = null;
    idUser = null;
    q = null;
    all = false;

    tanggalFrom = null;
    tanggalTo = null;

    detail = null;
    detailLoading = false;
    detailError = null;

    saving = false;
    saveMessage = null;
    saveError = null;

    deleting = false;
    deleteError = null;

    notifyListeners();
  }

  Future<bool> refresh({int? perPage}) async {
    return fetch(page: 1, perPage: perPage ?? this.perPage, append: false);
  }

  Future<bool> loadMore() async {
    if (loading) return false;
    if (!canLoadMore) return false;

    final nextPage = (meta?.page ?? page) + 1;
    return fetch(page: nextPage, perPage: perPage, append: true);
  }

  Map<String, String> _buildQueryParams({
    required int page,
    required int perPage,
  }) {
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

  // ============================ GET List ============================

  Future<bool> fetch({int? page, int? perPage, bool append = false}) async {
    var requestedPage = page ?? this.page;
    if (requestedPage < 1) requestedPage = 1;

    var requestedPerPage = perPage ?? this.perPage;
    if (requestedPerPage < 1) requestedPerPage = 1;
    if (requestedPerPage > 100) requestedPerPage = 100;

    loading = true;
    error = null;

    if (!append) {
      if (requestedPage == 1) {
        items.clear();
        meta = null;
      }
    }

    notifyListeners();

    try {
      final uri = Uri.parse(_listEndpoint).replace(
        queryParameters: _buildQueryParams(
          page: requestedPage,
          perPage: requestedPerPage,
        ),
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

  // ============================ GET Detail ============================

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

  // ============================ CREATE ============================

  Future<dto.Data?> createPayment({
    String? idDepartement,
    String? idKategoriKeperluan,
    required DateTime tanggal,
    required String nominalPembayaran,
    required String metodePembayaran,
    String? keterangan,
    String? nomorRekening,
    String? namaPemilikRekening,
    String? jenisBank,
    String? buktiPembayaranUrl,
    http.MultipartFile? buktiPembayaranFile,
    List<Map<String, dynamic>>? approvals,
    Map<String, dynamic>? additionalFields,
  }) async {
    saving = true;
    saveMessage = null;
    saveError = null;
    notifyListeners();

    final payload = <String, dynamic>{
      'tanggal': _dateFormatter.format(tanggal),
      'nominal_pembayaran': nominalPembayaran.trim(),
      'metode_pembayaran': metodePembayaran.trim(),
    };

    final dept = (idDepartement ?? '').trim();
    if (dept.isNotEmpty) payload['id_departement'] = dept;

    final kategori = (idKategoriKeperluan ?? '').trim();
    if (kategori.isNotEmpty) payload['id_kategori_keperluan'] = kategori;

    if (keterangan != null) payload['keterangan'] = keterangan;
    if (nomorRekening != null) payload['nomor_rekening'] = nomorRekening;
    if (namaPemilikRekening != null) {
      payload['nama_pemilik_rekening'] = namaPemilikRekening;
    }
    if (jenisBank != null) payload['jenis_bank'] = jenisBank;

    if (buktiPembayaranUrl != null) {
      payload['bukti_pembayaran_url'] = buktiPembayaranUrl;
    }

    if (approvals != null) payload['approvals'] = jsonEncode(approvals);
    if (additionalFields != null) payload.addAll(additionalFields);

    final List<http.MultipartFile> files = <http.MultipartFile>[];
    if (buktiPembayaranFile != null) files.add(buktiPembayaranFile);

    try {
      final Map<String, dynamic> response = await _api.postFormDataPrivate(
        _listEndpoint,
        payload,
        files: files.isEmpty ? null : files,
      );

      final dto.Data? created = _parseSingle(response['data']);
      if (created != null) _upsertItem(created);

      saveMessage =
          response['message']?.toString() ?? 'Payment berhasil dibuat.';
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

  Future<dto.Data?> updatePayment(
    String id, {
    DateTime? tanggal,
    String? keterangan,
    String? idKategoriKeperluan,
    String? metodePembayaran,
    String? nominalPembayaran,
    String? nomorRekening,
    String? namaPemilikRekening,
    String? jenisBank,
    String? buktiPembayaranUrl,
    http.MultipartFile? buktiPembayaranFile,
    List<Map<String, dynamic>>? approvals,
    Map<String, dynamic>? additionalFields,
  }) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;

    saving = true;
    saveMessage = null;
    saveError = null;
    notifyListeners();

    final payload = <String, dynamic>{};

    if (tanggal != null) payload['tanggal'] = _dateFormatter.format(tanggal);
    if (keterangan != null) payload['keterangan'] = keterangan;

    if (idKategoriKeperluan != null) {
      final v = idKategoriKeperluan.trim();
      payload['id_kategori_keperluan'] = v.isEmpty ? null : v;
    }

    if (metodePembayaran != null) {
      payload['metode_pembayaran'] = metodePembayaran.trim();
    }
    if (nominalPembayaran != null) {
      payload['nominal_pembayaran'] = nominalPembayaran.trim();
    }

    if (nomorRekening != null) payload['nomor_rekening'] = nomorRekening;
    if (namaPemilikRekening != null) {
      payload['nama_pemilik_rekening'] = namaPemilikRekening;
    }
    if (jenisBank != null) payload['jenis_bank'] = jenisBank;

    if (buktiPembayaranUrl != null) {
      payload['bukti_pembayaran_url'] = buktiPembayaranUrl.trim();
    }

    if (approvals != null) payload['approvals'] = jsonEncode(approvals);
    if (additionalFields != null) payload.addAll(additionalFields);

    final List<http.MultipartFile> files = <http.MultipartFile>[];
    if (buktiPembayaranFile != null) files.add(buktiPembayaranFile);

    try {
      final Map<String, dynamic> response = await _api.putFormDataPrivate(
        _detailEndpoint(trimmed),
        payload,
        files: files.isEmpty ? null : files,
      );

      final dto.Data? updated = _parseSingle(response['data']);
      if (updated != null) _upsertItem(updated);
      if (detail?.idPayment == updated?.idPayment) detail = updated;

      saveMessage =
          response['message']?.toString() ?? 'Payment berhasil diperbarui.';
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

  Future<bool> deletePayment(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return false;

    deleting = true;
    deleteError = null;
    notifyListeners();

    try {
      final Map<String, dynamic> response = await _api.deleteDataPrivate(
        _detailEndpoint(trimmed),
      );

      final ok = response['ok'] == true;
      if (ok) {
        items.removeWhere((it) => it.idPayment == trimmed);
        if (detail?.idPayment == trimmed) detail = null;
      }

      deleting = false;
      notifyListeners();
      return ok;
    } catch (e) {
      deleting = false;
      deleteError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================ Parsing Helpers ============================

  dto.Meta? _parseMeta(dynamic raw) {
    if (raw == null) return null;
    if (raw is dto.Meta) return raw;
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('page') && raw.containsKey('totalPages')) {
        return dto.Meta.fromJson(raw);
      }
    }
    return null;
  }

  List<dto.Data> _parseList(dynamic raw) {
    if (raw == null) return <dto.Data>[];
    if (raw is List<dto.Data>) return raw;

    if (raw is List) {
      final out = <dto.Data>[];
      for (final item in raw) {
        final parsed = _parseSingle(item);
        if (parsed != null) out.add(parsed);
      }
      return out;
    }
    return <dto.Data>[];
  }

  dto.Data? _parseSingle(dynamic raw) {
    if (raw == null) return null;
    if (raw is dto.Data) return raw;

    if (raw is Map<String, dynamic>) {
      try {
        final sanitized = _sanitizePaymentJson(raw);
        return dto.Data.fromJson(sanitized);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void _upsertItem(dto.Data item) {
    final idx = items.indexWhere((it) => it.idPayment == item.idPayment);
    if (idx >= 0) {
      items[idx] = item;
    } else {
      items.insert(0, item);
    }
  }

  Map<String, dynamic> _sanitizePaymentJson(Map<String, dynamic> raw) {
    final json = Map<String, dynamic>.from(raw);

    String s(dynamic v) => v == null ? '' : v.toString();
    int i(dynamic v) => v is int ? v : int.tryParse(s(v)) ?? 0;

    String isoOrEpoch(dynamic v) {
      final str = s(v).trim();
      if (str.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(
          0,
          isUtc: true,
        ).toIso8601String();
      }
      return str;
    }

    json['id_payment'] = s(json['id_payment']);
    json['id_user'] = s(json['id_user']);
    json['id_departement'] = s(json['id_departement']);
    json['id_kategori_keperluan'] = s(json['id_kategori_keperluan']);

    json['tanggal'] = isoOrEpoch(json['tanggal']);
    json['keterangan'] = s(json['keterangan']);
    json['nominal_pembayaran'] = s(json['nominal_pembayaran']);
    json['metode_pembayaran'] = s(json['metode_pembayaran']);

    json['nomor_rekening'] = s(json['nomor_rekening']);
    json['nama_pemilik_rekening'] = s(json['nama_pemilik_rekening']);
    json['jenis_bank'] = s(json['jenis_bank']);
    json['bukti_pembayaran_url'] = s(json['bukti_pembayaran_url']);

    json['status'] = s(json['status']);
    json['current_level'] = i(json['current_level']);

    json['created_at'] = isoOrEpoch(json['created_at']);
    json['updated_at'] = isoOrEpoch(json['updated_at']);
    json['deleted_at'] = json['deleted_at'];

    final dep = json['departement'];
    if (dep is Map<String, dynamic>) {
      json['departement'] = {
        'id_departement': s(dep['id_departement'] ?? json['id_departement']),
        'nama_departement': s(dep['nama_departement']),
      };
    } else {
      json['departement'] = {
        'id_departement': s(json['id_departement']),
        'nama_departement': '',
      };
    }

    final kat = json['kategori_keperluan'];
    if (kat is Map<String, dynamic>) {
      json['kategori_keperluan'] = {
        'id_kategori_keperluan': s(
          kat['id_kategori_keperluan'] ?? json['id_kategori_keperluan'],
        ),
        'nama_keperluan': s(kat['nama_keperluan']),
      };
    } else {
      json['kategori_keperluan'] = {
        'id_kategori_keperluan': s(json['id_kategori_keperluan']),
        'nama_keperluan': '',
      };
    }

    final approvalsRaw = json['approvals'];
    final approvalsList = approvalsRaw is List ? approvalsRaw : <dynamic>[];
    final sanitizedApprovals = <Map<String, dynamic>>[];

    for (final ap in approvalsList) {
      if (ap is Map<String, dynamic>) {
        final approver = ap['approver'];
        sanitizedApprovals.add({
          'id_approval_payment': s(ap['id_approval_payment']),
          'id_payment': s(ap['id_payment'] ?? json['id_payment']),
          'level': i(ap['level']),
          'approver_user_id': s(ap['approver_user_id']),
          'approver_role': s(ap['approver_role']),
          'decision': s(ap['decision']),
          'decided_at': isoOrEpoch(ap['decided_at']),
          'note': s(ap['note']),
          'bukti_approval_payment_url': s(ap['bukti_approval_payment_url']),
          'approver': approver is Map<String, dynamic>
              ? {
                  'id_user': s(approver['id_user']),
                  'nama_pengguna': s(approver['nama_pengguna']),
                  'email': s(approver['email']),
                  'role': s(approver['role']),
                  'foto_profil_user': s(approver['foto_profil_user']),
                }
              : {
                  'id_user': '',
                  'nama_pengguna': '',
                  'email': '',
                  'role': '',
                  'foto_profil_user': '',
                },
        });
      }
    }

    json['approvals'] = sanitizedApprovals;
    return json;
  }
}
