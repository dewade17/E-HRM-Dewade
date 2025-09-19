import 'package:dotted_border/dotted_border.dart';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/agenda_kerja/agenda_kerja.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/screens/users/agenda_kerja/agenda_kerja_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AgendaAbsensiCheckin extends StatefulWidget {
  const AgendaAbsensiCheckin({super.key});

  @override
  State<AgendaAbsensiCheckin> createState() => _AgendaAbsensiCheckinState();
}

class _AgendaAbsensiCheckinState extends State<AgendaAbsensiCheckin> {
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
    final agendaName = item.agenda?.namaAgenda ?? '-';
    final description = item.deskripsiKerja;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agendaName,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Hapus',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
