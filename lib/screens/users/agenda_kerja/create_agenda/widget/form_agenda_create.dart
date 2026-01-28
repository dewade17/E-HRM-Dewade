// lib/screens/users/agenda_kerja/create_agenda/widget/form_agenda_create.dart
// ignore_for_file: deprecated_member_use
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/agenda/agenda.dart';
import 'package:e_hrm/providers/agenda/agenda_provider.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/shared_widget/agenda_selection_field.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:e_hrm/shared_widget/time_picker_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormAgendaCreate extends StatefulWidget {
  const FormAgendaCreate({super.key});

  @override
  State<FormAgendaCreate> createState() => _FormAgendaCreateState();
}

class _FormAgendaCreateState extends State<FormAgendaCreate> {
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  final List<String> _urgensiItems = [
    'PENTING MENDESAK',
    'TIDAK PENTING TAPI MENDESAK',
    'PENTING TAK MENDESAK',
    'TIDAK PENTING TIDAK MENDESAK',
  ];

  String _selectedStatus = _statusOptions.first.value;
  AgendaItem? _selectedAgenda;

  final List<TextEditingController> _dateControllers =
      <TextEditingController>[];
  final List<DateTime?> _dateValues = <DateTime?>[];

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _selectedUrgensi;
  AgendaKerjaProvider? _agendaKerjaProvider;

