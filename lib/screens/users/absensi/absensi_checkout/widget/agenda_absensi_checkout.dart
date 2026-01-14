import 'package:dotted_border/dotted_border.dart';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/screens/users/agenda_kerja/agenda_kerja_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_hrm/dto/agenda_kerja/agenda_kerja.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AgendaAbsensiCheckout extends StatefulWidget {
  const AgendaAbsensiCheckout({super.key});

  @override
  State<AgendaAbsensiCheckout> createState() => _AgendaAbsensiCheckoutState();
}

class _AgendaAbsensiCheckoutState extends State<AgendaAbsensiCheckout> {
  bool _navigating = false;

  Future<void> _openSelection(BuildContext context) async {
    if (_navigating) return;
    setState(() => _navigating = true);
    final provider = context.read<AgendaKerjaProvider>();
    final initial = provider.selectedAgendaKerjaIds.toSet();

    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) =>
            AgendaKerjaScreen(selectionMode: true, initialSelection: initial),
      ),
    );

    if (result != null) {
      provider.replaceAgendaSelection(result);
    }

    if (mounted) setState(() => _navigating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgendaKerjaProvider>(
      builder: (context, provider, _) {
        final List<Data> selected = provider.selectedAgendaItems;
        final count = selected.length;

        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Pekerjaan yang perlu anda proses hari ini ($count)",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Card(
                child: DottedBorder(
                  options: CustomPathDottedBorderOptions(
                    color: AppColors.accentColor,
                    strokeWidth: 2,
                    dashPattern: const [10, 5],
                    padding: const EdgeInsets.all(12),
                    customPath: (size) {
                      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
                      const radius = Radius.circular(8);
                      return Path()
                        ..addRRect(RRect.fromRectAndRadius(rect, radius));
                    },
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Tambahkan Pekerjaan Anda di hari ini",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (provider.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (selected.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              'Belum ada pekerjaan dipilih.',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          )
                        else
                          ...selected.map(
                            (item) => _SelectedAgendaTile(
                              item: item,
                              onRemove: () => provider.toggleAgendaSelection(
                                item.idAgendaKerja,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: provider.loading ? null : () => _openSelection(context),
                child: SizedBox(
                  width: 150,
                  height: 50,
                  child: Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle),
                        const SizedBox(width: 10),
                        Text(
                          _navigating ? "Memuat..." : "Pekerjaan",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
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
        );
      },
    );
  }
}

class _SelectedAgendaTile extends StatelessWidget {
  const _SelectedAgendaTile({required this.item, required this.onRemove});

  final Data item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final start = item.startDate;
    final end = item.endDate;
    final agendaProvider = context.watch<AgendaKerjaProvider>();
    final normalizedStatus = _normalizeStatus(item.status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentColor.withAlpha((0.4 * 255).round()),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimeBox(_formatTime(start)),
              const SizedBox(height: 8),
              const Icon(Icons.more_vert, size: 20),
              const SizedBox(height: 8),
              _buildTimeBox(_formatTime(end)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfff6f6f6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: normalizedStatus,
                          isDense: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: _statusColor(normalizedStatus),
                          ),
                          items: _statusOptions
                              .map(
                                (option) => DropdownMenuItem<String>(
                                  value: option.value,
                                  child: Text(
                                    option.label,
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _statusColor(option.value),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: agendaProvider.saving
                              ? null
                              : (value) async {
                                  if (value == null ||
                                      value == normalizedStatus) {
                                    return;
                                  }
                                  final updated = await agendaProvider.update(
                                    item.idAgendaKerja,
                                    status: value,
                                  );
                                  if (updated == null && context.mounted) {
                                    final message =
                                        agendaProvider.error ??
                                        'Gagal memperbarui status pekerjaan.';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  }
                                },
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Hapus',
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.agenda?.namaAgenda ?? 'Agenda tidak diketahui',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.deskripsiKerja,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 12,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final DateFormat _timeFormatter = DateFormat('HH:mm');
  static final DateFormat _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  static String _formatTime(DateTime? date) {
    if (date == null) return '--:--';
    return _timeFormatter.format(date);
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormatter.format(date);
  }

  static String _normalizeStatus(String? value) {
    final lower = (value ?? '').trim().toLowerCase();
    for (final option in _statusOptions) {
      if (option.value == lower) {
        return option.value;
      }
    }
    return _statusOptions.first.value;
  }

  static Color _statusColor(String value) {
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

  Widget _buildTimeBox(String text) {
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.textDefaultColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
  _StatusOption(value: 'diproses', label: 'Diproses'),
  _StatusOption(value: 'selesai', label: 'Selesai'),
  _StatusOption(value: 'ditunda', label: 'Ditunda'),
];
