import 'package:e_hrm/providers/approvers/approvers_absensi_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ApproverSelectionSheet extends StatefulWidget {
  const ApproverSelectionSheet({super.key});

  @override
  State<ApproverSelectionSheet> createState() => _ApproverSelectionSheetState();
}

class _ApproverSelectionSheetState extends State<ApproverSelectionSheet> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearch);

    final provider = context.read<ApproversProvider>();
    if (!provider.isLoading && provider.users.isEmpty) {
      provider.refresh();
    }
  }

  void _handleSearch() {
    context.read<ApproversProvider>().setSearch(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height * 0.75;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Supervisi ...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<ApproversProvider>(
                  builder: (context, provider, _) {
                    final users = provider.users;
                    final loading = provider.isLoading;
                    final error = provider.error;

                    if (users.isEmpty && loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (users.isEmpty && error != null) {
                      return Center(
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    }

                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada data Supervisi.',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 80 &&
                            provider.canLoadMore &&
                            !provider.isLoading) {
                          provider.loadMore();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: users.length + (loading ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (index >= users.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          final user = users[index];
                          final isSelected = provider.selectedRecipientIds
                              .contains(user.idUser);

                          return ListTile(
                            onTap: () => provider.toggleSelect(user.idUser),
                            leading: CircleAvatar(
                              child: Text(
                                user.namaPengguna.isNotEmpty
                                    ? user.namaPengguna[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(
                              user.namaPengguna,
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            subtitle: user.email.isEmpty
                                ? null
                                : Text(
                                    user.email,
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (_) =>
                                  provider.toggleSelect(user.idUser),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Selesai',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
