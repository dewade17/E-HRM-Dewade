// lib/screens/users/agenda_kerja/create_agenda/widget/form_agenda_create.dart
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
import 'package:flutter/scheduler.dart';
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
  final List<String> _urgensiItems = [
    'PENTING MENDESAK',
    'TIDAK PENTING TAPI MENDESAK',
    'PENTING TAK MENDESAK',
    'TIDAK PENTING TIDAK MENDESAK',
  ];
  String _selectedStatus = _statusOptions.first.value;
  String? _selectedAgendaId;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _selectedUrgensi;
  AgendaKerjaProvider? _agendaKerjaProvider;

  @override
  void initState() {
    super.initState();
    // MEMANGGIL FETCH AGENDA DI AWAL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final agendaProvider = context.read<AgendaProvider>();
      if (agendaProvider.items.isEmpty && !agendaProvider.loading) {
        agendaProvider.fetch();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gunakan context.read karena kita hanya butuh instance untuk listener
    final agendaKerjaProvider = context.read<AgendaKerjaProvider>();

    if (_agendaKerjaProvider != agendaKerjaProvider) {
      _agendaKerjaProvider?.removeListener(_handleAgendaKerjaChanged);
      _agendaKerjaProvider = agendaKerjaProvider;
      _agendaKerjaProvider?.addListener(_handleAgendaKerjaChanged);

      // Sinkronisasi state awal saat listener pertama kali di-set
      _syncFromAgendaKerjaProvider(agendaKerjaProvider);
    }
  }

  @override
  void dispose() {
    _agendaKerjaProvider?.removeListener(_handleAgendaKerjaChanged);
    deskripsiController.dispose();
    calendarController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  void _handleAgendaKerjaChanged() {
    // Listener ini sekarang aman karena tidak ada `watch` yang konflik
    if (mounted && _agendaKerjaProvider != null) {
      _syncFromAgendaKerjaProvider(_agendaKerjaProvider!);
    }
  }

  void _syncFromAgendaKerjaProvider(AgendaKerjaProvider provider) {
    final providerDate = provider.currentDate;
    var shouldUpdate = false;

    if (providerDate != null &&
        (_selectedDate == null || !_isSameDay(_selectedDate!, providerDate))) {
      _selectedDate = providerDate;
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;
    if (_selectedAgendaId == null || _selectedAgendaId!.isEmpty) {
      _showSnackBar('Agenda wajib dipilih.', true);
      return;
    }
    if (_selectedDate == null) {
      _showSnackBar('Tanggal agenda wajib diisi.', true);
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showSnackBar('Jam mulai dan selesai wajib diisi.', true);
      return;
    }
    if (_selectedUrgensi == null || _selectedUrgensi!.isEmpty) {
      _showSnackBar('Urgensi wajib dipilih.', true);
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
      kebutuhanAgenda: _selectedUrgensi,
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    // Perhatikan: agendaProvider di-'watch' karena dropdown perlu rebuild saat item berubah
    final agendaProvider = context.watch<AgendaProvider>();

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
            Consumer<AgendaKerjaProvider>(
              builder: (context, agendaKerjaProvider, child) {
                return GestureDetector(
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
                );
              },
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
