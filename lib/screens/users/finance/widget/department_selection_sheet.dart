import 'dart:async';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/departements/departements.dart';
import 'package:e_hrm/providers/departements/departements_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

typedef DepartmentSelectionCallback =
    void Function(Departements? selectedDepartment);

class DepartmentSelectionSheet extends StatefulWidget {
  final DepartmentSelectionCallback onDepartmentSelected;
  final String? initialSelectedId;

  const DepartmentSelectionSheet({
    super.key,
    required this.onDepartmentSelected,
    this.initialSelectedId,
  });

  @override
  State<DepartmentSelectionSheet> createState() =>
      _DepartmentSelectionSheetState();
}

class _DepartmentSelectionSheetState extends State<DepartmentSelectionSheet> {
  late final TextEditingController _searchController;
  Departements? _currentlySelected;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    // Load data jika kosong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DepartementProvider>();
      if (!provider.loading && provider.items.isEmpty) {
        provider.refresh();
      }

      // Set initial selection jika ada
      if (widget.initialSelectedId != null && provider.items.isNotEmpty) {
        try {
          _currentlySelected = provider.items.firstWhere(
            (item) => item.idDepartement == widget.initialSelectedId,
          );
        } catch (_) {
          _currentlySelected = null;
        }
        if (mounted) setState(() {});
      }
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<DepartementProvider>().applySearch(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _selectDepartment(Departements department) {
    setState(() {
      _currentlySelected = department;
    });
    widget.onDepartmentSelected(_currentlySelected);
    Navigator.of(context).pop();
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
              // Search Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Departemen...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // List Data
              Expanded(
                child: Consumer<DepartementProvider>(
                  builder: (context, provider, _) {
                    final items = provider.items;
                    final loading = provider.loading;
                    final error = provider.error;
                    final hasSearchQuery = provider.search.isNotEmpty;

                    if (items.isEmpty && loading && !hasSearchQuery) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (loading && hasSearchQuery && items.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    if (items.isEmpty && error != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Error: ${provider.error}",
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: () => provider.refresh(),
                              child: const Text("Coba Lagi"),
                            ),
                          ],
                        ),
                      );
                    }
                    if (items.isEmpty && !loading) {
                      return const Center(
                        child: Text("Tidak ada data Departemen."),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => await provider.refresh(),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                                  notification.metrics.maxScrollExtent - 80 &&
                              !provider.loading) {
                            provider.loadMore();
                          }
                          return false;
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: items.length + (provider.loading ? 1 : 0),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            if (index >= items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }

                            final item = items[index];
                            final bool isSelected =
                                _currentlySelected?.idDepartement ==
                                item.idDepartement;

                            return ListTile(
                              onTap: () => _selectDepartment(item),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryColor
                                    .withOpacity(0.2),
                                child: Icon(
                                  Icons.apartment,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              title: Text(
                                item.namaDepartement,
                                style: GoogleFonts.poppins(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                              trailing: Radio<String>(
                                value: item.idDepartement,
                                groupValue: _currentlySelected?.idDepartement,
                                onChanged: (_) => _selectDepartment(item),
                                activeColor: AppColors.primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
