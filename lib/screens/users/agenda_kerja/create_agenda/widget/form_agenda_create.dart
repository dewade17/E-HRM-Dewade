// lib/screens/users/agenda_kerja/create_agenda/widget/form_agenda.dart
// ignore_for_file: deprecated_member_use
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/agenda/agenda_provider.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:e_hrm/shared_widget/time_picker_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormAgendaCreate extends StatefulWidget {
  const FormAgendaCreate({super.key});

  @override
  State<FormAgendaCreate> createState() => _FormAgendaCreateState();
}

class _FormAgendaCreateState extends State<FormAgendaCreate> {
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController calendarController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _selectedStatus = _statusOptions.first.value;
  String? _selectedAgendaId;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final agendaProvider = context.read<AgendaProvider>();
      if (!agendaProvider.loading && agendaProvider.items.isEmpty) {
        agendaProvider.fetch();
      }
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

  Future<void> _submit() async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

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

    final auth = context.read<AuthProvider>();
    final userId = await _ensureUserId(auth);
    if (!mounted) return;

    if (userId == null || userId.isEmpty) {
      _showSnackBar('ID pengguna tidak ditemukan. Silakan login ulang.', true);
      return;
    }

    final provider = context.read<AgendaKerjaProvider>();
    final created = await provider.create(
      idUser: userId,
      idAgenda: _selectedAgendaId!,
      deskripsiKerja: deskripsiController.text,
      status: _selectedStatus,
      startDate: startDateTime,
      endDate: endDateTime,
      durationSeconds: endDateTime.difference(startDateTime).inSeconds,
    );

    if (!mounted) return;

    final message = provider.message ?? 'Agenda kerja berhasil dibuat.';
    final errorMessage = provider.error ?? 'Gagal membuat agenda kerja.';

    if (created != null) {
      _showSnackBar(message, false);
      Navigator.of(context).pop(true);
    } else {
      _showSnackBar(errorMessage, true);
    }
  }

  Future<String?> _ensureUserId(AuthProvider auth) async {
    final current = auth.currentUser?.user.idUser;
    if (current != null && current.isNotEmpty) return current;

    await auth.tryRestoreSession(context, silent: true);
    final restored = auth.currentUser?.user.idUser;
    if (restored != null && restored.isNotEmpty) return restored;

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('id_user');
    } catch (_) {
      return null;
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

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // --- Menggunakan DropdownFieldWidget ---
            DropdownFieldWidget<String>(
              label: 'Agenda',
              value: _selectedAgendaId,
              hintText: 'Pilih agenda...',
              isRequired: true,
              items: agendaProvider.items
                  .map(
                    (agenda) => DropdownMenuItem<String>(
                      value: agenda.idAgenda,
                      child: Text(agenda.namaAgenda ?? 'Agenda tanpa nama'),
                    ),
                  )
                  .toList(),
              onChanged: agendaProvider.loading
                  ? null
                  : (val) => setState(() => _selectedAgendaId = val),
            ),
            if (agendaProvider.loading && agendaProvider.items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 20),

            // --- Menggunakan TextFieldWidget ---
            TextFieldWidget(
              label: 'Deskripsi Pekerjaan',
              controller: deskripsiController,
              hintText: 'Tulis deskripsi...',
              isRequired: true,
              prefixIcon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),

            // --- Menggunakan DatePickerFieldWidget ---
            DatePickerFieldWidget(
              label: 'Tanggal Agenda',
              controller: calendarController,
              onDateChanged: (date) => setState(() => _selectedDate = date),
              isRequired: true,
            ),
            const SizedBox(height: 20),

            // --- Menggunakan 2 TimePickerFieldWidget ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TimePickerFieldWidget(
                    label: "Jam Mulai",
                    controller: startTimeController,
                    onChanged: (time) => setState(() => _startTime = time),
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TimePickerFieldWidget(
                    label: "Jam Selesai",
                    controller: endTimeController,
                    onChanged: (time) => setState(() => _endTime = time),
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Menggunakan DropdownFieldWidget ---
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

            // --- Tombol Submit ---
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
