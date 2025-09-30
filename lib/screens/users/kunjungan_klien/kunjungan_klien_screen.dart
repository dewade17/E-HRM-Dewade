import 'package:e_hrm/screens/users/kunjungan_klien/daftar_kunjungan/daftar_kunjungan_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/rencana_kunjungan/rencana_kunjungan_screen.dart';
import 'package:flutter/material.dart';

class KunjunganKlienScreen extends StatefulWidget {
  const KunjunganKlienScreen({super.key});

  @override
  State<KunjunganKlienScreen> createState() => _KunjunganKlienScreenState();
}

// 1. Tambahkan 'with SingleTickerProviderStateMixin'
class _KunjunganKlienScreenState extends State<KunjunganKlienScreen>
    with SingleTickerProviderStateMixin {
  // 2. Deklarasikan TabController
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3. Inisialisasi controller dengan 2 tab
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // 4. Buang controller untuk mencegah memory leak
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // Tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Judul AppBar
        title: const Text(
          'KUNJUNGAN',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),

        // 5. Tempatkan TabBar di bagian bawah AppBar
        bottom: TabBar(
          controller: _tabController, // Hubungkan controller
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicatorColor: Colors.blue, // Warna garis indikator
          labelColor: Colors.blue, // Warna teks tab yang aktif
          unselectedLabelColor: Colors.grey, // Warna teks tab yang tidak aktif
          tabs: const [
            Tab(text: 'Daftar Kunjungan'),
            Tab(text: 'Rencana Kunjungan'),
          ],
        ),
      ),
      // 6. Gunakan TabBarView sebagai body
      body: TabBarView(
        controller: _tabController, // Hubungkan controller yang sama
        children: const [
          // Konten untuk tab pertama: 'Daftar Kunjungan'
          DaftarKunjunganScreen(),

          // Konten untuk tab kedua: 'Rencana Kunjungan'
          RencanaKunjunganScreen(),
        ],
      ),
    );
  }
}
