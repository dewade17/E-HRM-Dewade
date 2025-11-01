import 'package:e_hrm/screens/users/pengajuan_cuti_izin/riwayat_pengajuan/riwayat_pengajuan_screen.dart';
import 'package:e_hrm/screens/users/pengajuan_cuti_izin/tambah_pengajuan/tambah_pengajuan_screen.dart';
import 'package:flutter/material.dart';

class PengajuanScreen extends StatefulWidget {
  const PengajuanScreen({super.key});

  @override
  State<PengajuanScreen> createState() => _PengajuanScreenState();
}

class _PengajuanScreenState extends State<PengajuanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: const Text(
          'PENGAJUAN CUTI/IZIN',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),

        bottom: TabBar(
          controller: _tabController, // Hubungkan controller
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Buat Pengajuan'),
            Tab(text: 'Riwayat Pengajuan'),
          ],
        ),
      ),
      // 6. Gunakan TabBarView sebagai body
      body: TabBarView(
        controller: _tabController, // Hubungkan controller yang sama
        children: const [
          // Konten untuk tab pertama: 'Buat Pengajuan'
          TambahPengajuanScreen(),

          // Konten untuk tab kedua: 'Riwayat Pengajuan'
          RiwayatPengajuanScreen(),
        ],
      ),
    );
  }
}
