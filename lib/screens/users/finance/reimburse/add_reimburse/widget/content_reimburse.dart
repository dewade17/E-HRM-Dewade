// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/departements/departements.dart';
import 'package:e_hrm/dto/kategori_keperluan/kategori_keperluan.dart'
    as dto_kategori;
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/providers/pengajuan_reimburse/pengajuan_reimburse_provider.dart';
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

class _ExpenseItem {
  final TextEditingController detailController;
  final TextEditingController hargaController;
  _ExpenseItem({required this.detailController, required this.hargaController});
}

class ContentReimburse extends StatefulWidget {
  const ContentReimburse({super.key});

  @override
  State<ContentReimburse> createState() => _ContentReimburseState();
}

class _ContentReimburseState extends State<ContentReimburse> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController _noRekeningController = TextEditingController();
  final TextEditingController _jenisBankController = TextEditingController();
  final TextEditingController _namaPemilikRekeningController =
      TextEditingController();

  Departements? _selectedDepartment;
  dto_kategori.Data? _selectedKategori;

  DateTime? _selectedTanggal;
  final DateFormat _tanggalParser = DateFormat('dd MMMM yyyy', 'id_ID');

  File? _buktiFile;

  String? _metodePembayaran;
  final List<String> _listMetode = ["Cash", "Transfer"];

  final List<_ExpenseItem> _expenseItems = [];

  @override
  void initState() {
    super.initState();
    _addExpenseItem();
  }

  @override
  void dispose() {
    for (var item in _expenseItems) {
      item.detailController.dispose();
      item.hargaController.dispose();
    }
    tanggalController.dispose();
    keteranganController.dispose();
    totalController.dispose();
    _noRekeningController.dispose();
    _jenisBankController.dispose();
    _namaPemilikRekeningController.dispose();
    super.dispose();
  }

  void _addExpenseItem() {
    setState(() {
      _expenseItems.add(
        _ExpenseItem(
          detailController: TextEditingController(),
          hargaController: TextEditingController(),
        ),
      );
    });
  }

  void _removeExpenseItem(int index) {
    setState(() {
      _expenseItems[index].detailController.dispose();
      _expenseItems[index].hargaController.dispose();
      _expenseItems.removeAt(index);
    });
    _calculateTotal();
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _expenseItems) {
      String rawValue = item.hargaController.text.replaceAll('.', '');
      if (rawValue.isNotEmpty) {
        total += double.parse(rawValue);
      }
    }

    String formattedTotal = total.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    setState(() {
      totalController.text = "Rp $formattedTotal";
    });
  }

  void _handleSubmit() {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    if (_expenseItems.isEmpty) {
      _showSnackBar("Minimal harus ada 1 detail pengeluaran!", isError: true);
      return;
    }

    final approvers = context.read<ApproversPengajuanProvider>();
    if (approvers.selectedRecipientIds.isEmpty) {
      _showSnackBar(
        'Pilih minimal satu penerima laporan (supervisi).',
        isError: true,
      );
      return;
    }

    if (_buktiFile == null) {
      _showSnackBar("Bukti pembayaran wajib diupload!", isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "Simpan Pengajuan?",
        subtitle: "Pastikan data reimburse yang Anda masukkan sudah benar.",
        confirmText: "Ya, Simpan",
        onConfirm: () {
          Navigator.pop(context);
          FocusScope.of(context).unfocus();
          _submitReimburse();
        },
      ),
    );
  }

  Future<void> _submitReimburse() async {
    if (!mounted) return;

    final String deptId = _selectedDepartment?.idDepartement.trim() ?? '';
    if (deptId.isEmpty) {
      _showSnackBar('Departemen wajib dipilih.', isError: true);
      return;
    }

    final String kategoriId =
        _selectedKategori?.idKategoriKeperluan.trim() ?? '';
    if (kategoriId.isEmpty) {
      _showSnackBar('Kategori keperluan wajib dipilih.', isError: true);
      return;
    }

    final String metode = (_metodePembayaran ?? '').trim();
    if (metode.isEmpty) {
      _showSnackBar('Metode pembayaran wajib dipilih.', isError: true);
      return;
    }

    final DateTime? tanggal =
        _selectedTanggal ?? _tryParseTanggal(tanggalController.text);
    if (tanggal == null) {
      _showSnackBar('Tanggal tidak valid.', isError: true);
      return;
    }

    _calculateTotal();

    http.MultipartFile? buktiFile;
    if (_buktiFile != null) {
      try {
        buktiFile = await http.MultipartFile.fromPath(
          'bukti_pembayaran',
          _buktiFile!.path,
        );
      } catch (e) {
        _showSnackBar('Gagal membaca bukti pembayaran: $e', isError: true);
        return;
      }
    }

    final List<Map<String, dynamic>> itemsPayload = _buildItemsPayload();

    final approversProvider = context.read<ApproversPengajuanProvider>();
    final reimburseProvider = context.read<PengajuanReimburseProvider>();

    final result = await reimburseProvider.createReimburse(
      idDepartement: deptId,
      idKategoriKeperluan: kategoriId,
      tanggal: tanggal,
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
      items: itemsPayload,
      totalPengeluaran: totalController.text,
      approversProvider: approversProvider,
    );

    if (!mounted) return;

    final String? errorMessage = reimburseProvider.saveError;
    final String? successMessage = reimburseProvider.saveMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      _showSnackBar(errorMessage, isError: true);
      return;
    }

    if (successMessage != null && successMessage.isNotEmpty) {
      _showSnackBar(successMessage, isError: false);
    } else if (result != null) {
      _showSnackBar('Berhasil mengirim reimburse.', isError: false);
    }

    final popPayload = result ?? true;

    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(popPayload);
    } else {
      formKey.currentState?.reset();
      setState(() {
        _selectedDepartment = null;
        _selectedKategori = null;
        _selectedTanggal = null;
        _metodePembayaran = null;
        _buktiFile = null;
        tanggalController.clear();
        keteranganController.clear();
        totalController.clear();
        _noRekeningController.clear();
        _jenisBankController.clear();
        _namaPemilikRekeningController.clear();

        for (final item in _expenseItems) {
          item.detailController.dispose();
          item.hargaController.dispose();
        }
        _expenseItems.clear();
        _addExpenseItem();
      });
    }
  }

  List<Map<String, dynamic>> _buildItemsPayload() {
    final out = <Map<String, dynamic>>[];
    for (final item in _expenseItems) {
      final nama = item.detailController.text.trim();
      final harga = item.hargaController.text.trim();
      out.add(<String, dynamic>{'nama_item_reimburse': nama, 'harga': harga});
    }
    return out;
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
                hintText: "Pilih Departemen...",
                selectedDepartment: _selectedDepartment,
                backgroundColor: Colors.white,
                borderColor: AppColors.hintColor,
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
                isRequired: true,
                backgroundColor: Colors.white,
                borderColor: AppColors.hintColor,
                controller: tanggalController,
                onDateChanged: (date) {
                  _selectedTanggal = date;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              KategoriKeperluanSelectionField(
                label: "Kategori Keperluan",
                isRequired: true,
                hintText: "Pilih Kategori...",
                backgroundColor: Colors.white,
                borderColor: AppColors.hintColor,
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
                isRequired: true,
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
              DropdownFieldWidget(
                label: "Metode Pembayaran",
                isRequired: true,
                hintText: "Pilih Metode...",
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
                  if (value == null || value.isEmpty) {
                    return 'Metode pembayaran wajib dipilih';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Detail Pengeluaran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Harga",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _expenseItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFieldWidget(
                          label: "",
                          hintText: "...",
                          controller: _expenseItems[index].detailController,
                          borderColor: AppColors.hintColor,
                          backgroundColor: Colors.white,
                          width: double.infinity,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFieldWidget(
                          label: "",
                          hintText: "Rp...",
                          controller: _expenseItems[index].hargaController,
                          borderColor: AppColors.hintColor,
                          backgroundColor: Colors.white,
                          width: double.infinity,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                            CurrencyInputFormatter(),
                          ],
                          onChanged: (val) => _calculateTotal(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Wajib';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          onPressed: () => _removeExpenseItem(index),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addExpenseItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Tambah Detail Pengeluaran"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondTextColor,
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFieldWidget(
                label: "Total Pengeluaran",
                isRequired: true,
                controller: totalController,
                hintText: "Rp...",
                borderColor: AppColors.hintColor,
                backgroundColor: Colors.white,
                width: double.infinity,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Total wajib terisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_metodePembayaran == 'Transfer') ...[
                TextFieldWidget(
                  label: "No. Rekening",
                  controller: _noRekeningController,
                  hintText: "Contoh: 1234567890",
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
                      return 'No rekening wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  label: "Nama Pemilik Rekening",
                  controller: _namaPemilikRekeningController,
                  hintText: "Contoh: Budi Santoso",
                  borderColor: AppColors.hintColor,
                  backgroundColor: Colors.white,
                  width: double.infinity,
                  validator: (value) {
                    if (_metodePembayaran == 'Transfer' &&
                        (value == null || value.isEmpty)) {
                      return 'Nama pemilik rekening wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  label: "Jenis Bank",
                  controller: _jenisBankController,
                  hintText: "Contoh: BCA, Mandiri, dll",
                  borderColor: AppColors.hintColor,
                  backgroundColor: Colors.white,
                  width: double.infinity,
                  validator: (value) {
                    if (_metodePembayaran == 'Transfer' &&
                        (value == null || value.isEmpty)) {
                      return 'Jenis Bank wajib diisi';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 10),
              const RecipientFinance(),
              const SizedBox(height: 20),
              FilePickerFieldWidget(
                label: "Bukti Pembayaran",
                backgroundColor: Colors.white,
                borderColor: AppColors.hintColor,
                isRequired: true,
                onFileChanged: (newFile) {
                  setState(() {
                    _buktiFile = newFile;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Bukti wajib diupload';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Consumer<PengajuanReimburseProvider>(
                builder: (context, provider, _) {
                  final bool saving = provider.saving;
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
                              'Kirim Reimburse',
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
