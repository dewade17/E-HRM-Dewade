import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/agenda_kerja/agenda_kerja.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/foundation.dart';

class AgendaKerjaProvider extends ChangeNotifier {
  AgendaKerjaProvider();

  final ApiService _api = ApiService();

  bool loading = false;
  bool detailLoading = false;
  bool saving = false;
  bool deleting = false;
  final Set<String> _selectedAgendaKerjaIds = <String>{};

  String? error;
  String? message;

  List<Data> items = <Data>[];
  Meta? meta;
  Data? detail;

  String? _userId;
  String? _status;
  DateTime? _from;
  DateTime? _to;
  bool? _hasAbsensi;
  String? _agendaId;
  String? _absensiId;
  DateTime? _date;

  bool _isOffsetPaging = true;
  int limit = 50;
  int offset = 0;
  int page = 1;
  int perPage = 20;

  static const Object _noValue = Object();

  bool get hasMore {
    if (_isOffsetPaging) {
      final nextOffset = _parseOffset(meta?.nextOffset);
      if (nextOffset != null) return true;
      final total = meta?.total;
      if (total != null) return items.length < total;
      return false;
    }
    final totalPages = meta?.totalPages;
    final currentPage = meta?.page ?? page;
    if (totalPages != null) {
      return currentPage < totalPages;
    }
    final total = meta?.total;
    if (total != null) return items.length < total;
    return false;
  }

  String? get currentUserId => _userId;
  String? get currentStatus => _status;
  DateTime? get currentFrom => _from;
  DateTime? get currentTo => _to;
  bool? get currentHasAbsensi => _hasAbsensi;
  String? get currentAgendaId => _agendaId;
  String? get currentAbsensiId => _absensiId;
  DateTime? get currentDate => _date;
  bool get isOffsetPaging => _isOffsetPaging;

  List<String> get selectedAgendaKerjaIds =>
      List<String>.unmodifiable(_selectedAgendaKerjaIds);

  List<Data> get selectedAgendaItems => items
      .where(
        (Data item) => _selectedAgendaKerjaIds.contains(item.idAgendaKerja),
      )
      .toList(growable: false);

  bool isAgendaSelected(String idAgendaKerja) {
    return _selectedAgendaKerjaIds.contains(idAgendaKerja);
  }

  void selectAgenda(String idAgendaKerja, {bool selected = true}) {
    final normalized = idAgendaKerja.trim();
    if (normalized.isEmpty) return;

    final changed = selected
        ? _selectedAgendaKerjaIds.add(normalized)
        : _selectedAgendaKerjaIds.remove(normalized);
    if (changed) notifyListeners();
  }

  void toggleAgendaSelection(String idAgendaKerja) {
    final normalized = idAgendaKerja.trim();
    if (normalized.isEmpty) return;

    if (_selectedAgendaKerjaIds.contains(normalized)) {
      _selectedAgendaKerjaIds.remove(normalized);
    } else {
      _selectedAgendaKerjaIds.add(normalized);
    }
    notifyListeners();
  }

  void replaceAgendaSelection(Iterable<String> ids) {
    final normalized = ids
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toSet();
    if (_selectedAgendaKerjaIds.length == normalized.length &&
        _selectedAgendaKerjaIds.containsAll(normalized)) {
      return;
    }
    _selectedAgendaKerjaIds
      ..clear()
      ..addAll(normalized);
    notifyListeners();
  }

  void clearAgendaSelection() {
    if (_selectedAgendaKerjaIds.isEmpty) return;
    _selectedAgendaKerjaIds.clear();
    notifyListeners();
  }

  // ignore: unused_element
  Future<String?> _ensureUserId(String? userId) async {
    final trimmed = userId?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    if (_userId != null && _userId!.isNotEmpty) {
      return _userId;
    }

    final stored = await loadUserIdFromPrefs();
    if (stored != null && stored.isNotEmpty) {
      _userId = stored;
      return stored;
    }

    return null;
  }

