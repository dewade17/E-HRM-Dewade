// lib/screens/users/pengajuan_cuti_izin/tambah_pengajuan/pengajuan_izin_sakit/widget/kategori_sakit_selection_sheet.dart

import 'dart:async';
import 'package:e_hrm/dto/pengajuan_sakit/kategori_pengajuan_sakit.dart' as dto;
import 'package:e_hrm/providers/pengajuan_izin_sakit/kategori_pengajuan_sakit_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Callback untuk memberitahu item yang dipilih
typedef KategoriSakitSelectionCallback =
    void Function(dto.Data? selectedKategori);

class KategoriSakitSelectionSheet extends StatefulWidget {
  final KategoriSakitSelectionCallback onKategoriSelected;
  final String? initialSelectedId; // Untuk menandai item yang sudah dipilih

  const KategoriSakitSelectionSheet({
    super.key,
    required this.onKategoriSelected,
    this.initialSelectedId,
  });

  @override
  State<KategoriSakitSelectionSheet> createState() =>
      _KategoriSakitSelectionSheetState();
}

class _KategoriSakitSelectionSheetState
    extends State<KategoriSakitSelectionSheet> {
  late final TextEditingController _searchController;
  dto.Data? _currentlySelected;
  Timer? _debounce;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<KategoriPengajuanSakitProvider>();

      if (provider.items.isEmpty && !provider.loading) {
        provider.fetch(append: false);
      }

      if (widget.initialSelectedId == null) {
        return;
      }

      void updateSelection() {
        if (!mounted) return;

        dto.Data? selected;
        try {
          selected = provider.items.firstWhere(
            (item) => item.idKategoriSakit == widget.initialSelectedId,
          );
        } catch (_) {
          selected = null;
        }

        if (_currentlySelected?.idKategoriSakit != selected?.idKategoriSakit) {
          setState(() {
            _currentlySelected = selected;
          });
        }
      }

      if (provider.items.isNotEmpty) {
        updateSelection();
      } else {
        _providerListener = () {
          if (!mounted) return;
          if (provider.items.isEmpty) return;
          if (_providerListener != null) {
            provider.removeListener(_providerListener!);
            _providerListener = null;
          }
          updateSelection();
        };
        provider.addListener(_providerListener!);
      }
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        // Gunakan applySearch dari provider
        context.read<KategoriPengajuanSakitProvider>().applySearch(
          _searchController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    if (_providerListener != null) {
      context.read<KategoriPengajuanSakitProvider>().removeListener(
        _providerListener!,
      );
      _providerListener = null;
    }
    super.dispose();
  }

  void _selectKategori(dto.Data kategori) {
    setState(() {
      _currentlySelected = kategori;
    });
    // Panggil callback
    widget.onKategoriSelected(_currentlySelected);
    Navigator.of(context).pop(); // Tutup sheet
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height * 0.75; // Sesuaikan tinggi jika perlu

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Handle sheet
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
              // Input Pencarian
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Kategori Sakit...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Daftar Kategori
              Expanded(
                child: Consumer<KategoriPengajuanSakitProvider>(
                  builder: (context, provider, _) {
                    final kategoris = provider.items;
                    final loading = provider.loading;
                    final error = provider.error;
                    final hasSearchQuery = provider.search.isNotEmpty;

                    // Logika Tampilan Loading/Error/Kosong
                    if (kategoris.isEmpty && loading && !hasSearchQuery) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (loading && hasSearchQuery && kategoris.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    if (kategoris.isEmpty && error != null && !loading) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => provider.refresh(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (kategoris.isEmpty && !loading) {
                      return Center(
                        child: Text(
                          hasSearchQuery
                              ? 'Kategori Sakit tidak ditemukan.'
                              : 'Tidak ada data Kategori Sakit.',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    // Tampilkan list view
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context
                            .read<KategoriPengajuanSakitProvider>()
                            .refresh();
                      },
                      child: Column(
                        children: [
                          if (loading && hasSearchQuery && kategoris.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          Expanded(
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification.metrics.pixels >=
                                        notification.metrics.maxScrollExtent -
                                            80 &&
                                    !loading &&
                                    !hasSearchQuery &&
                                    provider.page < provider.totalPages) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      provider.loadMore();
                                    }
                                  });
                                }
                                return false;
                              },
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount:
                                    kategoris.length +
                                    (loading &&
                                            kategoris.isNotEmpty &&
                                            !hasSearchQuery
                                        ? 1
                                        : 0),
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  if (index >= kategoris.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }

                                  final kategori = kategoris[index];
                                  final bool isThisSelected =
                                      _currentlySelected?.idKategoriSakit ==
                                      kategori.idKategoriSakit;
                                  final bool dimmed =
                                      _currentlySelected != null &&
                                      !isThisSelected;
                                  final Color titleColor = dimmed
                                      ? Colors.grey.shade500
                                      : Colors.black87;
                                  final Color avatarBgColor = dimmed
                                      ? Colors.grey.shade300
                                      : Theme.of(context).primaryColorLight;
                                  final Color avatarFgColor = dimmed
                                      ? Colors.grey.shade500
                                      : Theme.of(context).primaryColorDark;

                                  return Opacity(
                                    opacity: dimmed ? 0.6 : 1.0,
                                    child: ListTile(
                                      onTap: () => _selectKategori(kategori),
                                      leading: CircleAvatar(
                                        backgroundColor: avatarBgColor,
                                        child: Text(
                                          kategori.namaKategori.isNotEmpty
                                              ? kategori.namaKategori[0]
                                                    .toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color: avatarFgColor,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        kategori.namaKategori,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isThisSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: titleColor,
                                          ),
                                        ),
                                      ),

                                      trailing: Radio<String>(
                                        value: kategori.idKategoriSakit,
                                        groupValue:
                                            _currentlySelected?.idKategoriSakit,
                                        onChanged: (_) =>
                                            _selectKategori(kategori),
                                        activeColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Tombol Tutup
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
                    'Tutup',
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
