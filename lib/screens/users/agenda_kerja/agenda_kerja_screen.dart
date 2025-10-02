// screens/users/agenda_kerja/agenda_kerja_screen.dart
import 'dart:math' as math;
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/screens/users/agenda_kerja/widget/calendar_agenda_kerja.dart';
import 'package:e_hrm/screens/users/agenda_kerja/widget/header_agenda_kerja.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_hrm/screens/users/agenda_kerja/widget/content_agenda_kerja.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgendaKerjaScreen extends StatefulWidget {
  const AgendaKerjaScreen({
    super.key,
    this.selectionMode = false,
    this.initialSelection = const <String>{},
  });

  final bool selectionMode;
  final Set<String> initialSelection;

  @override
  State<AgendaKerjaScreen> createState() => _AgendaKerjaScreenState();
}

class _AgendaKerjaScreenState extends State<AgendaKerjaScreen> {
  bool _selectionConfirmed = false;
  bool _didInitDependencies = false;
  late AgendaKerjaProvider _agendaProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitDependencies) return;
    _didInitDependencies = true;
    _agendaProvider = Provider.of<AgendaKerjaProvider>(context, listen: false);
    if (widget.selectionMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _agendaProvider.replaceAgendaSelection(widget.initialSelection);
      });
    }
  }

  @override
  void dispose() {
    if (widget.selectionMode && !_selectionConfirmed) {
      _agendaProvider.replaceAgendaSelection(widget.initialSelection);
    }
    super.dispose();
  }

  void _handleConfirmSelection(List<String> selectedIds) {
    _selectionConfirmed = true;
    Navigator.of(context).pop(List<String>.from(selectedIds));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final iconMax = (math.min(size.width, size.height) * 0.4).clamp(
      320.0,
      360.0,
    );

    return Scaffold(
      body: Stack(
        children: [
          // BG ikon samar di tengah
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    'lib/assets/image/icon_bg.png',
                    width: iconMax,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Image.asset(
                'lib/assets/image/Pattern.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // === Konten utama (scrollable) ===
          Positioned.fill(
            child: SafeArea(
              // top/bottom tetap aman, kiri/kanan edge-to-edge
              left: false,
              right: false,
              child: SingleChildScrollView(
                // full width secara horizontal
                padding: const EdgeInsets.fromLTRB(0, 60, 0, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CalendarAgendaKerja(),
                    const SizedBox(height: 24),
                    ContentAgendaKerja(selectionMode: widget.selectionMode),
                    if (widget.selectionMode) const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          if (widget.selectionMode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<AgendaKerjaProvider>(
                    builder: (context, provider, _) {
                      final selectedIds = provider.selectedAgendaKerjaIds;
                      final hasSelection = selectedIds.isNotEmpty;
                      final isBusy =
                          provider.loading ||
                          provider.saving ||
                          provider.deleting;
                      final canConfirm = hasSelection && !isBusy;

                      return SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: canConfirm
                              ? AppColors.textColor
                              : AppColors.textColor.withOpacity(0.6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: canConfirm
                                ? () => _handleConfirmSelection(selectedIds)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: isBusy
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.textDefaultColor,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Memproses...',
                                            style: GoogleFonts.poppins(
                                              textStyle: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    AppColors.textDefaultColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Pilih',
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: canConfirm
                                                ? AppColors.textDefaultColor
                                                : AppColors.hintColor,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          Positioned(top: 40, left: 10, child: HeaderAgendaKerja()),
        ],
      ),
    );
  }
}
