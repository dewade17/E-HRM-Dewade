// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Pastikan package ini ada
import 'package:intl/intl.dart';
import 'package:e_hrm/providers/sop_perusahaan/sop_perusahaan_provider.dart';
import 'package:e_hrm/dto/sop_perusahaan/sop_perushaan.dart' as sop_dto;

class ContentSop extends StatefulWidget {
  const ContentSop({super.key});

  @override
  State<ContentSop> createState() => _ContentSopState();
}

class _ContentSopState extends State<ContentSop>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isFocused = false;

  final Set<String> _selectedCategories = {};
  Set<String> _tempSelectedCategories = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));

    // Fetch data saat pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SopPerusahaanProvider>();
      provider.fetchAllSop();
      provider.fetchPinnedSop();
    });

    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk membuka browser
  Future<void> _openSopUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan SOP')),
        );
      }
    }
  }

  List<sop_dto.Item> _filterList(
    List<sop_dto.Item> items,
    SopPerusahaanProvider provider,
  ) {
    final query = _searchController.text.toLowerCase();

    return items.where((sop) {
      final matchSearch = sop.namaDokumen.toLowerCase().contains(query);
      final isFavorite = provider.isPinned(sop.idSopKaryawan);
      final matchTab = _tabController.index == 0 || isFavorite;
      final matchCategory =
          _selectedCategories.isEmpty ||
          _selectedCategories.contains(sop.kategoriSop.namaKategori);

      return matchSearch && matchTab && matchCategory;
    }).toList();
  }

  void _showFilterDialog(List<String> categories) {
    _tempSelectedCategories = Set.from(_selectedCategories);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pilih Kategori SOP'),
              content: SizedBox(
                width: double.maxFinite,
                child: categories.isEmpty
                    ? const Text("Tidak ada kategori tersedia")
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final selected = _tempSelectedCategories.contains(
                            category,
                          );
                          return CheckboxListTile(
                            title: Text(category),
                            value: selected,
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  _tempSelectedCategories.add(category);
                                } else {
                                  _tempSelectedCategories.remove(category);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() => _tempSelectedCategories.clear());
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategories.clear();
                      _selectedCategories.addAll(_tempSelectedCategories);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SopPerusahaanProvider>(
      builder: (context, provider, child) {
        // Ambil kategori unik dari data yang ada untuk filter
        final availableCategories = provider.sopItems
            .map((e) => e.kategoriSop.namaKategori)
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();

        final visibleList = _filterList(provider.sopItems, provider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔍 SEARCH + FILTER
            Row(
              children: [
                Expanded(
                  child: Focus(
                    onFocusChange: (f) => setState(() => _isFocused = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _isFocused
                              ? Colors.blue
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari SOP',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showFilterDialog(availableCategories),
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 131, 189, 236),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_list, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Files'),
                Tab(text: 'Favorite'),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: provider.loadingSop && provider.sopItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : visibleList.isEmpty
                  ? const Center(child: Text("SOP tidak ditemukan"))
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchAllSop(),
                      child: ListView.separated(
                        itemCount: visibleList.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final sop = visibleList[index];
                          final isFav = provider.isPinned(sop.idSopKaryawan);

                          // Format tanggal dari API
                          String formattedDate = "N/A";
                          try {
                            formattedDate = DateFormat(
                              'dd MMM yyyy',
                            ).format(sop.createdAt);
                          } catch (_) {}

                          return _SopItem(
                            title: sop.namaDokumen,
                            category: sop.kategoriSop.namaKategori,
                            date: formattedDate,
                            isFavorite: isFav,
                            onFavorite: () {
                              if (isFav) {
                                provider.unpinSop(sop.idSopKaryawan);
                              } else {
                                provider.pinSop(sop.idSopKaryawan);
                              }
                            },
                            onTap: () => _openSopUrl(sop.lampiranSopUrl),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SopItem extends StatelessWidget {
  final String title;
  final String date;
  final String category;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _SopItem({
    required this.title,
    required this.date,
    required this.category,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Aksi ketika item diklik
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.25)),
              ),
              child: Center(
                child: Image.asset(
                  'lib/assets/image/icon_apk.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    category,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: onFavorite,
            ),
          ],
        ),
      ),
    );
  }
}
