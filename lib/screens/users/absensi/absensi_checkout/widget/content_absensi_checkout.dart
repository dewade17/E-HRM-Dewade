// lib/screens/users/absensi/absensi_checkout/widget/content_absensi_checkout.dart

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/location/location.dart' as dto_loc;
import 'package:e_hrm/providers/absensi/absensi_provider.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/providers/approvers/approvers_absensi_provider.dart';
import 'package:e_hrm/providers/shift_kerja/shift_kerja_realtime_provider.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkout/widget/agenda_absensi_checkout.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkout/widget/catatan_absensi_checkout.dart';
import 'package:e_hrm/screens/users/absensi/absensi_checkout/widget/recipient_absensi_checkout.dart';
import 'package:e_hrm/screens/users/absensi/take_face_absensi/take_face_absensi_screen.dart';
import 'package:e_hrm/screens/users/absensi/widget/geofence_map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentAbsensiCheckout extends StatefulWidget {
  final String userId;
  const ContentAbsensiCheckout({super.key, required this.userId});

  @override
  State<ContentAbsensiCheckout> createState() => _ContentAbsensiCheckoutState();
}

class _ContentAbsensiCheckoutState extends State<ContentAbsensiCheckout> {
  dto_loc.Location? _nearest;
  Position? _position;

  bool _inside = false;
  double? _distanceM;
  final List<String> _catatan = <String>[];

  final DateFormat _dayNumberFormatter = DateFormat('dd');
  final DateFormat _dayNameFormatter = DateFormat('EEEE', 'id_ID');
  final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy', 'id_ID');
  final DateFormat _dateFullFormatter = DateFormat(
    'EEEE, dd MMM yyyy',
    'id_ID',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    // --- PERBAIKAN UTAMA DI SINI ---
    final agendaProvider = context.read<AgendaKerjaProvider>();
    final shiftProvider = context.read<ShiftKerjaRealtimeProvider>();
    final absensiProvider = context.read<AbsensiProvider>();

    // 1. Ambil status absensi hari ini untuk mendapatkan agenda yang sudah tertaut
    if (absensiProvider.todayStatus?.mode != 'checkout') {
      await absensiProvider.fetchTodayStatus(widget.userId);
      if (!mounted) return;
    }

    // 2. Ambil ID agenda yang sudah tertaut dari status
    final linkedIds = absensiProvider.todayStatus?.linkedAgendaIds ?? [];

    // 3. Set ID tersebut sebagai pilihan awal di AgendaKerjaProvider
    agendaProvider.replaceAgendaSelection(linkedIds);

    // 4. Lanjutkan dengan fetch data seperti biasa untuk mengisi daftar
    await agendaProvider.fetchAgendaKerja(
      userId: widget.userId,
      date: DateTime.now(),
      append: false,
    );

    if (!mounted) return;

    await shiftProvider.fetch(idUser: widget.userId, date: DateTime.now());
  }

