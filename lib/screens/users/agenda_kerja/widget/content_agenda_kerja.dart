import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/agenda_kerja/create_agenda/create_agenda_screen.dart';
import 'package:e_hrm/screens/users/agenda_kerja/edit_agenda/edit_agenda_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentAgendaKerja extends StatefulWidget {
  const ContentAgendaKerja({super.key});

  @override
  State<ContentAgendaKerja> createState() => _ContentAgendaKerjaState();
}

class _ContentAgendaKerjaState extends State<ContentAgendaKerja> {
  @override
  Widget build(BuildContext context) {
    // Opsi dropdown (urut sesuai permintaan)
    final List<String> _statusOptions = const [
      'Ditunda',
      'Selesai',
      'Diproses',
    ];

    // Nilai terpilih
    String _selectedStatus = 'Diproses';

    final size = MediaQuery.of(context).size;

    // Responsif: skala berdasarkan lebar layar dengan batas min/max
    final radius = (size.width * 0.04).clamp(12.0, 20.0);
    final topHeight = (size.width * 0.15).clamp(44.0, 72.0);
    final padding = (size.width * 0.04).clamp(12.0, 20.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch, // full width
      children: [
        // Header/strip hitam (rounded hanya sisi atas)
        Container(
          width: double.infinity,
          height: topHeight,
          decoration: BoxDecoration(
            color: AppColors.textDefaultColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 4),
                color: Colors.black12,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.album_outlined,
                  color: AppColors.menuColor,
                  size: 12,
                ),
                SizedBox(width: 10),
                Text(
                  "Rabu, 02 September 2025",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Konten putih (rounded hanya sisi bawah)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 4),
                color: Colors.black12,
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Pilih status',
                    hintStyle: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.backgroundColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.menuColor,
                        width: 1.6,
                      ),
                    ),
                  ),
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
                          value: s,
                          child: Text(
                            s,
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
              ),
              //container-agenda-kerja
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(
                      color: AppColors.primaryColor,
                      width: 5, // lebih tebal di kiri
                    ),
                    top: BorderSide(color: AppColors.primaryColor, width: 1),
                    right: BorderSide(color: AppColors.primaryColor, width: 1),
                    bottom: BorderSide(color: AppColors.primaryColor, width: 1),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Kolom utama konten
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rail kiri (jam mulai, titik vertikal, jam selesai)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Jam mulai
                            Container(
                              width: 78,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.textDefaultColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "09:00",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Titik-titik vertikal (ikon)
                            const Icon(Icons.more_vert, size: 22),
                            const SizedBox(height: 10),
                            // Jam selesai
                            Container(
                              width: 78,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.textDefaultColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "11:00",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        // Konten kanan (status, judul, tanggal)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Chip status "Diproses" + chevron
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xfff6f6f6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Diproses",
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Judul
                              Text(
                                "Membuat Design Project Mobile E-HRM OSS Bali",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Tanggal
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "02 September 2025",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Tombol aksi di kanan (hapus & edit)
                    Positioned(
                      right: -30,
                      top: 25,
                      child: Column(
                        children: [
                          // Hapus
                          Material(
                            color: const Color(0xffffe1e8),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {},
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.delete_outline, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Edit
                          Material(
                            color: const Color(0xffffe1e8),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => EditAgendaScreen(),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.edit_outlined, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => CreateAgendaScreen()),
                  );
                },
                child: Container(
                  width: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Card(
                    color: AppColors.textColor,
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle),
                          SizedBox(width: 10),
                          Text(
                            "Pekerjaan",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDefaultColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
