// lib/screens/users/agenda_kerja/edit_agenda/widget/form_agenda_edit.dart
// ignore_for_file: deprecated_member_use

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/agenda/agenda.dart'; // <-- Import DTO Agenda
import 'package:e_hrm/providers/agenda/agenda_provider.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/shared_widget/agenda_selection_field.dart'; // <-- Import Field Baru
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
  bool _autoValidate = false; // Ubah ke false
  String _selectedStatus = _statusOptions.first.value;
  // String? _selectedAgendaId; // <-- Ganti ini
  AgendaItem? _selectedAgenda; // <-- Dengan ini
  // String? _detailAgendaName; // <-- Bisa dihapus jika _selectedAgenda menyimpan objeknya
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

    // Ambil daftar agenda master terlebih dahulu
    if (!agendaProvider.loading && agendaProvider.items.isEmpty) {
      await agendaProvider.fetch();
    }

    // Ambil detail agenda kerja
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

    // Cari objek AgendaItem berdasarkan idAgenda dari detail
    AgendaItem? initialSelectedAgenda;
    if (detail.idAgenda.isNotEmpty) {
      try {
        initialSelectedAgenda = agendaProvider.items.firstWhere(
          (item) => item.idAgenda == detail.idAgenda,
          // Jika tidak ditemukan di daftar master, buat objek sementara
          orElse: () => AgendaItem(
            idAgenda: detail.idAgenda,
            namaAgenda: detail.agenda?.namaAgenda ?? 'Agenda Tersimpan',
          ),
        );
      } catch (_) {
        initialSelectedAgenda = AgendaItem(
          idAgenda: detail.idAgenda,
          namaAgenda: detail.agenda?.namaAgenda ?? 'Agenda Tersimpan',
        );
      }
    }

    // Parsing dan set state lainnya tetap sama
    final normalizedStatus = _normalizeStatus(detail.status);
    final normalizedUrgensi = _normalizeUrgensi(detail.kebutuhanAgenda);
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
      _selectedAgenda = initialSelectedAgenda; // <-- Set objek AgendaItem
      // _selectedAgendaId = detail.idAgenda.isNotEmpty ? detail.idAgenda : null; // Tidak perlu lagi
      // _detailAgendaName = detail.agenda?.namaAgenda; // Tidak perlu lagi
      _selectedStatus = normalizedStatus;
      _selectedDate = normalizedDate;
      _startTime = startTime;
      _endTime = endTime;
      _selectedUrgensi = normalizedUrgensi;
      _initializing = false;
    });
  }

  Future<void> _submit() async {
    final formState = formKey.currentState;
    if (formState == null) return; // Tambah cek null

    // Set autoValidate sebelum validasi
    setState(() => _autoValidate = true);

    if (!formState.validate()) return;

    // Validasi lain tetap sama
    if (_selectedAgenda == null) {
      // <-- Cek objek
      _showSnackBar('Agenda wajib dipilih.', true);
      return;
    }
    // ... (validasi tanggal, jam, urgensi tetap sama) ...
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
    if (_selectedUrgensi == null || _selectedUrgensi!.trim().isEmpty) {
      _showSnackBar('Urgensi wajib dipilih.', true);
      return;
    }

    final provider = context.read<AgendaKerjaProvider>();
    final updated = await provider.update(
      widget.agendaKerjaId,
      idAgenda: _selectedAgenda!.idAgenda, // <-- Ambil ID dari objek
      deskripsiKerja: deskripsiController.text,
      status: _selectedStatus,
      startDate: startDateTime,
      endDate: endDateTime,
      durationSeconds: endDateTime.difference(startDateTime).inSeconds,
      kebutuhanAgenda: _selectedUrgensi,
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
    context.watch<AgendaProvider>();
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

    // Dropdown items untuk Urgensi (tetap sama)
    final urgensiOptions = List<String>.from(_urgensiItems);
    if (_selectedUrgensi != null &&
        _selectedUrgensi!.isNotEmpty &&
        !urgensiOptions.contains(_selectedUrgensi)) {
      urgensiOptions.insert(0, _selectedUrgensi!);
    }

    final autovalidateMode = _autoValidate
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode, // Set di Form
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // --- GANTI DROPDOWN DENGAN FIELD BARU ---
            AgendaSelectionField(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Agenda',
              selectedAgenda: _selectedAgenda, // Kirim objek AgendaItem
              isRequired: true,
              onAgendaSelected: (selected) {
                setState(() => _selectedAgenda = selected);
                // Trigger validasi ulang
                if (_autoValidate) {
                  formKey.currentState?.validate();
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Agenda wajib dipilih';
                }
                return null;
              },
              // autovalidateMode: autovalidateMode, // Dihapus dari sini
            ),
            // --- AKHIR PERGANTIAN ---
            const SizedBox(height: 20),
            TextFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Deskripsi Pekerjaan',
              controller: deskripsiController,
              hintText: 'Tulis deskripsi...',
              isRequired: true,
              prefixIcon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
              maxLines: 3, // Perbolehkan multiline
            ),
            const SizedBox(height: 20),
            DatePickerFieldWidget(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
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
                    backgroundColor: AppColors.textColor,
                    borderColor: AppColors.textDefaultColor,
                    label: "Jam Mulai",
                    controller: startTimeController,
                    initialTime: _startTime,
                    onChanged: (time) => setState(() => _startTime = time),
                    isRequired: true,
                    validator: (value) {
                      // Tambah validator
                      if (_startTime == null) return 'Wajib diisi';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TimePickerFieldWidget(
                    backgroundColor: AppColors.textColor,
                    borderColor: AppColors.textDefaultColor,
                    label: "Jam Selesai",
                    controller: endTimeController,
                    initialTime: _endTime,
                    onChanged: (time) => setState(() => _endTime = time),
                    isRequired: true,
                    validator: (value) {
                      // Tambah validator
                      if (_endTime == null) return 'Wajib diisi';
                      // Validasi tambahan
                      if (_startTime != null && _endTime != null) {
                        final startMinutes =
                            _startTime!.hour * 60 + _startTime!.minute;
                        final endMinutes =
                            _endTime!.hour * 60 + _endTime!.minute;
                        if (endMinutes <= startMinutes) {
                          return 'Jam selesai harus setelah jam mulai';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownFieldWidget<String>(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: "Urgensi",
              hintText: "Pilih tingkat urgensi",
              value: _selectedUrgensi,
              isRequired: true,
              items: urgensiOptions.map((String value) {
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
              // Validator sudah otomatis
            ),
            const SizedBox(height: 20),
            DropdownFieldWidget<String>(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
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

  String? _normalizeUrgensi(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }
}

class _StatusOption {
  const _StatusOption({required this.value, required this.label});
  final String value;
  final String label;
}

const List<_StatusOption> _statusOptions = <_StatusOption>[
  _StatusOption(value: 'teragenda', label: 'Teragenda'),
  _StatusOption(value: 'diproses', label: 'Diproses'),
  _StatusOption(value: 'selesai', label: 'Selesai'),
  _StatusOption(value: 'ditunda', label: 'Ditunda'),
];
