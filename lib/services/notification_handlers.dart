// lib/services/notification_handler.dart

import 'dart:convert';
import 'package:e_hrm/contraints/endpoints.dart'; // <-- TAMBAHKAN IMPORT INI
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:e_hrm/firebase_options.dart'; // File hasil flutterfire configure
import 'package:e_hrm/services/api_services.dart'; // Sesuaikan dengan path ApiService Anda

// Handler untuk notifikasi saat aplikasi di-terminate/background
// Harus berada di top-level (di luar class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();

  // Plugin untuk menampilkan notifikasi di foreground (saat aplikasi dibuka)
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // --- PERUBAHAN 1: Tambahkan variabel cache untuk token ---
  String? _cachedToken;

  Future<void> init() async {
    // 1. Minta izin notifikasi dari pengguna (untuk iOS & Web)
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // 2. Set up handler untuk pesan background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Inisialisasi FlutterLocalNotificationsPlugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(initializationSettings);

    // 4. Dengarkan notifikasi saat aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // ID channel
              'High Importance Notifications', // Nama channel
              channelDescription: 'Channel untuk notifikasi penting.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 5. Ambil dan kirim token FCM ke server (saat init)
    await _getTokenAndSendToServer();

    // 6. Dengarkan perubahan token (jika token di-refresh)
    _firebaseMessaging.onTokenRefresh.listen(_sendTokenToServer);
  }

  // --- PERUBAHAN 2: Buat fungsi publik untuk mengambil token ---
  /// Fungsi publik untuk mendapatkan token FCM secara paksa.
  /// Akan mengambil dari cache jika ada, atau meminta yang baru jika belum ada.
  Future<String?> getFcmToken() async {
    if (_cachedToken != null) {
      print("Mengembalikan FCM token dari cache.");
      return _cachedToken;
    }
    try {
      print("Meminta FCM token baru dari Firebase...");
      _cachedToken = await _firebaseMessaging.getToken();
      print("Token baru didapat: ${_cachedToken != null}");
      return _cachedToken;
    } catch (e) {
      print("Gagal mendapatkan FCM token secara paksa: $e");
      return null;
    }
  }

  Future<void> _getTokenAndSendToServer() async {
    try {
      // Modifikasi di sini untuk menggunakan fungsi yang baru dibuat
      final token = await getFcmToken();
      if (token != null) {
        print("FCM Token (saat init): $token");
        await _sendTokenToServer(token);
      }
    } catch (e) {
      print("Error getting FCM token saat init: $e");
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      // --- PERBAIKAN UTAMA DI SINI ---
      // Menggunakan endpoint absolut dari file endpoints.dart
      await _apiService.postDataPrivate(Endpoints.getNotifications, {
        'token': token,
      });
      print("FCM token berhasil dikirim ke server.");
    } catch (e) {
      print("Gagal mengirim FCM token ke server: $e");
    }
  }
}
