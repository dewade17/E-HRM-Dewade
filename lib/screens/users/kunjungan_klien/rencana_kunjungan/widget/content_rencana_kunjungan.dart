import 'package:e_hrm/screens/users/kunjungan_klien/widget_kunjungan/calendar_kunjungan.dart';
import 'package:flutter/material.dart';

class ContentRencanaKunjungan extends StatefulWidget {
  const ContentRencanaKunjungan({super.key});

  @override
  State<ContentRencanaKunjungan> createState() =>
      _ContentRencanaKunjunganState();
}

class _ContentRencanaKunjunganState extends State<ContentRencanaKunjungan> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [CalendarKunjungan()]));
  }
}
