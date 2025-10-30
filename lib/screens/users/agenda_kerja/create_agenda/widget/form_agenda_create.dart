// lib/screens/users/agenda_kerja/create_agenda/widget/form_agenda_create.dart
// ignore_for_file: deprecated_member_use
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/agenda/agenda.dart'; // <-- Import DTO Agenda
import 'package:e_hrm/providers/agenda/agenda_provider.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/shared_widget/agenda_selection_field.dart'; // <-- Import Field Baru
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
  bool _autoValidate = false; // Ubah ke false
  final List<String> _urgensiItems = [
    'PENTING MENDESAK',
    'TIDAK PENTING TAPI MENDESAK',
    'PENTING TAK MENDESAK',
    'TIDAK PENTING TIDAK MENDESAK',
  ];
  String _selectedStatus = _statusOptions.first.value;
  // String? _selectedAgendaId; // <-- Ganti ini
  AgendaItem? _selectedAgenda; // <-- Dengan ini (simpan objek AgendaItem)
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _selectedUrgensi;
  AgendaKerjaProvider? _agendaKerjaProvider;

  @override
  void initState() {
    super.initState();
    // Pre-fill the date from the provider if it's already available
    final initialProvider = context.read<AgendaKerjaProvider>();
    if (initialProvider.currentDate != null) {
      _selectedDate = initialProvider.currentDate;
    }

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
    final agendaKerjaProvider = context.read<AgendaKerjaProvider>();

    if (_agendaKerjaProvider != agendaKerjaProvider) {
      _agendaKerjaProvider?.removeListener(_handleAgendaKerjaChanged);
      _agendaKerjaProvider = agendaKerjaProvider;
      _agendaKerjaProvider?.addListener(_handleAgendaKerjaChanged);

      // Jadwalkan sinkronisasi setelah build selesai
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncFromAgendaKerjaProvider(agendaKerjaProvider);
        }
      });
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
    // --- PERBAIKAN UNTUK KEAMANAN ---
    // Pastikan listener juga menjalankan setState setelah build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _agendaKerjaProvider != null) {
        _syncFromAgendaKerjaProvider(_agendaKerjaProvider!);
      }
    });
  }

  void _syncFromAgendaKerjaProvider(AgendaKerjaProvider provider) {
    final providerDate = provider.currentDate;
    var shouldUpdate = false;

    if (providerDate != null &&
        (_selectedDate == null || !_isSameDay(_selectedDate!, providerDate))) {
      _selectedDate = providerDate;
      shouldUpdate = true;
    }

    if (shouldUpdate && mounted) {
      // Pemanggilan setState sekarang aman karena berada di dalam post-frame callback
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final formState = formKey.currentState;
    if (formState == null) return; // Tambah pengecekan null

    // Set autoValidate sebelum validasi
    setState(() => _autoValidate = true);

    if (!formState.validate()) return;

    // Validasi lain tetap sama
    if (_selectedAgenda == null) {
      // <-- Cek objek AgendaItem
      _showSnackBar('Agenda wajib dipilih.', true);
      return;
    }
    // ... (validasi tanggal, jam, urgensi tetap sama) ...
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

    // ... (ensureUserId tetap sama) ...
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
      idAgenda: _selectedAgenda!.idAgenda, // <-- Ambil ID dari objek
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
    // final agendaProvider = context.watch<AgendaProvider>(); // Tidak perlu watch lagi di sini

    final autovalidateMode = _autoValidate
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;
    return Form(
      key: formKey,
      // Autovalidate di form agar semua field terpengaruh
      autovalidateMode: autovalidateMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // --- GANTI DROPDOWN DENGAN FIELD BARU ---
            AgendaSelectionField(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Agenda',
              selectedAgenda: _selectedAgenda,
              isRequired: true,
              onAgendaSelected: (selected) {
                setState(() => _selectedAgenda = selected);
                // Trigger validasi ulang jika form sudah pernah divalidasi
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

            // Loading indicator untuk AgendaProvider bisa ditaruh di sini jika perlu
            Consumer<AgendaProvider>(
              builder: (context, agendaProv, _) {
                if (agendaProv.loading && agendaProv.items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

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
                    onChanged: (time) => setState(() => _startTime = time),
                    isRequired: true,
                    // Tambahkan validator untuk time picker jika perlu
                    validator: (value) {
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
                    onChanged: (time) => setState(() => _endTime = time),
                    isRequired: true,
                    // Tambahkan validator untuk time picker jika perlu
                    validator: (value) {
                      if (_endTime == null) return 'Wajib diisi';
                      // Validasi tambahan: jam selesai > jam mulai
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
              // Validator sudah otomatis ditangani oleh DropdownFieldWidget
              // validator: (value) => ...
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
  _StatusOption(value: 'teragenda', label: 'Teragenda'),
  _StatusOption(value: 'diproses', label: 'Diproses'),
  _StatusOption(value: 'selesai', label: 'Selesai'),
  _StatusOption(value: 'ditunda', label: 'Ditunda'),
];