  String _formatShiftTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'Libur';
    try {
      // Perbaikan: Hapus .toLocal()
      final dt = DateTime.parse(raw);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      final parts = raw.split(':');
      if (parts.length >= 2) {
        final hh = parts[0].padLeft(2, '0');
        final mm = parts[1].padLeft(2, '0');
        return '$hh:$mm';
      }
    }
    return raw;
  }

  String _buildScheduleLabel(
    DateTime date,
    ShiftKerjaRealtimeProvider provider,
  ) {
    final items = provider.items;
    final data = items.isNotEmpty ? items.first : null;
    final start = _formatShiftTime(data?.polaKerja?.jamMulai);
    final end = _formatShiftTime(data?.polaKerja?.jamSelesai);
    final base = _dateFullFormatter.format(date);

    if (start == 'Libur' || end == 'Libur') {
      return '$base (Libur)';
    }

    return '$base ($start - $end)';
  }

  Future<void> _handleVerify() async {
    final absensi = context.read<AbsensiProvider>();
    if (absensi.saving) return;

    if (_nearest == null || _position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi belum tersedia. Coba lagi.')),
      );
      return;
    }

    if (!_inside) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda berada di luar area kantor.')),
      );
      return;
    }

    final agenda = context.read<AgendaKerjaProvider>();
    final approvers = context.read<ApproversProvider>();
    final shift = context.read<ShiftKerjaRealtimeProvider>();

    final agendaIds = agenda.selectedAgendaKerjaIds;
    final recipientIds = approvers.selectedRecipientIds.toList(growable: false);
    final catatanEntries = _catatan
        .map((desc) => desc.trim())
        .where((value) => value.isNotEmpty)
        .map((value) => AbsensiCatatanEntry(description: value))
        .toList(growable: false);

    final scheduleDate = shift.responseDate ?? DateTime.now();
    final scheduleLabel = _buildScheduleLabel(scheduleDate, shift);
    final shiftName = shift.items.isNotEmpty
        ? shift.items.first.polaKerja?.namaPolaKerja
        : null;

    final success = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TakeFaceAbsensiScreen(
          isCheckin: false,
          userId: widget.userId,
          locationId: _nearest?.idLocation,
          latitude: _position!.latitude,
          longitude: _position!.longitude,
          agendaIds: agendaIds,
          recipientIds: recipientIds,
          catatan: catatanEntries,
          locationName: _nearest?.namaKantor ?? '-',
          scheduleLabel: scheduleLabel,
          shiftName: shiftName,
          agendaCount: agendaIds.length,
          recipientCount: recipientIds.length,
          catatanCount: catatanEntries.length,
        ),
      ),
    );

    if (!mounted) return;

    if (success == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final absensi = context.watch<AbsensiProvider>();
    final shiftProvider = context.watch<ShiftKerjaRealtimeProvider>();
    final scheduleDate = shiftProvider.responseDate ?? DateTime.now();
    final shiftData = shiftProvider.items.isNotEmpty
        ? shiftProvider.items.first
        : null;
    final dayNumber = _dayNumberFormatter.format(scheduleDate);
    final dayName = _dayNameFormatter.format(scheduleDate);
    final monthYear = _monthYearFormatter.format(scheduleDate);
    final startTime = _formatShiftTime(shiftData?.polaKerja?.jamMulai);
    final endTime = _formatShiftTime(shiftData?.polaKerja?.jamSelesai);
    final isLibur = startTime == 'Libur' || endTime == 'Libur';
    final shiftName = isLibur
        ? 'Hari Libur'
        : (shiftData?.polaKerja?.namaPolaKerja ?? '-');
    final canSubmit =
        _inside && _nearest != null && _position != null && !absensi.saving;

    final textStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(fontSize: 13.5),
    );

    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                dayNumber,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDefaultColor,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                  Text(
                    monthYear,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDefaultColor,
                      ),
                    ),
                  ),
                ],
              ),
              const VerticalDivider(
                width: 25,
                thickness: 2,
                color: AppColors.primaryColor,
                indent: 10,
                endIndent: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLibur)
                      Text(
                        'Libur',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDefaultColor,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Text(
                            startTime,
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                          ),
                          const Icon(Icons.more_horiz_outlined),
                          Text(
                            endTime,
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Text(
                      shiftName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDefaultColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: GeofenceMap(
            onStatus: (inside, distanceM, nearest) async {
              if (!mounted) return;

              final double? safeDistance =
                  (distanceM != null && distanceM.isFinite) ? distanceM : null;

              setState(() {
                _inside = inside;
                _distanceM = safeDistance;
                _nearest = nearest;
              });

              try {
                final p = await Geolocator.getCurrentPosition(
                  locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.high,
                  ),
                );
                if (mounted) setState(() => _position = p);
              } catch (_) {}
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _inside ? Icons.verified_user : Icons.error_outline,
              color: _inside ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _nearest == null
                    ? 'Menunggu lokasi & daftar kantor...'
                    : '${_nearest!.namaKantor} • '
                          '${_inside ? "Di dalam radius" : "Di luar radius"}'
                          '${_distanceM != null ? " • ${_distanceM!.toStringAsFixed(1)} m" : ""}',
                style: textStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const RecipientAbsensiCheckout(),
        const SizedBox(height: 16),
        const AgendaAbsensiCheckout(),
        CatatanAbsensiCheckout(
          onChanged: (values) {
            _catatan
              ..clear()
              ..addAll(values);
          },
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: canSubmit ? _handleVerify : null,
          child: Card(
            color: canSubmit ? AppColors.primaryColor : Colors.grey.shade400,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 70),
              child: Text(
                absensi.saving ? "Memproses..." : "Verifikasi Wajah",
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