  void _setLoading(bool value) {
    if (loading == value) return;
    loading = value;
    notifyListeners();
  }

  void _setDetailLoading(bool value) {
    if (detailLoading == value) return;
    detailLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    if (saving == value) return;
    saving = value;
    notifyListeners();
  }

  void _setDeleting(bool value) {
    if (deleting == value) return;
    deleting = value;
    notifyListeners();
  }

  int? _parseOffset(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Uri _buildUserUri(String userId, Map<String, String> query) {
    final base = Uri.parse(Endpoints.agendaKerjaUser(userId));
    return query.isEmpty ? base : base.replace(queryParameters: query);
  }

  Map<String, dynamic> _buildBody(Map<String, dynamic> body) {
    final mapped = <String, dynamic>{};
    body.forEach((key, value) {
      if (value != null) {
        mapped[key] = value;
      } else {
        mapped[key] = null;
      }
    });
    return mapped;
  }

  bool _matchesCurrentFilters(Data item) {
    if (_userId != null && _userId!.isNotEmpty && item.idUser != _userId) {
      return false;
    }
    if (_status != null &&
        _status!.isNotEmpty &&
        item.status.toLowerCase() != _status) {
      return false;
    }
    if (_agendaId != null &&
        _agendaId!.isNotEmpty &&
        item.idAgenda != _agendaId) {
      return false;
    }
    if (_absensiId != null && _absensiId!.isNotEmpty) {
      final absensiId = item.idAbsensi;
      if (absensiId == null || absensiId.isEmpty) return false;
      if (absensiId != _absensiId) return false;
    }
    if (_hasAbsensi != null) {
      final hasAbsensi = (item.idAbsensi ?? '').isNotEmpty;
      if (_hasAbsensi! && !hasAbsensi) return false;
      if (!_hasAbsensi! && hasAbsensi) return false;
    }
    return true;
  }

  void resetList() {
    items = <Data>[];
    meta = null;
    detail = null;
    limit = 50;
    offset = 0;
    page = 1;
    perPage = 20;
    _isOffsetPaging = true;
    message = null;
    error = null;
    _userId = null;
    _status = null;
    _from = null;
    _to = null;
    _hasAbsensi = null;
    _agendaId = null;
    _absensiId = null;
    _date = null;
    _selectedAgendaKerjaIds.clear();
    notifyListeners();
  }

  void clearDetail() {
    detail = null;
    notifyListeners();
  }

  Future<bool> fetchUserAgenda({
    required String userId,
    String? status,
    DateTime? from,
    DateTime? to,
    bool? hasAbsensi,
    int? limit,
    int? offset,
    bool append = false,
  }) async {
    var limitValue = limit ?? this.limit;
    if (limitValue <= 0) {
      limitValue = this.limit > 0 ? this.limit : 50;
    }

    int? effectiveOffset = offset;
    if (append) {
      effectiveOffset ??= _parseOffset(meta?.nextOffset);
      if (effectiveOffset == null) {
        return false;
      }
    } else {
      effectiveOffset ??= 0;
    }

    final rawStatus = (status ?? _status)?.trim().toLowerCase();
    final statusValue = rawStatus != null && rawStatus.isNotEmpty
        ? rawStatus
        : null;
    final fromValue = from ?? _from;
    final toValue = to ?? _to;
    final hasAbsensiValue = hasAbsensi ?? _hasAbsensi;

    final query = <String, String>{
      'limit': limitValue.toString(),
      'offset': effectiveOffset.toString(),
      if (statusValue != null) 'status': statusValue,
      if (fromValue != null) 'from': fromValue.toIso8601String(),
      if (toValue != null) 'to': toValue.toIso8601String(),
      if (hasAbsensiValue != null) 'has_absensi': hasAbsensiValue ? '1' : '0',
    };

    _setLoading(true);
    try {
      final uri = _buildUserUri(userId, query);
      final res = await _api.fetchDataPrivate(uri.toString());

      final rawList = res['data'];
      final List<Data> mapped = rawList is List
          ? rawList.map<Data>((dynamic e) {
              if (e is Data) return e;
              if (e is Map<String, dynamic>) return Data.fromJson(e);
              if (e is Map) {
                return Data.fromJson(Map<String, dynamic>.from(e));
              }
              throw Exception('Bentuk data agenda kerja tidak dikenali');
            }).toList()
          : <Data>[];

      Meta? metaValue;
      final metaRaw = res['meta'];
      if (metaRaw is Map<String, dynamic>) {
        metaValue = Meta.fromJson(metaRaw);
      } else if (metaRaw is Map) {
        metaValue = Meta.fromJson(Map<String, dynamic>.from(metaRaw));
      }

      items = append ? <Data>[...items, ...mapped] : mapped;
      meta = metaValue;
      _userId = userId;
      _status = statusValue;
      _from = fromValue;
      _to = toValue;
      _hasAbsensi = hasAbsensiValue;
      _agendaId = null;
      _absensiId = null;
      _date = null;
      _isOffsetPaging = true;
      limit = metaValue?.limit ?? limitValue;
      offset = metaValue?.offset ?? effectiveOffset;
      page = 1;
      perPage = limit;
      message = res['message'] as String?;
      error = null;
      _pruneAgendaSelection();

      notifyListeners();
      return true;
    } catch (e) {
      message = null;
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> fetchAgendaKerja({
    String? userId,
    String? agendaId,
    String? absensiId,
    String? status,
    DateTime? date,
    DateTime? from,
    DateTime? to,
    int? page,
    int? perPage,
    bool append = false,
  }) async {
    var perPageValue = perPage ?? this.perPage;
    if (perPageValue <= 0) {
      perPageValue = this.perPage > 0 ? this.perPage : 20;
    }

    int pageValue;
    if (page != null) {
      pageValue = page;
    } else if (append) {
      final currentPage = meta?.page ?? this.page;
      final totalPages = meta?.totalPages;
      if (totalPages != null && currentPage >= totalPages) {
        return false;
      }
      pageValue = currentPage + 1;
    } else {
      pageValue = 1;
    }
    if (pageValue < 1) pageValue = 1;

    final effectiveUserId = userId ?? _userId;
    final effectiveAgendaId = agendaId ?? _agendaId;
    final effectiveAbsensiId = absensiId ?? _absensiId;
    final normalizedStatus = (status ?? _status)?.trim().toLowerCase();
    final statusValue = normalizedStatus != null && normalizedStatus.isNotEmpty
        ? normalizedStatus
        : null;
    final dateValue = date ?? _date;
    final fromValue = from ?? _from;
    final toValue = to ?? _to;

    final query = <String, String>{
      'page': pageValue.toString(),
      'perPage': perPageValue.toString(),
      if (effectiveUserId != null && effectiveUserId.isNotEmpty)
        'user_id': effectiveUserId,
      if (effectiveAgendaId != null && effectiveAgendaId.isNotEmpty)
        'id_agenda': effectiveAgendaId,
      if (effectiveAbsensiId != null && effectiveAbsensiId.isNotEmpty)
        'id_absensi': effectiveAbsensiId,
      if (statusValue != null) 'status': statusValue,
      if (dateValue != null) 'date': dateValue.toIso8601String(),
      if (fromValue != null) 'from': fromValue.toIso8601String(),
      if (toValue != null) 'to': toValue.toIso8601String(),
    };

    _setLoading(true);
    try {
      final uri = Uri.parse(
        Endpoints.agendaKerjaCrud,
      ).replace(queryParameters: query);
      final res = await _api.fetchDataPrivate(uri.toString());

      final rawList = res['data'];
      final List<Data> mapped = rawList is List
          ? rawList.map<Data>((dynamic e) {
              if (e is Data) return e;
              if (e is Map<String, dynamic>) return Data.fromJson(e);
              if (e is Map) {
                return Data.fromJson(Map<String, dynamic>.from(e));
              }
              throw Exception('Bentuk data agenda kerja tidak dikenali');
            }).toList()
          : <Data>[];

      Meta? metaValue;
      final metaRaw = res['meta'];
      if (metaRaw is Map<String, dynamic>) {
        metaValue = Meta.fromJson(metaRaw);
      } else if (metaRaw is Map) {
        metaValue = Meta.fromJson(Map<String, dynamic>.from(metaRaw));
      }

      items = append ? <Data>[...items, ...mapped] : mapped;
      meta = metaValue;
      _userId = effectiveUserId;
      _agendaId = effectiveAgendaId;
      _absensiId = effectiveAbsensiId;
      _status = statusValue;
      _date = dateValue;
      _from = fromValue;
      _to = toValue;
      _hasAbsensi = null;
      _isOffsetPaging = false;
      perPage = metaValue?.perPage ?? perPageValue;
      page = metaValue?.page ?? pageValue;
      limit = perPage;
      offset = (page - 1) * perPage;
      message = res['message'] as String?;
      error = null;
      _pruneAgendaSelection();

      notifyListeners();

      return true;
    } catch (e) {
      message = null;
      error = e.toString();
      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Data?> fetchDetail(String id) async {
    _setDetailLoading(true);
    try {
      final res = await _api.fetchDataPrivate(Endpoints.agendaKerjaDetail(id));

      final dataRaw = res['data'];
      if (dataRaw is Map<String, dynamic>) {
        detail = Data.fromJson(dataRaw);
      } else if (dataRaw is Map) {
        detail = Data.fromJson(Map<String, dynamic>.from(dataRaw));
      } else {
        detail = null;
      }

      message = res['message'] as String?;
      error = null;
      notifyListeners();
      return detail;
    } catch (e) {
      message = null;
      error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setDetailLoading(false);
    }
  }

  Future<Data?> create({
    required String idUser,
    required String idAgenda,
    required String deskripsiKerja,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? durationSeconds,
    String? idAbsensi,
  }) async {
    _setSaving(true);
    try {
      final body = _buildBody(<String, dynamic>{
        'id_user': idUser.trim(),
        'id_agenda': idAgenda.trim(),
        'deskripsi_kerja': deskripsiKerja.trim(),
        if (status != null) 'status': status.toLowerCase(),
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
        'id_absensi': idAbsensi,
      });

      final res = await _api.postDataPrivate(Endpoints.agendaKerjaCrud, body);

      final dataRaw = res['data'];
      if (dataRaw is! Map) {
        throw Exception('Respon server tidak valid saat membuat agenda kerja');
      }

      final created = Data.fromJson(Map<String, dynamic>.from(dataRaw));
      message = res['message'] as String? ?? 'Agenda kerja berhasil dibuat.';
      error = null;

      if (_matchesCurrentFilters(created)) {
        final previousItems = items;
        final previousLength = previousItems.length;
        final filtered = previousItems
            .where((e) => e.idAgendaKerja != created.idAgendaKerja)
            .toList();
        final bool replaced = filtered.length != previousLength;
        items = <Data>[created, ...filtered];
        final metaValue = meta;
        if (metaValue != null && !replaced) {
          final currentTotal = metaValue.total ?? previousLength;
          metaValue.total = currentTotal + 1;
        }
      }

      notifyListeners();
      return created;
    } catch (e) {
      message = null;
      error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setSaving(false);
    }
  }

  Future<Data?> update(
    String idAgendaKerja, {
    String? idUser,
    String? idAgenda,
    String? deskripsiKerja,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? durationSeconds,
    Object? idAbsensi = _noValue,
  }) async {
    _setSaving(true);
    try {
      final body = <String, dynamic>{
        if (idUser != null) 'id_user': idUser.trim(),
        if (idAgenda != null) 'id_agenda': idAgenda.trim(),
        if (deskripsiKerja != null) 'deskripsi_kerja': deskripsiKerja.trim(),
        if (status != null) 'status': status.toLowerCase(),
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
      };
      if (idAbsensi != _noValue) {
        body['id_absensi'] = idAbsensi;
      }

      final res = await _api.updateDataPrivate(
        Endpoints.agendaKerjaDetail(idAgendaKerja),
        _buildBody(body),
      );

      final dataRaw = res['data'];
      if (dataRaw is! Map) {
        throw Exception(
          'Respon server tidak valid saat memperbarui agenda kerja',
        );
      }

      final updated = Data.fromJson(Map<String, dynamic>.from(dataRaw));
      message =
          res['message'] as String? ?? 'Agenda kerja berhasil diperbarui.';
      error = null;

      final previousItems = items;
      final previousLength = previousItems.length;
      if (_matchesCurrentFilters(updated)) {
        bool replaced = false;
        final List<Data> mapped = previousItems.map((e) {
          if (e.idAgendaKerja == updated.idAgendaKerja) {
            replaced = true;
            return updated;
          }
          return e;
        }).toList();
        if (replaced) {
          items = mapped;
        } else {
          items = <Data>[updated, ...mapped];
          final metaValue = meta;
          if (metaValue != null) {
            final currentTotal = metaValue.total ?? previousLength;
            metaValue.total = currentTotal + 1;
          }
        }
      } else {
        final filtered = previousItems
            .where((e) => e.idAgendaKerja != updated.idAgendaKerja)
            .toList();
        final bool removed = filtered.length != previousLength;
        items = filtered;
        if (removed && meta != null) {
          final currentTotal = meta!.total ?? previousLength;
          final next = currentTotal - 1;
          meta!.total = next < 0 ? 0 : next;
        }
      }

      if (detail?.idAgendaKerja == updated.idAgendaKerja) {
        detail = _matchesCurrentFilters(updated) ? updated : null;
      }

      notifyListeners();
      return updated;
    } catch (e) {
      message = null;
      error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> delete(String idAgendaKerja, {bool hard = false}) async {
    _setDeleting(true);
    try {
      final uri = Uri.parse(
        Endpoints.agendaKerjaDetail(idAgendaKerja),
      ).replace(queryParameters: <String, String>{'hard': hard ? '1' : '0'});
      final res = await _api.deleteDataPrivate(uri.toString());

      message = res['message'] as String? ?? 'Agenda kerja berhasil dihapus.';
      error = null;

      final previousLength = items.length;
      final filtered = items
          .where((e) => e.idAgendaKerja != idAgendaKerja)
          .toList();
      final bool changed = filtered.length != previousLength;
      items = filtered;
      _selectedAgendaKerjaIds.remove(idAgendaKerja);

      if (detail?.idAgendaKerja == idAgendaKerja) {
        detail = null;
      }

      if (changed && meta != null) {
        final currentTotal = meta!.total ?? previousLength;
        final next = currentTotal - 1;
        meta!.total = next < 0 ? 0 : next;
        if (!_isOffsetPaging) {
          final per = meta!.perPage ?? perPage;
          if (per > 0 && meta!.total != null) {
            meta!.totalPages = (meta!.total! + per - 1) ~/ per;
            final totalPages = meta!.totalPages;
            if (totalPages != null) {
              final currentPage = meta!.page ?? page;
              if (currentPage > totalPages) {
                meta!.page = totalPages;
                page = totalPages;
              }
            }
          }
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      message = null;
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setDeleting(false);
    }
  }

  void _pruneAgendaSelection() {
    if (_selectedAgendaKerjaIds.isEmpty) return;
    final validIds = items.map((Data e) => e.idAgendaKerja).toSet();
    _selectedAgendaKerjaIds.removeWhere((String id) => !validIds.contains(id));
    // Tidak memanggil notifyListeners karena pemanggil sudah melakukannya
    // setelah daftar item diperbarui.
  }
}
