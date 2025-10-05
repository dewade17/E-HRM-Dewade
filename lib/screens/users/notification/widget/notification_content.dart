import 'package:flutter/material.dart';

class NotificationContent extends StatefulWidget {
  const NotificationContent({super.key});

  @override
  State<NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<NotificationContent> {
  // Filter
  final List<String> _filters = ['semua', 'belum dibaca', 'telah dibaca'];
  String _selectedFilter = 'semua';

  // Warna tema kartu notifikasi
  static const _bgUnread = Color(0xFFEAF8F3); // hijau muda (mirip referensi)
  static const _bgRead = Color(0xFFF6FAF8);
  static const _accent = Color(0xFF18A36C);

  // Model sederhana notifikasi
  final List<_Notif> _allNotifs = [];

  @override
  void initState() {
    super.initState();

    // ====== Contoh data dari TEMPLATE yang kamu berikan ======
    const titleTemplate = '🔔 Pengingat Agenda Kerja';
    const bodyTemplate =
        'Jangan lupa, agenda "{judul_agenda}" akan jatuh tempo besok. '
        'Segera perbarui statusnya.';
    final agendaData = {
      'nama_karyawan': 'I Dewa Gede Arsana Pucanganom',
      'judul_agenda': 'Rapat Sprint Q4',
    };

    // Render template ke text final
    final templatedTitle = _renderTemplate(titleTemplate, agendaData);
    final templatedBody = _renderTemplate(bodyTemplate, agendaData);

    // Tambahkan contoh notifikasi dari template
    _allNotifs.addAll([
      _Notif(
        id: 'n1',
        title: templatedTitle,
        body: templatedBody,
        sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        category: 'agenda',
      ),
    ]);

    // ====== Contoh data yang meniru gaya teks pada gambar referensi ======
    _allNotifs.addAll([
      _Notif(
        id: 'n2',
        title: 'Siap-siap Absen Masuk.',
        body:
            'Hari Minggu tetep semangat kerja ya kak I Dewa Gede Arsana Pucanganom, '
            'masuk jam 9 pagi.\nPatuhi SOP dan jangan telat, nanti HRD si kak Ayu marah lohh',
        sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 12)),
        isRead: false,
        category: 'absensi',
      ),
      _Notif(
        id: 'n3',
        title: '✅ Absen Masuk Berhasil',
        body:
            'Anda berhasil check-in pada pukul 08:59. Selamat bekerja, I Dewa Gede Arsana Pucanganom!',
        sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        isRead: true,
        category: 'absensi',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifs();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header filter
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      underline: const SizedBox.shrink(),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _selectedFilter = val);
                      },
                      items: _filters
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(
                                _capitalize(f),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Daftar notifikasi
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final n = filtered[index];
                  return _NotificationCard(
                    notif: n,
                    onToggleRead: () {
                      setState(() {
                        n.isRead = !n.isRead;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_Notif> _filteredNotifs() {
    switch (_selectedFilter) {
      case 'belum dibaca':
        return _allNotifs.where((e) => !e.isRead).toList();
      case 'telah dibaca':
        return _allNotifs.where((e) => e.isRead).toList();
      default:
        return _allNotifs;
    }
  }

  static String _renderTemplate(String template, Map<String, String> data) {
    // Ganti {key} di template dengan nilai pada data
    return template.replaceAllMapped(
      RegExp(r'\{([^}]+)\}'),
      (m) => data[m.group(1)] ?? m.group(0)!,
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String formatDateTime(DateTime dt) {
    // Format: dd-MM-yyyy, HH:mm (tanpa package tambahan)
    return '${_two(dt.day)}-${_two(dt.month)}-${dt.year}, '
        '${_two(dt.hour)}:${_two(dt.minute)}';
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notif, required this.onToggleRead});

  final _Notif notif;
  final VoidCallback onToggleRead;

  static const _bgUnread = _NotificationContentState._bgUnread;
  static const _bgRead = _NotificationContentState._bgRead;
  static const _accent = _NotificationContentState._accent;

  @override
  Widget build(BuildContext context) {
    final bg = notif.isRead ? _bgRead : _bgUnread;

    return InkWell(
      onTap: onToggleRead,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead
                ? const Color(0xFFE5E7EB)
                : _accent.withOpacity(.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + indikator unread
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _accent.withOpacity(.25)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(notif._iconData(), size: 20, color: _accent),
                ),
                if (!notif.isRead)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    notif.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: Color(0xFF0F172A), // slate-900
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Body (multi-line)
                  Text(
                    notif.body,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: Color(0xFF334155), // slate-700
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Timestamp
                  Text(
                    _NotificationContentState.formatDateTime(notif.sentAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(
                        0xFF64748B,
                      ).withOpacity(.9), // slate-500
                    ),
                  ),
                ],
              ),
            ),

            // Aksi kecil: toggle read
            IconButton(
              onPressed: onToggleRead,
              tooltip: notif.isRead
                  ? 'Tandai belum dibaca'
                  : 'Tandai telah dibaca',
              icon: Icon(
                notif.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                size: 20,
                color: notif.isRead ? const Color(0xFF94A3B8) : _accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notif {
  _Notif({
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
    required this.isRead,
    required this.category,
  });

  final String id;
  final String title;
  final String body;
  final DateTime sentAt;
  bool isRead;
  final String category;

  IconData _iconData() {
    switch (category) {
      case 'agenda':
        return Icons.event_note;
      case 'absensi':
        return Icons.notifications;
      default:
        return Icons.info_outline;
    }
  }
}
