// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/departements/departements.dart';
import 'package:e_hrm/dto/kategori_keperluan/kategori_keperluan.dart'
    as dto_kategori;
import 'package:e_hrm/providers/approvers/approvers_finance_provider.dart';

import 'package:e_hrm/providers/payment/payment_provider.dart';
import 'package:e_hrm/screens/users/finance/widget/recipient_finance.dart';
import 'package:e_hrm/shared_widget/confirmation_dialog.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/department_selection_field.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/kategori_keperluan_selection_field.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:e_hrm/utils/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentPayment extends StatefulWidget {
  const ContentPayment({super.key});

  @override
  State<ContentPayment> createState() => _ContentPaymentState();
}

class _ContentPaymentState extends State<ContentPayment> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController _noRekeningController = TextEditingController();
  final TextEditingController _jenisBankController = TextEditingController();
  final TextEditingController _namaPemilikRekeningController =
      TextEditingController();

  Departements? _selectedDepartment;
  dto_kategori.Data? _selectedKategori;

  DateTime? _selectedTanggal;

  File? _buktiFile;

  String? _metodePembayaran;
  final List<String> _listMetode = ["Cash", "Transfer"];

  final DateFormat _tanggalParser = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void dispose() {
    tanggalController.dispose();
    keteranganController.dispose();
    nominalController.dispose();
    _noRekeningController.dispose();
    _jenisBankController.dispose();
    _namaPemilikRekeningController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final deptId = (_selectedDepartment?.idDepartement ?? '').trim();
    if (deptId.isEmpty) {
      _showSnackBar('Departemen wajib dipilih.', isError: true);
      return;
    }

    final kategoriId = (_selectedKategori?.idKategoriKeperluan ?? '').trim();
    if (kategoriId.isEmpty) {
      _showSnackBar('Kategori keperluan wajib dipilih.', isError: true);
      return;
    }

    final metode = (_metodePembayaran ?? '').trim();
    if (metode.isEmpty) {
      _showSnackBar('Metode pembayaran wajib dipilih.', isError: true);
      return;
    }

    final nominal = _normalizeNominal(nominalController.text);
    if (nominal.isEmpty) {
      _showSnackBar('Nominal pembayaran wajib diisi.', isError: true);
      return;
    }

    final approvers = context.read<ApproversFinanceProvider>();
    if (approvers.selectedRecipientIds.isEmpty) {
      _showSnackBar(
        'Pilih minimal satu penerima laporan (supervisi).',
        isError: true,
      );
      return;
    }

    if (_buktiFile == null) {
      _showSnackBar('Bukti pembayaran wajib diupload.', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "Kirim Payment?",
        subtitle: "Pastikan data payment yang Anda masukkan sudah benar.",
        confirmText: "Ya, Kirim",
        onConfirm: () {
          Navigator.pop(context);
          FocusScope.of(context).unfocus();
          _submitPayment();
        },
      ),
    );
  }

  Future<void> _submitPayment() async {
    if (!mounted) return;

    final deptId = (_selectedDepartment?.idDepartement ?? '').trim();
    final kategoriId = (_selectedKategori?.idKategoriKeperluan ?? '').trim();
    final metode = (_metodePembayaran ?? '').trim();
    final nominal = _normalizeNominal(nominalController.text);

    final DateTime? tanggal =
        _selectedTanggal ?? _tryParseTanggal(tanggalController.text);
    if (tanggal == null) {
      _showSnackBar('Tanggal tidak valid.', isError: true);
      return;
    }

    if (nominal.isEmpty) {
      _showSnackBar('Nominal pembayaran wajib diisi.', isError: true);
      return;
    }

    http.MultipartFile? buktiFile;
    try {
      buktiFile = await http.MultipartFile.fromPath(
        'bukti_pembayaran',
        _buktiFile!.path,
      );
    } catch (e) {
      _showSnackBar('Gagal membaca bukti pembayaran: $e', isError: true);
      return;
    }

    final approversProvider = context.read<ApproversFinanceProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final approvals = _buildApprovalsFromProvider(approversProvider);

    final created = await paymentProvider.createPayment(
      idDepartement: deptId,
      idKategoriKeperluan: kategoriId,
      tanggal: tanggal,
      nominalPembayaran: nominal,
      metodePembayaran: metode,
      keterangan: keteranganController.text.trim(),
      nomorRekening: metode == 'Transfer'
          ? _noRekeningController.text.trim()
          : null,
      namaPemilikRekening: metode == 'Transfer'
          ? _namaPemilikRekeningController.text.trim()
          : null,
      jenisBank: metode == 'Transfer' ? _jenisBankController.text.trim() : null,
      buktiPembayaranFile: buktiFile,
      approvals: approvals,
    );

    if (!mounted) return;

    final err = paymentProvider.saveError;
    final msg = paymentProvider.saveMessage;

    if (err != null && err.isNotEmpty) {
      _showSnackBar(err, isError: true);
      return;
    }

    if (msg != null && msg.isNotEmpty) {
      _showSnackBar(msg, isError: false);
    } else if (created != null) {
      _showSnackBar('Payment berhasil dibuat.', isError: false);
    }

    final popPayload = created ?? true;

    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(popPayload);
      return;
    }

    // fallback kalau tidak bisa pop (jarang terjadi)
    formKey.currentState?.reset();
    setState(() {
      _selectedDepartment = null;
      _selectedKategori = null;
      _selectedTanggal = null;
      _metodePembayaran = null;
      _buktiFile = null;

      tanggalController.clear();
      keteranganController.clear();
      nominalController.clear();

      _noRekeningController.clear();
      _jenisBankController.clear();
      _namaPemilikRekeningController.clear();
    });
  }

  String _normalizeNominal(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  DateTime? _tryParseTanggal(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    try {
      return _tanggalParser.parseStrict(raw);
    } catch (_) {}

    for (final fmt in <String>['dd-MM-yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd']) {
      try {
        return DateFormat(fmt, 'id_ID').parseStrict(raw);
      } catch (_) {}
    }

    return null;
  }

  List<Map<String, dynamic>> _buildApprovalsFromProvider(
    ApproversFinanceProvider provider,
  ) {
    final selected = provider.selectedUsers
        .where((user) => user.idUser.trim().isNotEmpty)
        .toList(growable: false);
    if (selected.isEmpty) return <Map<String, dynamic>>[];

    return List<Map<String, dynamic>>.generate(selected.length, (index) {
      final user = selected[index];
      final role = user.role.trim().toUpperCase();
      return <String, dynamic>{
        'approver_user_id': user.idUser,
        'approver_role': role,
        'level': index + 1,
      };
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              DepartmentSelectionField(
                label: "Departemen",
                isRequired: true,
                backgroundColor: Colors.white,
                borderColor: AppColors.hintColor,
                selectedDepartment: _selectedDepartment,
                onDepartmentSelected: (selected) {
                  setState(() {
                    _selectedDepartment = selected;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Departemen wajib dipilih';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DatePickerFieldWidget(
                label: "Tanggal",
                borderColor: AppColors.hintColor,
                controller: tanggalController,
                onDateChanged: (date) {
                  _selectedTanggal = date;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              KategoriKeperluanSelectionField(
                label: "Kategori Keperluan",
                isRequired: true,
                selectedKategori: _selectedKategori,
                onKategoriSelected: (selected) {
                  setState(() {
                    _selectedKategori = selected;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Kategori keperluan wajib dipilih';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFieldWidget(
                label: "Keterangan",
                controller: keteranganController,
                hintText: "Masukkan Deskripsi ...",
                maxLines: 3,
                backgroundColor: Colors.white,
                borderColor: AppColors.hintColor,
                width: double.infinity,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Keterangan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFieldWidget(
                label: "Nominal Pembayaran",
                controller: nominalController,
                hintText: "Rp...",
                backgroundColor: Colors.white,
                borderColor: AppColors.hintColor,
                width: double.infinity,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                  CurrencyInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal pembayaran wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownFieldWidget(
                label: "Metode Pembayaran",
                isRequired: true,
                value: _metodePembayaran,
                items: _listMetode.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                backgroundColor: Colors.white,
                borderColor: AppColors.hintColor,
                onChanged: (value) {
                  setState(() {
                    _metodePembayaran = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Metode pembayaran wajib dipilih';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_metodePembayaran == 'Transfer') ...[
                TextFieldWidget(
                  label: "Nomor Rekening",
                  controller: _noRekeningController,
                  hintText: "Masukkan Nomor Rekening",
                  borderColor: AppColors.hintColor,
                  backgroundColor: Colors.white,
                  width: double.infinity,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(30),
                  ],
                  validator: (value) {
                    if (_metodePembayaran == 'Transfer' &&
                        (value == null || value.isEmpty)) {
                      return 'Nomor Rekening wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  label: "Nama Pemilik Rekening",
                  controller: _namaPemilikRekeningController,
                  hintText: "Masukkan Nama Pemilik Rekening",
                  borderColor: AppColors.hintColor,
                  backgroundColor: Colors.white,
                  width: double.infinity,
                  validator: (value) {
                    if (_metodePembayaran == 'Transfer' &&
                        (value == null || value.isEmpty)) {
                      return 'Nama Pemilik Rekening wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  label: "Nama Bank",
                  controller: _jenisBankController,
                  hintText: "Masukkan Nama Bank",
                  borderColor: AppColors.hintColor,
                  backgroundColor: Colors.white,
                  width: double.infinity,
                  validator: (value) {
                    if (_metodePembayaran == 'Transfer' &&
                        (value == null || value.isEmpty)) {
                      return 'Nama Bank wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],
              const RecipientFinance(),
              const SizedBox(height: 20),
              FilePickerFieldWidget(
                label: "Bukti Pembayaran",
                isRequired: true,
                backgroundColor: Colors.white,
                borderColor: AppColors.hintColor,
                validator: (value) {
                  if (value == null) {
                    return 'Bukti pembayaran wajib diupload';
                  }
                  return null;
                },
                onFileChanged: (newFile) {
                  setState(() {
                    _buktiFile = newFile;
                  });
                },
              ),
              const SizedBox(height: 20),

              Consumer<PaymentProvider>(
                builder: (context, provider, _) {
                  final saving = provider.saving;
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: saving ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.secondTextColor,
                                ),
                              ),
                            )
                          : Text(
                              'Kirim Payment',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondTextColor,
                              ),
                            ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
