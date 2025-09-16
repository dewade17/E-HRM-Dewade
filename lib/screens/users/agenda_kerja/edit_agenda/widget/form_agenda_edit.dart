// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/agenda/agenda_provider.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/screens/users/agenda_kerja/edit_agenda/widget/calendar_edit_agenda.dart';
import 'package:e_hrm/screens/users/agenda_kerja/edit_agenda/widget/time_edit_agenda.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FormAgendaEdit extends StatefulWidget {
  const FormAgendaEdit({super.key, required this.agendaKerjaId});

  final String agendaKerjaId;

  @override
  State<FormAgendaEdit> createState() => _FormAgendaEditState();
}

class _FormAgendaEditState extends State<FormAgendaEdit> {
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController calendarController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final DateFormat _timeFormatter = DateFormat('HH:mm');
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  String _selectedStatus = _statusOptions.first.value;
  String? _selectedAgendaId;
  String? _detailAgendaName;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _initializing = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetail();
    });
  }

  @override
  void dispose() {
    deskripsiController.dispose();
    calendarController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    final agendaProvider = context.read<AgendaProvider>();
    final agendaKerjaProvider = context.read<AgendaKerjaProvider>();

    setState(() {
      _initializing = true;
      _loadError = null;
    });

    if (!agendaProvider.loading && agendaProvider.items.isEmpty) {
      await agendaProvider.fetch();
    }

    final detail = await agendaKerjaProvider.fetchDetail(widget.agendaKerjaId);

    if (!mounted) return;

    if (detail == null) {
      setState(() {
        _initializing = false;
        _loadError =
            agendaKerjaProvider.error ?? 'Data agenda kerja tidak ditemukan.';
      });
      return;
    }

    final normalizedStatus = _normalizeStatus(detail.status);
    final selectedDate = detail.startDate ?? detail.endDate;
    final normalizedDate = selectedDate != null
        ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
        : null;
    final startTime = detail.startDate != null
        ? TimeOfDay(
            hour: detail.startDate!.hour,
            minute: detail.startDate!.minute,
          )
        : null;
    final endTime = detail.endDate != null
        ? TimeOfDay(hour: detail.endDate!.hour, minute: detail.endDate!.minute)
        : null;

    setState(() {
      deskripsiController.text = detail.deskripsiKerja;
      _selectedAgendaId = detail.idAgenda.isNotEmpty ? detail.idAgenda : null;
      _detailAgendaName = detail.agenda?.namaAgenda;
      _selectedStatus = normalizedStatus;
      _selectedDate = normalizedDate;
      _startTime = startTime;
      _endTime = endTime;
      calendarController.text = normalizedDate != null
          ? _dateFormatter.format(normalizedDate)
          : '';
      _initializing = false;
    });
  }

  Future<void> _submit() async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    if (_selectedAgendaId == null || _selectedAgendaId!.isEmpty) {
      _showSnackBar('Silakan pilih agenda terlebih dahulu.', true);
      return;
    }
    if (_selectedDate == null) {
      _showSnackBar('Silakan pilih tanggal agenda.', true);
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showSnackBar('Jam mulai dan selesai wajib diisi.', true);
      return;
    }

    final startDateTime = _combineDateTime(_selectedDate!, _startTime!);
    final endDateTime = _combineDateTime(_selectedDate!, _endTime!);
    if (!endDateTime.isAfter(startDateTime)) {
      _showSnackBar('Jam selesai harus lebih besar dari jam mulai.', true);
      return;
    }

    final provider = context.read<AgendaKerjaProvider>();
    final updated = await provider.update(
      widget.agendaKerjaId,
      idAgenda: _selectedAgendaId,
      deskripsiKerja: deskripsiController.text,
      status: _selectedStatus,
      startDate: startDateTime,
      endDate: endDateTime,
      durationSeconds: endDateTime.difference(startDateTime).inSeconds,
    );

    if (!mounted) return;

    final message = provider.message ?? 'Agenda kerja berhasil diperbarui.';
    final errorMessage = provider.error ?? 'Gagal memperbarui agenda kerja.';

    if (updated != null) {
      _showSnackBar(message, false);
      Navigator.of(context).pop(true);
    } else {
      _showSnackBar(errorMessage, true);
    }
  }

  void _showSnackBar(String message, bool isError) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.errorColor : AppColors.succesColor,
        content: Text(message),
      ),
    );
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _onDateChanged(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
    if (date != null) {
      calendarController.text = _dateFormatter.format(date);
    }
  }

  void _onTimeChanged(TimeOfDay? start, TimeOfDay? end) {
    setState(() {
      _startTime = start;
      _endTime = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final agendaProvider = context.watch<AgendaProvider>();
    final agendaKerjaProvider = context.watch<AgendaKerjaProvider>();

    if (_initializing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _loadError!,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _loadDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Muat ulang'),
              ),
            ),
          ],
        ),
      );
    }

    final dropdownItems = agendaProvider.items
        .map(
          (agenda) => DropdownMenuItem<String>(
            value: agenda.idAgenda,
            child: Text(
              agenda.namaAgenda?.isNotEmpty == true
                  ? agenda.namaAgenda!
                  : 'Agenda tanpa nama',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        )
        .toList();

    if (_selectedAgendaId != null &&
        dropdownItems.every((item) => item.value != _selectedAgendaId)) {
      dropdownItems.insert(
        0,
        DropdownMenuItem<String>(
          value: _selectedAgendaId!,
          child: Text(
            _detailAgendaName?.isNotEmpty == true
                ? _detailAgendaName!
                : 'Agenda saat ini',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 25),
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' Agenda',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedAgendaId,
                  isExpanded: true,
                  decoration: _dropdownDecoration(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  items: dropdownItems,
                  onChanged: agendaProvider.loading
                      ? null
                      : (val) {
                          setState(() => _selectedAgendaId = val);
                        },
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Pilih agenda' : null,
                ),
                if (agendaProvider.loading && agendaProvider.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  )
                else if (agendaProvider.error != null &&
                    agendaProvider.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Gagal memuat agenda: ${agendaProvider.error}',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' Deskripsi Pekerjaan',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextFormField(
                      controller: deskripsiController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tulis deskripsi…',
                        floatingLabelAlignment: FloatingLabelAlignment.start,
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Icon(Icons.comment),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Masukkan deskripsi'
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          CalendarEditAgenda(
            calendarController: calendarController,
            initialDate: _selectedDate,
            onDateChanged: _onDateChanged,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' Jam Mulai & Selesai',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TimeEditAgenda(
                  onChanged: _onTimeChanged,
                  initialStart: _startTime,
                  initialEnd: _endTime,
                ),
                if (_startTime != null && _endTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _formatTimeRange,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' Status',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: _dropdownDecoration(),
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
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _selectedStatus = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: agendaKerjaProvider.saving ? null : _submit,
            child: Card(
              elevation: 5,
              color: agendaKerjaProvider.saving
                  ? AppColors.primaryColor.withOpacity(0.6)
                  : AppColors.primaryColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 70,
                ),
                child: agendaKerjaProvider.saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textColor,
                          ),
                        ),
                      )
                    : Text(
                        'Simpan Pekerjaan',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String get _formatTimeRange {
    if (_startTime == null || _endTime == null) return '';
    final start = _timeFormatter.format(
      DateTime(0, 1, 1, _startTime!.hour, _startTime!.minute),
    );
    final end = _timeFormatter.format(
      DateTime(0, 1, 1, _endTime!.hour, _endTime!.minute),
    );
    return 'Rentang waktu: $start - $end';
  }

  InputDecoration _dropdownDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    filled: true,
    fillColor: Colors.white,
    hintText: 'Pilih salah satu',
    hintStyle: GoogleFonts.poppins(
      textStyle: const TextStyle(fontSize: 12, color: Colors.grey),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.backgroundColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.menuColor, width: 1.6),
    ),
  );

  String _normalizeStatus(String status) {
    final normalized = status.trim().toLowerCase();
    final match = _statusOptions
        .firstWhere(
          (option) => option.value == normalized,
          orElse: () => _statusOptions.first,
        )
        .value;
    return match;
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
