import 'dart:convert';
import 'dart:collection';
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

  NotificationHandler().showLocalNotification(
    message,
    from: 'BackgroundHandler_$uniqueLogId',
    fromBackground: true,
  );
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

class NotificationHandler {
  NotificationHandler._internal();
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _cachedToken;
  bool _initialized = false;
  final LinkedHashSet<String> _seenMessageIds = LinkedHashSet<String>();

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {},
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _createAndroidNotificationChannel();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final String uniqueLogId = DateTime.now().millisecondsSinceEpoch
          .toString();
      showLocalNotification(
        message,
        from: 'ForegroundListener_$uniqueLogId',
        fromBackground: false,
      );
    });

    await _getTokenAndSendToServer();
    _firebaseMessaging.onTokenRefresh.listen(_sendTokenToServer);
  }

  bool _isDuplicate(RemoteMessage message) {
    final id = message.messageId;
    if (id == null) return false;
    if (_seenMessageIds.contains(id)) return true;
    _seenMessageIds.add(id);
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
    if (_isDuplicate(message)) return;

    final String title =
        message.data['title'] ?? message.notification?.title ?? 'No Title';
    final String body =
        message.data['body'] ?? message.notification?.body ?? 'No Body';

    if (title.isEmpty && body.isEmpty) return;

    final String dedupeKey = message.data['dedupeKey'] ?? '$title|$body';
    final int notificationId = dedupeKey.hashCode & 0x7fffffff;

    _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Channel untuk notifikasi penting.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          tag: 'e_hrm_general',
          groupKey: 'e_hrm_general',
        ),
        iOS: const DarwinNotificationDetails(
          threadIdentifier: 'e_hrm_general',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          threadIdentifier: 'e_hrm_general',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
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
    } catch (_) {
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
    } catch (_) {}
  }
}

final notificationHandler = NotificationHandler();
