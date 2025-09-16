import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarEditAgenda extends StatefulWidget {
  final TextEditingController calendarController;
  final DateTime? initialDate;
  final ValueChanged<DateTime?>? onDateChanged;

  const CalendarEditAgenda({
    super.key,
    required this.calendarController,
    this.initialDate,
    this.onDateChanged,
  });

  @override
  State<CalendarEditAgenda> createState() => _CalendarEditAgendaState();
}

class _CalendarEditAgendaState extends State<CalendarEditAgenda> {
  DateTime? selectedDate;
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    if (selectedDate != null) {
      widget.calendarController.text = _dateFormatter.format(selectedDate!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDateChanged?.call(selectedDate);
      });
    }
  }

  @override
  void didUpdateWidget(covariant CalendarEditAgenda oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      final newDate = widget.initialDate;
      if (newDate != null) {
        widget.calendarController.text = _dateFormatter.format(newDate);
      } else {
        widget.calendarController.clear();
      }
      setState(() {
        selectedDate = newDate;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final DateTime initial = selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              headlineLarge: TextStyle(fontSize: 20),
              titleLarge: TextStyle(fontSize: 16),
              bodyLarge: TextStyle(fontSize: 14),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() {
      selectedDate = DateTime(picked.year, picked.month, picked.day);
      widget.calendarController.text = _dateFormatter.format(selectedDate!);
    });

    widget.onDateChanged?.call(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' Tanggal Agenda',
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
              child: GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: widget.calendarController,
                    decoration: const InputDecoration(
                      hintText: 'dd/mm/yyyy',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal belum dipilih';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
