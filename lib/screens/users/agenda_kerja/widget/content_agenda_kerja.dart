import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/agenda_kerja/agenda_kerja.dart' show Data;
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/screens/users/agenda_kerja/create_agenda/create_agenda_screen.dart';
import 'package:e_hrm/screens/users/agenda_kerja/edit_agenda/edit_agenda_screen.dart';
import 'package:e_hrm/utils/id_user_resolver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentAgendaKerja extends StatefulWidget {
  const ContentAgendaKerja({super.key, this.selectionMode = false});

  final bool selectionMode;

  @override
  State<ContentAgendaKerja> createState() => _ContentAgendaKerjaState();
}

class _ContentAgendaKerjaState extends State<ContentAgendaKerja> {
  final DateFormat _dateFormatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  final DateFormat _shortDateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');
  final DateFormat _timeFormatter = DateFormat('HH:mm');

  late String _selectedStatus;
  String? _deletingId;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AgendaKerjaProvider>();
    final currentStatus = provider.currentStatus;
    final normalizedCurrent = _normalizeStatus(currentStatus);
    final hasExistingOption =
        normalizedCurrent.isNotEmpty &&
        _statusOptions.any((option) => option.value == normalizedCurrent);
    _selectedStatus = hasExistingOption
        ? normalizedCurrent
        : _statusOptions.last.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchAgenda(force: provider.items.isEmpty);
    });
  }

  Future<void> _fetchAgenda({DateTime? date, bool force = false}) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<AgendaKerjaProvider>();
    final userId = await resolveUserId(auth, context: context);
    if (userId == null || userId.isEmpty) {
      return;
    }
    final targetDate = _stripTime(
      date ?? provider.currentDate ?? DateTime.now(),
    );

    if (!force) {
      final sameUser = provider.currentUserId == userId;
      final currentDate = provider.currentDate;
      final sameDate =
          currentDate != null &&
          _isSameDay(_stripTime(currentDate), targetDate);
      final providerStatus = _normalizeStatus(provider.currentStatus);
      final selectedStatus = _normalizeStatus(_selectedStatus);
      final sameStatus = selectedStatus.isEmpty
          ? providerStatus.isEmpty
          : providerStatus == selectedStatus;

      if (provider.items.isNotEmpty && sameUser && sameDate && sameStatus) {
        return;
      }
    }

    final normalizedStatus = _normalizeStatus(_selectedStatus);
    await provider.fetchAgendaKerja(
      userId: userId,
      date: targetDate,
      status: normalizedStatus.isEmpty ? null : normalizedStatus,
      append: false,
    );
  }

  Future<void> _onDelete(Data item) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<AgendaKerjaProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus pekerjaan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus pekerjaan "${item.deskripsiKerja}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirm != true) return;

    setState(() => _deletingId = item.idAgendaKerja);

    final success = await provider.delete(item.idAgendaKerja);

    if (!mounted) return;

    setState(() => _deletingId = null);

    final message = success
        ? provider.message ?? 'Agenda kerja berhasil dihapus.'
        : provider.error ?? 'Gagal menghapus agenda kerja.';

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.succesColor : AppColors.errorColor,
        content: Text(message),
      ),
    );
  }

  Color _statusColor(String value) {
    switch (value.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF16A34A);
      case 'ditunda':
        return const Color(0xFFE11D48);
      case 'diproses':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _statusLabel(String value) {
    if (value.isEmpty) return '-';
    final lower = value.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  String _normalizeStatus(String? value) => value?.trim().toLowerCase() ?? '';

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return _shortDateFormatter.format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '--:--';
    return _timeFormatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgendaKerjaProvider>(
      builder: (context, provider, _) {
        final currentDate = provider.currentDate ?? DateTime.now();
        final headerText = _dateFormatter.format(currentDate);
        final items = provider.items;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.textDefaultColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(0, 4),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.album_outlined,
                      color: AppColors.menuColor,
                      size: 12,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        headerText,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentColor,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(0, 4),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Pilih status',
                      hintStyle: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.backgroundColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.menuColor,
                          width: 1.6,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    items: _statusOptions
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s.value,
                            child: Text(
                              s.label,
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: provider.loading
                        ? null
                        : (val) {
                            if (val == null) return;
                            setState(() => _selectedStatus = val);
                            _fetchAgenda(force: true);
                          },
                  ),
                  if (provider.loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                  const SizedBox(height: 16),
                  if (!provider.loading && provider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Terjadi kesalahan: ${provider.error}',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  if (!provider.loading && items.isEmpty)
                    Column(
                      children: [
                        const Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada agenda kerja untuk filter ini.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    ...items.map((item) => _buildAgendaCard(item, provider)),
                  const SizedBox(height: 12),
                  if (!widget.selectionMode)
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const CreateAgendaScreen(),
                          ),
                        );
                        if (result == true) {
                          _fetchAgenda(force: true);
                        }
                      },
                      child: Container(
                        width: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Card(
                          color: AppColors.textColor,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle),
                                const SizedBox(width: 10),
                                Text(
                                  'Pekerjaan',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDefaultColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAgendaCard(Data item, AgendaKerjaProvider provider) {
    final start = item.startDate;
    final end = item.endDate;
    final normalizedStatus = item.status.toLowerCase();
    final isDeleting = _deletingId == item.idAgendaKerja && provider.deleting;
    final selectionMode = widget.selectionMode;
    final isSelected = provider.isAgendaSelected(item.idAgendaKerja);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: selectionMode
            ? () => provider.toggleAgendaSelection(item.idAgendaKerja)
            : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: const BorderSide(color: AppColors.primaryColor, width: 5),
              top: const BorderSide(color: AppColors.primaryColor, width: 1),
              right: const BorderSide(color: AppColors.primaryColor, width: 1),
              bottom: const BorderSide(color: AppColors.primaryColor, width: 1),
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 78,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.textDefaultColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatTime(start),
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Icon(Icons.more_vert, size: 22),
                      const SizedBox(height: 10),
                      Container(
                        width: 78,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.textDefaultColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatTime(end),
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xfff6f6f6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _statusLabel(normalizedStatus),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(normalizedStatus),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.agenda?.namaAgenda ?? 'Agenda tidak diketahui',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.deskripsiKerja,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(start ?? end),
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
              if (!selectionMode)
                Positioned(
                  right: 0,
                  top: 16,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: Material(
                          color: const Color(0xffffe1e8),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: isDeleting ? null : () => _onDelete(item),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: isDeleting
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.delete_outline, size: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: Material(
                          color: const Color(0xffffe1e8),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              final result = await Navigator.of(context)
                                  .push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => EditAgendaScreen(
                                        agendaKerjaId: item.idAgendaKerja,
                                      ),
                                    ),
                                  );
                              if (result == true) {
                                _fetchAgenda(force: true);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.edit_outlined, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Positioned(
                  right: -18,
                  top: 20,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: isSelected
                        ? AppColors.succesColor
                        : AppColors.textDefaultColor.withAlpha(
                            (0.3 * 255).round(),
                          ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusOption {
  const _StatusOption({required this.value, required this.label});

  final String value;
  final String label;
}

const List<_StatusOption> _statusOptions = <_StatusOption>[
  _StatusOption(value: 'ditunda', label: 'Ditunda'),
  _StatusOption(value: 'selesai', label: 'Selesai'),
  _StatusOption(value: 'diproses', label: 'Diproses'),
];
