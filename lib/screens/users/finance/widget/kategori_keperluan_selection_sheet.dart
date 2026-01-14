import 'dart:async';
import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/dto/kategori_keperluan/kategori_keperluan.dart';
import 'package:e_hrm/providers/keperluan_payment/kategori_keperluan_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

typedef KategoriSelectionCallback = void Function(Data? selectedKategori);

class KategoriKeperluanSelectionSheet extends StatefulWidget {
  final KategoriSelectionCallback onKategoriSelected;
  final String? initialSelectedId;

  const KategoriKeperluanSelectionSheet({
    super.key,
    required this.onKategoriSelected,
    this.initialSelectedId,
  });

  @override
  State<KategoriKeperluanSelectionSheet> createState() =>
      _KategoriKeperluanSelectionSheetState();
}

class _KategoriKeperluanSelectionSheetState
    extends State<KategoriKeperluanSelectionSheet> {
  late final TextEditingController _searchController;
  Data? _currentlySelected;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<KategoriKeperluanProvider>();
      if (!provider.loading && provider.items.isEmpty) {
        provider.refresh();
      }

      if (widget.initialSelectedId != null && provider.items.isNotEmpty) {
        try {
          _currentlySelected = provider.items.firstWhere(
            (item) => item.idKategoriKeperluan == widget.initialSelectedId,
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
        context.read<KategoriKeperluanProvider>().applySearch(
          _searchController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _selectKategori(Data kategori) {
    setState(() {
      _currentlySelected = kategori;
    });
    widget.onKategoriSelected(_currentlySelected);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SizedBox(
          height: media.size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Kategori Keperluan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<KategoriKeperluanProvider>(
                  builder: (context, provider, _) {
                    if (provider.items.isEmpty && provider.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.items.isEmpty) {
                      return const Center(child: Text("Data tidak ditemukan"));
                    }

                    return RefreshIndicator(
                      onRefresh: () => provider.refresh(),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount:
                              provider.items.length +
                              (provider.loading ? 1 : 0),
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            if (index >= provider.items.length) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final item = provider.items[index];
                            final isSelected =
                                _currentlySelected?.idKategoriKeperluan ==
                                item.idKategoriKeperluan;

                            return ListTile(
                              onTap: () => _selectKategori(item),
                              title: Text(
                                item.namaKeperluan,
                                style: GoogleFonts.poppins(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: Radio<String>(
                                value: item.idKategoriKeperluan,
                                groupValue:
                                    _currentlySelected?.idKategoriKeperluan,
                                onChanged: (_) => _selectKategori(item),
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
