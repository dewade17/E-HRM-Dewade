import 'package:e_hrm/dto/sop_perusahaan/sop_perushaan.dart' as sop_dto;

class PinnedSopDto {
  final String idPinnedSop;
  final String idSop;
  final DateTime? pinnedAt;
  final sop_dto.Item? sop;

  const PinnedSopDto({
    required this.idPinnedSop,
    required this.idSop,
    required this.pinnedAt,
    required this.sop,
  });

  static const String _fallbackIsoUtc = '1970-01-01T00:00:00.000Z';

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  static Map<String, dynamic> _sanitizeKategoriJson(dynamic raw) {
    final m = _asMap(raw);
    return <String, dynamic>{
      'id_kategori_sop': (m['id_kategori_sop'] ?? '').toString(),
      'nama_kategori': (m['nama_kategori'] ?? '').toString(),
    };
  }

  static Map<String, dynamic> _sanitizeSopItemJson(dynamic raw) {
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
      'created_by_snapshot_nama_pengguna': s(
        m['created_by_snapshot_nama_pengguna'],
      ),
      'created_at': iso(m['created_at']),
      'updated_at': iso(m['updated_at']),
      'deleted_at': m['deleted_at'],
      'id_kategori_sop': s(m['id_kategori_sop']),
      'kategori_sop': kategori,
    };
  }

  factory PinnedSopDto.fromAny(dynamic raw) {
    final m = _asMap(raw);

    sop_dto.Item? sop;
    final sopRaw = m['sop'];
    if (sopRaw != null) {
      try {
        sop = sop_dto.Item.fromJson(_sanitizeSopItemJson(sopRaw));
      } catch (_) {
        sop = null;
      }
    }

    return PinnedSopDto(
      idPinnedSop: (m['id_pinned_sop'] ?? m['idPinnedSop'] ?? '').toString(),
      idSop: (m['id_sop'] ?? m['idSop'] ?? '').toString(),
      pinnedAt: _dt(
        m['pinned_at'] ?? m['pinnedAt'] ?? m['created_at'] ?? m['createdAt'],
      ),
      sop: sop,
    );
  }
}
