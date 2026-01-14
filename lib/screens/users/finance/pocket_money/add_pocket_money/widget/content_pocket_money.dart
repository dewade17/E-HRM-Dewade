// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/departements/departements.dart';
import 'package:e_hrm/dto/kategori_keperluan/kategori_keperluan.dart'
    as dto_kategori;
import 'package:e_hrm/providers/approvers/approvers_pengajuan_provider.dart';
import 'package:e_hrm/providers/pocket_money/pocket_money_provider.dart';
import 'package:e_hrm/screens/users/finance/widget/recipient_finance.dart';
import 'package:e_hrm/shared_widget/confirmation_dialog.dart';
import 'package:e_hrm/shared_widget/date_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/department_selection_field.dart';
import 'package:e_hrm/shared_widget/dropdown_field_widget.dart';
import 'package:e_hrm/shared_widget/file_picker_field_widget.dart';
import 'package:e_hrm/shared_widget/kategori_keperluan_selection_field.dart';
import 'package:e_hrm/shared_widget/text_field_widget.dart';
import 'package:e_hrm/utils/currency_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _ExpenseItem {
  final TextEditingController detailController;
  final TextEditingController hargaController;
  _ExpenseItem({required this.detailController, required this.hargaController});
}

class ContentPocketMoney extends StatefulWidget {
  const ContentPocketMoney({super.key});

  @override
  State<ContentPocketMoney> createState() => _ContentPocketMoneyState();
}

class _ContentPocketMoneyState extends State<ContentPocketMoney> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController _noRekeningController = TextEditingController();
  final TextEditingController _jenisBankController = TextEditingController();
  final TextEditingController _namaPemilikRekeningController =
      TextEditingController();

  Departements? _selectedDepartment;
  File? _buktiFile;
  dto_kategori.Data? _selectedKategori;

  DateTime? _selectedTanggal;
  final DateFormat _tanggalParser = DateFormat('dd MMMM yyyy', 'id_ID');

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
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _expenseItems) {
      String val = item.hargaController.text
          .replaceAll("Rp", "")
          .replaceAll(".", "")
          .replaceAll(",", "")
          .trim();
      if (val.isNotEmpty) {
        total += double.tryParse(val) ?? 0;
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
      _showSnackBar('Minimal 1 item pengeluaran wajib diisi.', isError: true);
      return;
    }

    for (final item in _expenseItems) {
      if (item.detailController.text.trim().isEmpty ||
          item.hargaController.text.trim().isEmpty) {
        _showSnackBar(
          'Detail & harga item pengeluaran wajib diisi.',
          isError: true,
        );
        return;
      }
    }

    final metode = (_metodePembayaran ?? '').trim();
    if (metode.isEmpty) {
      _showSnackBar('Metode pembayaran wajib dipilih.', isError: true);
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
      _showSnackBar('Bukti pembayaran wajib diupload!', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "Simpan Pengajuan?",
        subtitle: "Pastikan data yang Anda masukkan sudah benar.",
        confirmText: "Ya, Simpan",
        onConfirm: () {
          Navigator.pop(context);
          FocusScope.of(context).unfocus();
          _submitPocketMoney();
        },
      ),
    );
  }

  Future<void> _submitPocketMoney() async {
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

    final DateTime? tanggal =
        _selectedTanggal ?? _tryParseTanggal(tanggalController.text);
    if (tanggal == null) {
      _showSnackBar('Tanggal tidak valid.', isError: true);
      return;
    }

    final String metode = (_metodePembayaran ?? '').trim();
    if (metode.isEmpty) {
      _showSnackBar('Metode pembayaran wajib dipilih.', isError: true);
      return;
    }

    http.MultipartFile? buktiFile;
    final file = _buktiFile;
    if (file != null) {
      try {
        buktiFile = await http.MultipartFile.fromPath(
          'bukti_pembayaran',
          file.path,
        );
      } catch (e) {
        _showSnackBar('Gagal menyiapkan file bukti pembayaran.', isError: true);
        return;
      }
    }

    final List<Map<String, dynamic>> itemsPayload = _buildItemsPayload();

    final approversProvider = context.read<ApproversPengajuanProvider>();
    final pocketMoneyProvider = context.read<PocketMoneyProvider>();

    final result = await pocketMoneyProvider.createPocketMoney(
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

    final String? errorMessage = pocketMoneyProvider.saveError;
    final String? successMessage = pocketMoneyProvider.saveMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      _showSnackBar(errorMessage, isError: true);
      return;
    }

    if (successMessage != null && successMessage.isNotEmpty) {
      _showSnackBar(successMessage, isError: false);
    } else if (result != null) {
      _showSnackBar('Berhasil mengirim pocket money.', isError: false);
    }

    final popPayload = result ?? true;

    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(popPayload);
    }
  }

  List<Map<String, dynamic>> _buildItemsPayload() {
    final out = <Map<String, dynamic>>[];
    for (final item in _expenseItems) {
      final nama = item.detailController.text.trim();
      final harga = item.hargaController.text.trim();
      out.add(<String, dynamic>{
        'nama_item_pocket_money': nama,
        'harga': harga,
      });
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            DepartmentSelectionField(
              label: "Departemen",
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
            const Divider(thickness: 1, color: Colors.black87),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Daftar Pengeluaran",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addExpenseItem,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(_expenseItems.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFieldWidget(
                          label: "",
                          hintText: "Detail...",
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
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: _expenseItems.length > 1
                            ? () => _removeExpenseItem(index)
                            : null,
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.black87),
            Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    "Total Pengeluaran",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFieldWidget(
                    label: "",
                    controller: totalController,
                    hintText: "Rp.....",
                    enabled: false,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 20),
            DropdownFieldWidget(
              label: "Metode Pembayaran",
              hintText: "Pilih metode pembayaran",
              value: _metodePembayaran,
              items: _listMetode.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              borderColor: AppColors.hintColor,
              backgroundColor: Colors.white,
              onChanged: (val) {
                setState(() {
                  _metodePembayaran = val;
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
                label: "Jenis Bank",
                controller: _jenisBankController,
                hintText: "Masukkan Jenis Bank",
                borderColor: AppColors.hintColor,
                backgroundColor: Colors.white,
                width: double.infinity,
                validator: (value) {
                  if (_metodePembayaran == 'Transfer' &&
                      (value == null || value.isEmpty)) {
                    return 'Jenis bank wajib diisi';
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
              file: _buktiFile,
              onFileChanged: (file) {
                setState(() {
                  _buktiFile = file;
                });
              },
              backgroundColor: Colors.white,
              borderColor: AppColors.hintColor,
              validator: (value) {
                if (value == null) return 'Bukti wajib diupload';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Consumer<PocketMoneyProvider>(
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
    );
  }
}
