// lib/screens/users/agenda_kerja/edit_agenda/widget/form_agenda_edit.dart
// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/agenda/agenda_provider.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:e_hrm/shared_widget/time_picker_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _selectedStatus = _statusOptions.first.value;
  String? _selectedAgendaId;
  String? _detailAgendaName;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _selectedUrgensi;
  final List<String> _urgensiItems = [
    'PENTING MENDESAK',
    'TIDAK PENTING TAPI MENDESAK',
    'PENTING TAK MENDESAK',
    'TIDAK PENTING TIDAK MENDESAK',
  ];

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
    startTimeController.dispose();
    endTimeController.dispose();
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
      _initializing = false;
    });
  }

  Future<void> _submit() async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    if (_selectedDate == null || _startTime == null || _endTime == null) {
      _showSnackBar('Tanggal dan jam wajib diisi.', true);
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
          children: [
            Text(_loadError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat ulang'),
            ),
          ],
        ),
      );
    }

    final dropdownItems = agendaProvider.items
        .map(
          (agenda) => DropdownMenuItem<String>(
            value: agenda.idAgenda,
            child: Text(agenda.namaAgenda ?? 'Agenda tanpa nama'),
          ),
        )
        .toList();

    if (_selectedAgendaId != null &&
        dropdownItems.every((item) => item.value != _selectedAgendaId)) {
      dropdownItems.insert(
        0,
        DropdownMenuItem<String>(
          value: _selectedAgendaId!,
          child: Text(_detailAgendaName ?? 'Agenda saat ini'),
        ),
      );
    }

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            DropdownFieldWidget<String>(
              label: 'Agenda',
              value: _selectedAgendaId,
              hintText: 'Pilih agenda...',
              isRequired: true,
              items: dropdownItems,
              onChanged: agendaProvider.loading
                  ? null
                  : (val) => setState(() => _selectedAgendaId = val),
            ),
            const SizedBox(height: 20),
            TextFieldWidget(
              label: 'Deskripsi Pekerjaan',
              controller: deskripsiController,
              hintText: 'Tulis deskripsi...',
              isRequired: true,
              prefixIcon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            DatePickerFieldWidget(
              label: 'Tanggal Agenda',
              controller: calendarController,
              initialDate: _selectedDate,
              onDateChanged: (date) => setState(() => _selectedDate = date),
              isRequired: true,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TimePickerFieldWidget(
                    label: "Jam Mulai",
                    controller: startTimeController,
                    initialTime: _startTime,
                    onChanged: (time) => setState(() => _startTime = time),
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TimePickerFieldWidget(
                    label: "Jam Selesai",
                    controller: endTimeController,
                    initialTime: _endTime,
                    onChanged: (time) => setState(() => _endTime = time),
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownFieldWidget<String>(
              label: "Urgensi",
              hintText: "Pilih tingkat urgensi",
              value: _selectedUrgensi,
              isRequired: true,
              items: _urgensiItems.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedUrgensi = newValue;
                });
              },
              validator: (value) {
                if (value == 'PENTING MENDESAK') {
                  return 'Opsi ini sementara tidak tersedia';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownFieldWidget<String>(
              label: 'Status',
              value: _selectedStatus,
              isRequired: true,
              items: _statusOptions
                  .map(
                    (s) => DropdownMenuItem<String>(
                      value: s.value,
                      child: Text(s.label),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStatus = val);
              },
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
                          'Simpan Perubahan',
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
        ),
      ),
    );
  }

  String _normalizeStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return _statusOptions
        .firstWhere(
          (option) => option.value == normalized,
          orElse: () => _statusOptions.first,
        )
        .value;
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
