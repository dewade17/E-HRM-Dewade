import 'dart:async';
import 'package:e_hrm/dto/kunjungan/kategori_kunjungan.dart'; // <-- DTO Kategori Kunjungan
import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart'; // <-- Provider Kategori Kunjungan
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Callback untuk memberitahu item yang dipilih
typedef KategoriKunjunganSelectionCallback =
    void Function(KategoriKunjunganItem? selectedKategori);

class KategoriKunjunganSelectionSheet extends StatefulWidget {
  final KategoriKunjunganSelectionCallback onKategoriSelected;
  final String? initialSelectedId; // Untuk menandai item yang sudah dipilih

  const KategoriKunjunganSelectionSheet({
    super.key,
    required this.onKategoriSelected,
    this.initialSelectedId,
  });

  @override
  State<KategoriKunjunganSelectionSheet> createState() =>
      _KategoriKunjunganSelectionSheetState();
}

class _KategoriKunjunganSelectionSheetState
    extends State<KategoriKunjunganSelectionSheet> {
  late final TextEditingController _searchController;
  KategoriKunjunganItem? _currentlySelected;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    final provider = context.read<KategoriKunjunganProvider>();
    // Pastikan data dimuat jika kosong
    provider.ensureLoaded();

    // Set item terpilih awal jika ada
    if (widget.initialSelectedId != null && provider.items.isNotEmpty) {
      _currentlySelected = provider.itemById(widget.initialSelectedId!);
    } else if (provider.selectedId != null) {
      // Ambil dari state provider jika initialId null tapi provider punya pilihan
      _currentlySelected = provider.selectedItem;
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        // Gunakan setSearch dari provider
        context.read<KategoriKunjunganProvider>().setSearch(
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
    super.dispose();
  }

  void _selectKategori(KategoriKunjunganItem kategori) {
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
                    hintText: 'Cari Jenis Kunjungan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Daftar Kategori Kunjungan
              Expanded(
                child: Consumer<KategoriKunjunganProvider>(
                  builder: (context, provider, _) {
                    final kategoris = provider.items;
                    final loading = provider.isLoading;
                    final error = provider.error;
                    final isLoadingMore = provider.isLoadingMore;
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
                              ? 'Jenis Kunjungan tidak ditemukan.'
                              : 'Tidak ada data Jenis Kunjungan.',
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
                      // <-- WIDGET REFRESH DITAMBAHKAN
                      onRefresh: () async {
                        // Panggil metode refresh dari provider
                        await context
                            .read<KategoriKunjunganProvider>()
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
                                    provider.canLoadMore &&
                                    !loading &&
                                    !isLoadingMore &&
                                    !hasSearchQuery) {
                                  provider.loadMore();
                                }
                                return false;
                              },
                              child: ListView.separated(
                                physics:
                                    const AlwaysScrollableScrollPhysics(), // <-- Agar selalu bisa di-scroll
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount:
                                    kategoris.length + (isLoadingMore ? 1 : 0),
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
                                      _currentlySelected?.idKategoriKunjungan ==
                                      kategori.idKategoriKunjungan;
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
                                          kategori.kategoriKunjungan.isNotEmpty
                                              ? kategori.kategoriKunjungan[0]
                                                    .toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color: avatarFgColor,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        kategori.kategoriKunjungan,
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
                                        value: kategori.idKategoriKunjungan,
                                        groupValue: _currentlySelected
                                            ?.idKategoriKunjungan,
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
