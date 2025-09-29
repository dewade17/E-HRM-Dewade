import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarProfile extends StatefulWidget {
  final TextEditingController calendarController;
  final DateTime? initialDate;
  final ValueChanged<DateTime?>? onDateChanged;

  const CalendarProfile({
    super.key,
    required this.calendarController,
    this.initialDate,
    this.onDateChanged,
  });

  @override
  State<CalendarProfile> createState() => _CalendarProfileState();
}

class _CalendarProfileState extends State<CalendarProfile> {
  DateTime? selectedDate;
  final DateFormat _dateFormatter = DateFormat(
    'dd MMMM yyyy',
    'id_ID',
  ); // Format lebih deskriptif

  @override
  void initState() {
    super.initState();
    // Inisialisasi locale untuk format tanggal Indonesia
    // Jika Anda belum menambahkannya di main.dart, ini adalah cara lokal
    // Intl.defaultLocale = 'id_ID';

    selectedDate = widget.initialDate;
    if (selectedDate != null) {
      widget.calendarController.text = _dateFormatter.format(selectedDate!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDateChanged?.call(selectedDate);
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale(
        'id',
        'ID',
      ), // Menampilkan kalender dalam Bahasa Indonesia
      builder: (context, child) {
        // Kustomisasi tema date picker agar lebih modern
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor, // Warna utama
              onPrimary: Colors.white, // Warna teks di atas warna utama
              onSurface: AppColors.textDefaultColor, // Warna teks di kalender
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.primaryColor, // Warna tombol OK dan Batal
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Lahir', // Menghilangkan spasi di awal
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textDefaultColor,
          ),
        ),
        const SizedBox(height: 8),
        // Menggunakan TextFormField secara langsung untuk UI yang lebih baik
        TextFormField(
          controller: widget.calendarController,
          readOnly: true, // Membuat field tidak bisa diketik manual
          onTap: _pickDate, // Memanggil date picker saat ditekan
          decoration: InputDecoration(
            hintText: 'Pilih tanggal...', // Hint text yang lebih jelas
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),

            // Menambahkan ikon kalender agar lebih jelas
            prefixIcon: Icon(
              Icons.calendar_today,
              color: AppColors.primaryColor,
            ),
            // Menggunakan border yang lebih modern
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tanggal lahir wajib diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
