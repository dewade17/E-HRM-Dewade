import 'dart:io';

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/profile/profile.dart' as dto;
import 'package:e_hrm/providers/profile/profile_provider.dart';
import 'package:e_hrm/screens/users/profile/widget/calendar_profile.dart';
import 'package:e_hrm/screens/users/profile/widget/foto_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FormProfile extends StatefulWidget {
  final ProfileProvider provider;
  final String? userId;

  const FormProfile({super.key, required this.provider, this.userId});

  @override
  State<FormProfile> createState() => _FormProfileState();
}

class _FormProfileState extends State<FormProfile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namapenggunaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController alamatdomisiliController =
      TextEditingController();
  final TextEditingController alamatktpController = TextEditingController();
  final TextEditingController kontakController = TextEditingController();
  final TextEditingController tanggallahirController = TextEditingController();
  final TextEditingController nomorRekeningController = TextEditingController();
  final TextEditingController jenisbankController = TextEditingController();
  final TextEditingController kontakdaruratController = TextEditingController();
  final TextEditingController namakontakdaruratController =
      TextEditingController();

  final DateFormat _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  dto.Data? _lastProfile;
  DateTime? _selectedDate;
  String? golonganDarahValue;
  String? agamaValue;
  File? _pickedPhoto;
  bool _removePhoto = false;

  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_onProviderChanged);
    _syncFromProvider(widget.provider);
  }

  @override
  void didUpdateWidget(covariant FormProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      oldWidget.provider.removeListener(_onProviderChanged);
      widget.provider.addListener(_onProviderChanged);
      _syncFromProvider(widget.provider);
    }
  }

  @override
  void dispose() {
    widget.provider.removeListener(_onProviderChanged);
    namapenggunaController.dispose();
    emailController.dispose();
    alamatdomisiliController.dispose();
    alamatktpController.dispose();
    kontakController.dispose();
    tanggallahirController.dispose();
    nomorRekeningController.dispose();
    jenisbankController.dispose();
    kontakdaruratController.dispose();
    namakontakdaruratController.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (!mounted) return;
    final profile = widget.provider.profile;
    if (profile != null && !identical(profile, _lastProfile)) {
      _syncFromProvider(widget.provider);
    }
  }

  void _syncFromProvider(ProfileProvider provider) {
    final profile = provider.profile;
    if (profile == null) return;
    _lastProfile = profile;

    final alamatDomisili = _asString(profile.alamatDomisili);
    final alamatKtp = _asString(profile.alamatKtp);
    final kontak = _asString(profile.kontak);
    final agama = _nullableString(profile.agama);
    final golongan = _nullableString(profile.golonganDarah);
    final nomorRekening = _asString(profile.nomorRekening);
    final jenisBank = _asString(profile.jenisBank);
    final tanggal = _parseDate(profile.tanggalLahir);

    namapenggunaController.text = profile.namaPengguna;
    emailController.text = profile.email;
    alamatdomisiliController.text = alamatDomisili;
    alamatktpController.text = alamatKtp;
    kontakController.text = kontak;
    nomorRekeningController.text = nomorRekening;
    jenisbankController.text = jenisBank;

    setState(() {
      agamaValue = agama;
      golonganDarahValue = golongan;
      _selectedDate = tanggal;
      tanggallahirController.text = tanggal != null
          ? _dateFormatter.format(tanggal)
          : '';
      _pickedPhoto = null;
      _removePhoto = false;
    });
  }

  String _asString(dynamic value) {
    if (value == null) return '';
    final text = value.toString();
    if (text.toLowerCase() == 'null') return '';
    return text;
  }

  String? _nullableString(dynamic value) {
    final text = _asString(value).trim();
    return text.isEmpty ? null : text;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      final raw = value.trim();
      if (raw.isEmpty) return null;
      DateTime? parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
      try {
        parsed = DateFormat('yyyy-MM-dd').parse(raw);
        return parsed;
      } catch (_) {
        // ignore
      }
    }
    return null;
  }

  Future<void> _submit() async {
    final provider = widget.provider;
    final id = (widget.userId ?? provider.profile?.idUser)?.trim();
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID pengguna tidak ditemukan.')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    http.MultipartFile? foto;
    if (_pickedPhoto != null) {
      try {
        foto = await http.MultipartFile.fromPath('foto', _pickedPhoto!.path);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat foto: $e')));
        return;
      }
    }

    final formattedBirthDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : null;

    final body = <String, dynamic>{
      'nama_pengguna': namapenggunaController.text.trim(),
      'email': emailController.text.trim(),
      'alamat_domisili': alamatdomisiliController.text.trim(),
      'alamat_ktp': alamatktpController.text.trim(),
      'kontak': kontakController.text.trim(),
      'agama': agamaValue,
      'tanggal_lahir': formattedBirthDate,
      'golongan_darah': golonganDarahValue,
      'nomor_rekening': nomorRekeningController.text.trim(),
      'jenis_bank': jenisbankController.text.trim(),
      'kontak_darurat': kontakdaruratController.text.trim(),
      'nama_kontak_darurat': namakontakdaruratController.text.trim(),
    };

    final success = await provider.updateProfile(
      id,
      body,
      foto: foto,
      removePhoto: _removePhoto && foto == null,
    );

    if (!mounted) return;

    final message = success
        ? (provider.lastMessage ?? 'Profil berhasil diperbarui.')
        : (provider.error ?? 'Gagal memperbarui profil.');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (success) {
      setState(() {
        _removePhoto = false;
        _pickedPhoto = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final isSaving = provider.saving;
    final imageUrl = _nullableString(provider.profile?.fotoProfilUser);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: Container(
            width: 328,
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: AppColors.primaryColor),
            ),
            child: Stack(
              children: [
                AbsorbPointer(
                  absorbing: isSaving,
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 70),
                          if (provider.error != null &&
                              provider.profile != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              child: Text(
                                provider.error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          _buildTextField(
                            label: 'Nama Lengkap',
                            controller: namapenggunaController,
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Email',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (text.isEmpty) {
                                return 'Email wajib diisi';
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(text)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Alamat Domisili',
                            controller: alamatdomisiliController,
                            keyboardType: TextInputType.streetAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Alamat KTP',
                            controller: alamatktpController,
                            keyboardType: TextInputType.streetAddress,
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ), // <-- Tambahkan ini
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Kontak',
                                    controller: kontakController,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildDropdown(
                                    label: 'Agama',
                                    value: agamaValue,
                                    items: const [
                                      'Islam',
                                      'Kristen',
                                      'Katolik',
                                      'Hindu',
                                      'Buddha',
                                      'Konghucu',
                                    ],
                                    onChanged: (value) {
                                      setState(() => agamaValue = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ), // <-- Tambahkan ini juga
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: CalendarProfile(
                                    calendarController: tanggallahirController,
                                    initialDate: _selectedDate,
                                    onDateChanged: (value) {
                                      setState(() {
                                        _selectedDate = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildDropdown(
                                    label: 'Golongan Darah',
                                    value: golonganDarahValue,
                                    items: const ['A', 'B', 'AB', 'O'],
                                    onChanged: (value) {
                                      setState(
                                        () => golonganDarahValue = value,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Nomor Rekening',
                            controller: nomorRekeningController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Jenis Bank',
                            controller: jenisbankController,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Kontak Darurat',
                            controller: kontakdaruratController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Nama Kontak Darurat',
                            controller: namakontakdaruratController,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                // <-- Ganti menjadi ElevatedButton
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: isSaving ? null : _submit,
                                child:
                                    isSaving // <-- Ganti 'label' dan 'icon' menjadi 'child'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ), // Jarak antara loading dan teks
                                          Text(
                                            'Menyimpan...',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Simpan',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isSaving)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -70,
          left: 120,
          child: FotoProfile(
            imageUrl: imageUrl,
            onPicked: (file) {
              setState(() {
                _pickedPhoto = file;
                _removePhoto = false;
              });
            },
            onRemove: () {
              setState(() {
                _pickedPhoto = null;
                _removePhoto = true;
              });
            },
            enabled: !isSaving,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 290,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' $label',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
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
                controller: controller,
                keyboardType: keyboardType,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: validator,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? value,
  }) {
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' $label',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
              child: DropdownButtonFormField<String?>(
                key: ValueKey<String?>('$label-$value'),
                value: value,
                icon: const Icon(Icons.arrow_drop_down),
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                items: items
                    .map(
                      (item) => DropdownMenuItem<String?>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
                hint: Text('Pilih $label'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
