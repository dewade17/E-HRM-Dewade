// lib/screens/users/kunjungan_klien/detail_kunjungan/detail_kunjungan_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:e_hrm/dto/kunjungan/kunjungan_klien.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_klien_provider.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/content_detail_kunjungan.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/detail_kunjungan/widget/header_detail_kunjungan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailKunjunganScreen extends StatefulWidget {
  const DetailKunjunganScreen({
    super.key,
    required this.idKunjungan,
    this.initialData,
  });

  final String idKunjungan;
  final Data? initialData;

  @override
  State<DetailKunjunganScreen> createState() => _DetailKunjunganScreenState();
}

class _DetailKunjunganScreenState extends State<DetailKunjunganScreen> {
  bool _didFetchDetail = false;
  Data? _lastData;

  double? _startLat;
  double? _startLng;
  double? _endLat;
  double? _endLng;

  String? _startAddress;
  String? _endAddress;
  bool _startAddressLoading = false;
  bool _endAddressLoading = false;
  String? _startAddressError;
  String? _endAddressError;

  @override
  void initState() {
    super.initState();
    _applyData(widget.initialData);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didFetchDetail) return;
    _didFetchDetail = true;

    final provider = context.read<KunjunganKlienProvider>();
    final existingDetail = provider.detail;
    if (existingDetail?.idKunjungan == widget.idKunjungan) {
      _applyData(existingDetail);
    } else {
      scheduleMicrotask(() async {
        final detail = await provider.fetchDetail(widget.idKunjungan);
        if (!mounted) return;
        _applyData(detail);
      });
    }
  }

  @override
  void didUpdateWidget(covariant DetailKunjunganScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialData != widget.initialData &&
        widget.initialData != null) {
      _applyData(widget.initialData);
    }
    if (oldWidget.idKunjungan != widget.idKunjungan) {
      _didFetchDetail = false;
    }
  }

  void _applyData(Data? data) {
    if (data == null) return;
    if (!mounted) {
      _lastData = data;
    } else {
      setState(() {
        _lastData = data;
      });
    }
    _maybeLookupAddress(data.startLatitude, data.startLongitude, isStart: true);
    _maybeLookupAddress(data.endLatitude, data.endLongitude, isStart: false);
  }

  void _maybeLookupAddress(double? lat, double? lng, {required bool isStart}) {
    if (lat == null || lng == null) {
      setState(() {
        if (isStart) {
          _startLat = lat;
          _startLng = lng;
          _startAddress = null;
          _startAddressError = null;
          _startAddressLoading = false;
        } else {
          _endLat = lat;
          _endLng = lng;
          _endAddress = null;
          _endAddressError = null;
          _endAddressLoading = false;
        }
      });
      return;
    }

    if (isStart && lat == _startLat && lng == _startLng) {
      return;
    }
    if (!isStart && lat == _endLat && lng == _endLng) {
      return;
    }

    setState(() {
      if (isStart) {
        _startLat = lat;
        _startLng = lng;
        _startAddress = null;
        _startAddressError = null;
        _startAddressLoading = true;
      } else {
        _endLat = lat;
        _endLng = lng;
        _endAddress = null;
        _endAddressError = null;
        _endAddressLoading = true;
      }
    });

    _reverseGeocode(lat, lng)
        .then((value) {
          if (!mounted) return;
          setState(() {
            if (isStart) {
              _startAddress = value;
              _startAddressLoading = false;
            } else {
              _endAddress = value;
              _endAddressLoading = false;
            }
          });
        })
        .catchError((error) {
          if (!mounted) return;
          setState(() {
            if (isStart) {
              _startAddressError = error.toString();
              _startAddressLoading = false;
            } else {
              _endAddressError = error.toString();
              _endAddressLoading = false;
            }
          });
        });
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      <String, String>{
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
      },
    );
    final response = await http.get(
      uri,
      headers: <String, String>{
        'User-Agent': 'E-HRM-App/1.0 (+https://example.com)',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat alamat (${response.statusCode})');
    }
    final body = jsonDecode(response.body);
    if (body is Map && body['display_name'] != null) {
      return body['display_name'].toString();
    }
    throw Exception('Alamat tidak ditemukan');
  }

  String _resolveAddress({
    required bool isStart,
    required double? lat,
    required double? lng,
  }) {
    final loading = isStart ? _startAddressLoading : _endAddressLoading;
    final error = isStart ? _startAddressError : _endAddressError;
    final address = isStart ? _startAddress : _endAddress;
    if (loading) {
      return 'Memuat alamat...';
    }
    if (error != null) {
      return error;
    }
    if (address != null && address.isNotEmpty) {
      return address;
    }
    if (lat == null || lng == null) {
      return 'Lokasi tidak tersedia';
    }
    return 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
  }

  // ✨ PERUBAHAN DISINI: Menghapus .toLocal()
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    // Menghapus .toLocal()
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  // ✨ PERUBAHAN DISINI: Menghapus .toLocal()
  String _formatTime(DateTime? date) {
    if (date == null) return '--:--';
    // Menghapus .toLocal()
    return DateFormat('HH.mm', 'id_ID').format(date);
  }

  String _resolveKategori(Data data) {
    return data.kategori?.kategoriKunjungan ??
        data.deskripsi ??
        'Kategori tidak tersedia';
  }

  String _resolveDuration(Data data) {
    final durationInSeconds = data.duration;
    if (durationInSeconds == null || durationInSeconds < 0) {
      return 'Durasi tidak tersedia';
    }
    if (durationInSeconds == 0) {
      return '0 detik'; // Menampilkan 0 detik jika durasi nol
    }

    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;

    final parts = <String>[];
    if (hours > 0) {
      parts.add('$hours jam');
    }
    if (minutes > 0) {
      parts.add('$minutes menit');
    }

    // ✨ PERBAIKAN: Jika durasi kurang dari 1 menit, tampilkan dalam detik.
    if (hours == 0 && minutes == 0) {
      parts.add('$durationInSeconds detik');
    }

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final iconMax = (math.min(size.width, size.height) * 0.4).clamp(
      320.0,
      360.0,
    );

    return Consumer<KunjunganKlienProvider>(
      builder: (context, provider, _) {
        final detail = provider.detail;
        if (detail != null && detail.idKunjungan == widget.idKunjungan) {
          if (_lastData?.idKunjungan != detail.idKunjungan ||
              _lastData != detail) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _applyData(detail);
            });
          }
        }

        final data =
            (detail != null && detail.idKunjungan == widget.idKunjungan)
            ? detail
            : _lastData;

        final startDate = data?.jamCheckin;
        final endDate = data?.jamCheckout;

        final startAddress = _resolveAddress(
          isStart: true,
          lat: data?.startLatitude,
          lng: data?.startLongitude,
        );
        final endAddress = _resolveAddress(
          isStart: false,
          lat: data?.endLatitude,
          lng: data?.endLongitude,
        );

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Center(
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.asset(
                        'lib/assets/image/icon_bg.png',
                        width: iconMax,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Image.asset(
                    'lib/assets/image/Pattern.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              Positioned.fill(
                child: SafeArea(
                  left: false,
                  right: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 50),
                            if (provider.isDetailLoading && data == null)
                              const Center(child: CircularProgressIndicator())
                            else if (provider.detailError != null &&
                                data == null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Text(
                                  provider.detailError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            else if (data != null)
                              ContentDetailKunjungan(
                                kategori: _resolveKategori(data),
                                durationText: _resolveDuration(data),
                                deskripsi:
                                    data.deskripsi ?? 'Tidak ada keterangan.',
                                startDateText: _formatDate(startDate),
                                startTimeText: _formatTime(startDate),
                                startAddress: startAddress,
                                endDateText: _formatDate(endDate),
                                endTimeText: _formatTime(endDate),
                                endAddress: endAddress,
                                lampiranUrl: data.lampiranKunjunganUrl,
                                reports: data.reports,
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 40,
                left: 10,
                child: HeaderDetailKunjungan(),
              ),
            ],
          ),
        );
      },
    );
  }
}
