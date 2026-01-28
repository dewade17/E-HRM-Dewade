import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/providers/approvers/approvers_finance_provider.dart';
import 'package:e_hrm/screens/users/finance/widget/approver_finance_selection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecipientFinance extends StatefulWidget {
  const RecipientFinance({super.key});

  @override
  State<RecipientFinance> createState() => _RecipientFinanceState();
}

class _RecipientFinanceState extends State<RecipientFinance> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ApproversFinanceProvider>();
      if (!provider.isLoading && provider.users.isEmpty) {
        provider.refresh();
      }
    });
  }

  Future<void> _openSelection() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ApproverFinanceSelection(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApproversFinanceProvider>(
      builder: (context, provider, _) {
        final selected = provider.selectedUsers;

        return Card(
          color: AppColors.textColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textDefaultColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Supervisi: ${selected.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDefaultColor,
                        ),
                      ),
                      InkWell(
                        onTap: _openSelection,
                        borderRadius: BorderRadius.circular(24),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.accentColor,
                          child: Icon(Icons.add, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selected.isEmpty
                      ? [
                          Text(
                            'Belum ada penerima dipilih.',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ]
                      : selected
                            .map(
                              (user) => Chip(
                                label: Text(
                                  user.namaPengguna,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                                backgroundColor: AppColors.accentColor,
                                deleteIconColor: Colors.black87,
                                onDeleted: () =>
                                    provider.toggleSelect(user.idUser),
                              ),
                            )
                            .toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
