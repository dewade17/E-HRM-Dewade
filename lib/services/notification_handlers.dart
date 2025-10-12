// lib/services/notification_handlers.dart

import 'dart:convert';
import 'dart:collection';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/firebase_options.dart';
import 'package:e_hrm/services/api_services.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final String uniqueLogId = DateTime.now().millisecondsSinceEpoch.toString();
  print(
    '[$uniqueLogId] BACKGROUND HANDLER TERPANGGIL messageId=${message.messageId}',
  );

  // Penting: jika payload bertipe "notification", biarkan sistem yang tampilkan (Android).
  NotificationHandler().showLocalNotification(
    message,
    from: 'BackgroundHandler_$uniqueLogId',
    fromBackground: true,
  );
}

class NotificationHandler {
  NotificationHandler._internal();
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _cachedToken;

  // --- Guard agar init hanya sekali ---
  bool _initialized = false;

  // --- De-dupe cache untuk messageId ---
  final LinkedHashSet<String> _seenMessageIds = LinkedHashSet<String>();

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Permission
    await _firebaseMessaging.requestPermission();

    // iOS (jaga-jaga): tampilkan notifikasi saat foreground
    // Abaikan jika tidak pakai iOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Inisialisasi plugin notifikasi lokal
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(initializationSettings);

    await _createAndroidNotificationChannel();

    // Listener foreground — hanya didaftarkan sekali
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final String uniqueLogId = DateTime.now().millisecondsSinceEpoch
          .toString();
      print(
        '[$uniqueLogId] FOREGROUND LISTENER TERPANGGIL messageId=${message.messageId}',
      );
      showLocalNotification(
        message,
        from: 'ForegroundListener_$uniqueLogId',
        fromBackground: false,
      );
    });

    await _getTokenAndSendToServer();
    _firebaseMessaging.onTokenRefresh.listen(_sendTokenToServer);
  }

  // --- LOGIC: kapan kita BOLEH menampilkan notifikasi lokal? ---
  bool _shouldShowLocal(RemoteMessage message, {required bool fromBackground}) {
    final hasNotificationPayload =
        message.notification != null &&
        ((message.notification!.title?.isNotEmpty ?? false) ||
            (message.notification!.body?.isNotEmpty ?? false));

    // Jika dari background DAN ada payload notification:
    // Android sudah menampilkan notifikasi sistem secara otomatis.
    if (fromBackground && hasNotificationPayload) {
      print(
        'SKIP LOCAL: background + notification payload (biar sistem yang tampilkan).',
      );
      return false;
    }

    // Selain itu, aman tampilkan lokal (foreground atau data-only di background).
    return true;
  }

  // --- De-dupe berdasarkan messageId ---
  bool _isDuplicate(RemoteMessage message) {
    final id = message.messageId;
    if (id == null) return false;
    if (_seenMessageIds.contains(id)) return true;
    _seenMessageIds.add(id);
    // batasi ukuran set agar tidak membengkak
    if (_seenMessageIds.length > 64) {
      _seenMessageIds.remove(_seenMessageIds.first);
    }
    return false;
  }

  void showLocalNotification(
    RemoteMessage message, {
    String from = 'Unknown',
    required bool fromBackground,
  }) {
    print(
      'SHOW_LOCAL_NOTIFICATION dipanggil dari: [$from] messageId=${message.messageId}',
    );

    // (opsional) kalau kamu tetap pakai guard background vs notification payload
    // if (!_shouldShowLocal(message, fromBackground: fromBackground)) return;

    final String title =
        message.data['title'] ?? message.notification?.title ?? 'No Title';
    final String body =
        message.data['body'] ?? message.notification?.body ?? 'No Body';

    if (title.isEmpty && body.isEmpty) {
      print('GAGAL MENAMPILKAN NOTIFIKASI: Title/Body kosong.');
      return;
    }

    // --- KUNCI: ID deterministik untuk collapse duplikat ---
    final String dedupeKey = message.data['dedupeKey'] ?? '$title|$body';
    // pastikan positif
    final int notificationId = dedupeKey.hashCode & 0x7fffffff;

    print(
      'MENAMPILKAN/UPDATE NOTIF LOKAL id=$notificationId tag=$dedupeKey (from=$from)',
    );

    _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Channel untuk notifikasi penting.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // (opsional) tambah tag supaya Android juga treat sebagai satu thread
          tag: dedupeKey,
          groupKey: 'e_hrm_general', // opsional: pengelompokan
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Channel untuk notifikasi penting.',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<String?> getFcmToken() async {
    if (_cachedToken != null) return _cachedToken;
    try {
      _cachedToken = await _firebaseMessaging.getToken();
      return _cachedToken;
    } catch (e) {
      print('Gagal mendapatkan FCM token: $e');
      return null;
    }
  }

  Future<void> _getTokenAndSendToServer() async {
    final String? token = await getFcmToken();
    if (token != null) {
      await _sendTokenToServer(token);
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      await _apiService.postDataPrivate(Endpoints.getNotifications, {
        'token': token,
      });
      print('FCM token berhasil dikirim ke server.');
    } catch (e) {
      print('Gagal mengirim FCM token ke server: $e');
    }
  }
}