  @override
  void initState() {
    super.initState();

    final initialProvider = context.read<AgendaKerjaProvider>();
    final initialDate = initialProvider.currentDate;

    _initDateRows(initialDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final agendaProvider = context.read<AgendaProvider>();
      if (agendaProvider.items.isEmpty && !agendaProvider.loading) {
        agendaProvider.fetch();
      }
    });
  }

  void _initDateRows(DateTime? initialDate) {
    _dateControllers.clear();
    _dateValues.clear();

    _dateControllers.add(TextEditingController());
    _dateValues.add(initialDate);

    if (initialDate != null) {
      _dateControllers.first.text = _formatDate(initialDate);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final agendaKerjaProvider = context.read<AgendaKerjaProvider>();

    if (_agendaKerjaProvider != agendaKerjaProvider) {
      _agendaKerjaProvider?.removeListener(_handleAgendaKerjaChanged);
      _agendaKerjaProvider = agendaKerjaProvider;
      _agendaKerjaProvider?.addListener(_handleAgendaKerjaChanged);

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
    startTimeController.dispose();
    endTimeController.dispose();
    for (final c in _dateControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleAgendaKerjaChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _agendaKerjaProvider != null) {
        _syncFromAgendaKerjaProvider(_agendaKerjaProvider!);
      }
    });
  }

  void _syncFromAgendaKerjaProvider(AgendaKerjaProvider provider) {
    final providerDate = provider.currentDate;
    if (providerDate == null) return;

    var shouldUpdate = false;

    if (_dateValues.isEmpty) {
      _initDateRows(providerDate);
      shouldUpdate = true;
    } else {
      final first = _dateValues.first;
      final isDifferent = first == null
          ? true
          : !_isSameDay(first, providerDate);

      if (isDifferent || _dateValues.length != 1) {
        for (final c in _dateControllers) {
          c.dispose();
        }
        _initDateRows(providerDate);
        shouldUpdate = true;
      }
    }

    if (shouldUpdate && mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final formState = formKey.currentState;
    if (formState == null) return;

    setState(() => _autoValidate = true);

    if (!formState.validate()) return;

    if (_selectedAgenda == null) {
      _showSnackBar('Agenda wajib dipilih.', true);
      return;
    }

    final dates = _dateValues.whereType<DateTime>().toList();
    if (dates.isEmpty || dates.length != _dateValues.length) {
      _showSnackBar('Tanggal agenda wajib diisi.', true);
      return;
    }

    final uniqueDays = <String>{};
    for (final d in dates) {
      final key = '${d.year}-${d.month}-${d.day}';
      if (!uniqueDays.add(key)) {
        _showSnackBar('Tanggal tidak boleh duplikat.', true);
        return;
      }
    }

    if (_startTime == null || _endTime == null) {
      _showSnackBar('Jam mulai dan selesai wajib diisi.', true);
      return;
    }

    if (_selectedUrgensi == null || _selectedUrgensi!.isEmpty) {
      _showSnackBar('Urgensi wajib dipilih.', true);
      return;
    }

    final sortedDates = List<DateTime>.of(dates)
      ..sort((a, b) => a.compareTo(b));

    final startDates = sortedDates
        .map((date) => _combineDateTime(date, _startTime!))
        .toList();
    final endDates = sortedDates
        .map((date) => _combineDateTime(date, _endTime!))
        .toList();

    for (var i = 0; i < startDates.length; i += 1) {
      if (!endDates[i].isAfter(startDates[i])) {
        _showSnackBar('Jam selesai harus lebih besar dari jam mulai.', true);
        return;
      }
    }

    final durationSeconds = endDates.first
        .difference(startDates.first)
        .inSeconds;

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
      idAgenda: _selectedAgenda!.idAgenda,
      deskripsiKerja: deskripsiController.text,
      status: _selectedStatus,
      startDates: startDates,
      endDates: endDates,
      durationSeconds: durationSeconds,
      kebutuhanAgenda: _selectedUrgensi,
    );

    if (!mounted) return;

    final message = provider.message ?? 'Agenda kerja berhasil dibuat.';
    final errorMessage = provider.error ?? 'Gagal membuat agenda kerja.';

    if (created != null) {
      final successMessage = sortedDates.length > 1
          ? 'Agenda kerja berhasil dibuat untuk ${sortedDates.length} tanggal.'
          : message;
      _showSnackBar(successMessage, false);
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

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  void _addDateRow() {
    setState(() {
      _dateControllers.add(TextEditingController());
      _dateValues.add(null);
    });
  }

  void _removeDateRow(int index) {
    if (_dateControllers.length <= 1) return;
    setState(() {
      _dateControllers[index].dispose();
      _dateControllers.removeAt(index);
      _dateValues.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final autovalidateMode = _autoValidate
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            AgendaSelectionField(
              backgroundColor: AppColors.textColor,
              borderColor: AppColors.textDefaultColor,
              label: 'Agenda',
              selectedAgenda: _selectedAgenda,
              isRequired: true,
              onAgendaSelected: (selected) {
                setState(() => _selectedAgenda = selected);
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
            ),
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
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.textColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.textDefaultColor.withOpacity(0.2),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal Agenda",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDefaultColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List<Widget>.generate(_dateControllers.length, (
                      index,
                    ) {
                      final canRemove = _dateControllers.length > 1;
                      final isLast = index == _dateControllers.length - 1;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _dateControllers.length - 1 ? 0 : 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DatePickerFieldWidget(
                                backgroundColor: AppColors.textColor,
                                borderColor: AppColors.textDefaultColor,
                                label: 'Pilih Tanggal',
                                controller: _dateControllers[index],
                                initialDate: _dateValues[index],
                                onDateChanged: (date) {
                                  if (date == null) return;
                                  setState(() {
                                    _dateValues[index] = date;
                                    _dateControllers[index].text = _formatDate(
                                      date,
                                    );
                                  });
                                },
                                isRequired: true,
                                validator: (_) {
                                  if (_dateValues.length <= index ||
                                      _dateValues[index] == null) {
                                    return 'Tanggal wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: ElevatedButton(
                                    onPressed: isLast ? _addDateRow : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: AppColors.textColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: ElevatedButton(
                                    onPressed: canRemove
                                        ? () => _removeDateRow(index)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.errorColor,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      color: AppColors.textColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
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
                    validator: (_) {
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
                    validator: (_) {
                      if (_endTime == null) return 'Wajib diisi';
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
