import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kunjungan/kunjungan_klien.dart';
import 'package:e_hrm/providers/approvers/approvers_absensi_provider.dart';
import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/mark_me_map.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/recipient_kunjungan.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FormEndKunjungan extends StatefulWidget {
  const FormEndKunjungan({super.key, required this.item});

  final Data item;

  @override
  State<FormEndKunjungan> createState() => _FormEndKunjunganState();
}

class _FormEndKunjunganState extends State<FormEndKunjungan> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  late final TextEditingController latitudeEndcontroller;
  late final TextEditingController longitudeEndcontroller;
  late final TextEditingController keterangankunjungancontroller;
  String? _selectedKategoriId;
  bool _didInitProviders = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    latitudeEndcontroller = TextEditingController(
      text: item.endLatitude != null
          ? item.endLatitude!.toStringAsFixed(6)
          : '',
    );
    longitudeEndcontroller = TextEditingController(
      text: item.endLongitude != null
          ? item.endLongitude!.toStringAsFixed(6)
          : '',
    );
    keterangankunjungancontroller = TextEditingController(
      text: item.deskripsi ?? '',
    );
    _selectedKategoriId =
        item.idKategoriKunjungan ?? item.kategoriIdFromRelation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didInitProviders) return;
      _didInitProviders = true;

      final kategoriProvider = context.read<KategoriKunjunganProvider>();
      kategoriProvider.ensureLoaded();
      if (_selectedKategoriId != null) {
        kategoriProvider.setSelectedId(_selectedKategoriId);
      }

      final approverProvider = context.read<ApproversProvider>();
      approverProvider.clearSelection();
      for (final report in widget.item.reports) {
        final id = report.idUser;
        if (id != null &&
            id.isNotEmpty &&
            !approverProvider.selectedRecipientIds.contains(id)) {
          approverProvider.toggleSelect(id);
        }
      }
    });
  }

  @override
  void dispose() {
    latitudeEndcontroller.dispose();
    longitudeEndcontroller.dispose();
    keterangankunjungancontroller.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.accentColor,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    setState(() {
      _autoValidate = true;
    });

    if (!formState.validate()) {
      return;
    }

    final latitude = double.tryParse(latitudeEndcontroller.text.trim());
    final longitude = double.tryParse(longitudeEndcontroller.text.trim());

    if (latitude == null || longitude == null) {
      _showSnackBar(
        'Silakan tandai lokasi akhir kunjungan terlebih dahulu.',
        isError: true,
      );
      return;
    }

    final kategoriProvider = context.read<KategoriKunjunganProvider>();
    final kunjunganProvider = context.read<KunjunganKlienProvider>();
    if (kunjunganProvider.isSaving) return;

    final approverProvider = context.read<ApproversProvider>();

    final kategoriId =
        _selectedKategoriId ??
        kategoriProvider.selectedId ??
        widget.item.idKategoriKunjungan ??
        widget.item.kategoriIdFromRelation;

    if (kategoriId == null || kategoriId.isEmpty) {
      _showSnackBar(
        'Silakan pilih jenis kunjungan terlebih dahulu.',
        isError: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final deskripsi = keterangankunjungancontroller.text.trim();

    final selectedUserMap = {
      for (final user in approverProvider.selectedUsers) user.idUser: user,
    };
    final existingRecipientMap = {
      for (final report in widget.item.reports)
        if (report.idUser != null && report.idUser!.isNotEmpty)
          report.idUser!: report,
    };

    final recipients = approverProvider.selectedRecipientIds
        .where((id) => id.trim().isNotEmpty)
        .map((id) {
          final user = selectedUserMap[id];
          final existing = existingRecipientMap[id];
          final name =
              (user?.namaPengguna ?? existing?.recipientNamaSnapshot)?.trim() ??
              '';
          final role = (user?.role ?? existing?.recipientRoleSnapshot)?.trim();

          return {
            'id_user': id,
            if (name.isNotEmpty) 'recipient_nama_snapshot': name,
            if (role != null && role.isNotEmpty)
              'recipient_role_snapshot': role.toUpperCase(),
          };
        })
        .toList();

    if (recipients.isNotEmpty &&
        recipients.any((recipient) {
          final nameValue = recipient['recipient_nama_snapshot'];
          return nameValue is! String || nameValue.trim().isEmpty;
        })) {
      _showSnackBar(
        'Data approver tidak lengkap. Silakan muat ulang daftar approver.',
        isError: true,
      );
      return;
    }
    await kunjunganProvider.submitEndKunjungan(
      widget.item.idKunjungan,
      deskripsi: deskripsi.isEmpty ? null : deskripsi,
      jamCheckout: DateTime.now(),
      endLatitude: latitude,
      endLongitude: longitude,
      idKategoriKunjungan: kategoriId,
      recipients: recipients.isEmpty ? null : recipients,
    );

    if (!mounted) return;

    final error = kunjunganProvider.saveError;
    final message = kunjunganProvider.saveMessage;

    if (error != null) {
      _showSnackBar(error, isError: true);
      return;
    }

    if (message != null && message.isNotEmpty) {
      _showSnackBar(message);
    } else {
      _showSnackBar('Kunjungan berhasil diselesaikan.');
    }

    Navigator.of(context).maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    final kategoriProvider = context.watch<KategoriKunjunganProvider>();
    final kunjunganProvider = context.watch<KunjunganKlienProvider>();
    final isSaving = kunjunganProvider.isSaving;
    final autovalidateMode = _autoValidate
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;

    final dropdownItems = kategoriProvider.items
        .map(
          (item) => DropdownMenuItem<String>(
            value: item.idKategoriKunjungan,
            child: Text(item.kategoriKunjungan),
          ),
        )
        .toList();

    final currentKategoriId = _selectedKategoriId;
    final hasExistingInItems =
        currentKategoriId != null &&
        dropdownItems.any((element) => element.value == currentKategoriId);
    if (currentKategoriId != null && !hasExistingInItems) {
      final fallbackLabel =
          widget.item.kategori?.kategoriKunjungan ?? 'Kategori tersimpan';
      dropdownItems.insert(
        0,
        DropdownMenuItem<String>(
          value: currentKategoriId,
          child: Text(fallbackLabel),
        ),
      );
    }

    return Center(
      child: Container(
        width: 338,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.backgroundColor),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    MarkMeMap(
                      latitudeController: latitudeEndcontroller,
                      longitudeController: longitudeEndcontroller,
                      onPicked: (lat, lng) {
                        latitudeEndcontroller.text = lat.toStringAsFixed(6);
                        longitudeEndcontroller.text = lng.toStringAsFixed(6);
                      },
                    ),
                    FormField<bool>(
                      autovalidateMode: autovalidateMode,
                      validator: (_) {
                        if (latitudeEndcontroller.text.isEmpty ||
                            longitudeEndcontroller.text.isEmpty) {
                          return 'Silakan tandai lokasi terlebih dulu.';
                        }
                        return null;
                      },
                      builder: (state) {
                        if (state.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              state.errorText!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFieldWidget(
                width: 300,
                prefixIcon: Icons.message,
                maxLines: 3,
                label: 'Keterangan',
                controller: keterangankunjungancontroller,
                autovalidateMode: autovalidateMode,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 5,
                  ),
                  child: Text(
                    'Laporan Ke',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: const RecipientKunjungan(),
              ),
              const SizedBox(height: 20),
              DropdownFieldWidget<String>(
                width: 300,
                prefixIcon: Icons.add_box_outlined,
                label: 'Jenis Kunjungan',
                hintText: 'Pilih jenis kunjungan...',
                value: currentKategoriId,
                items: dropdownItems,
                autovalidateMode: autovalidateMode,
                onChanged: isSaving
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedKategoriId = newValue;
                        });
                        if (newValue != null) {
                          kategoriProvider.setSelectedId(newValue);
                        }
                      },
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return 'Anda harus memilih jenis kunjungan.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Bukti Kunjungan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDefaultColor,
                    ),
                  ),
                ),
              ),
              if ((widget.item.lampiranKunjunganUrl ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      // <-- INI PERUBAHANNYA
                      widget.item.lampiranKunjunganUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 42,
                            color: Colors.black38,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Belum ada bukti kunjungan.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  foregroundColor: AppColors.menuColor,
                ),
                onPressed: isSaving ? null : _handleSubmit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(
                          'Selesai',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
