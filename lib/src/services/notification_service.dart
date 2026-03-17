import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  static final StreamController<RemoteMessage> _inAppNotificationController =
      StreamController.broadcast();

  static Stream<RemoteMessage> get inAppNotifications =>
      _inAppNotificationController.stream;

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      if (!kIsWeb) {
        await FirebaseMessaging.instance.requestPermission();

        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        final InitializationSettings initializationSettings =
            InitializationSettings(android: initializationSettingsAndroid);
        await _flutterLocalNotificationsPlugin.initialize(
          settings: initializationSettings,
          onDidReceiveNotificationResponse: (details) {
            final payload = details.payload;
            if (payload != null && payload.isNotEmpty) {
              final context = rootNavigatorKey.currentContext;
              if (context != null) {
                GoRouter.of(context).go(payload);
              }
            }
          },
        );

        final notificationAppLaunchDetails =
            await _flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();
        final didNotificationLaunchApp =
            notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
        final launchPayload =
            notificationAppLaunchDetails?.notificationResponse?.payload;
        if (didNotificationLaunchApp &&
            launchPayload != null &&
            launchPayload.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = rootNavigatorKey.currentContext;
            if (context != null) {
              GoRouter.of(context).go(launchPayload);
            }
          });
        }

        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'default_channel',
          'Default',
          description: 'Default channel for foreground notifications',
          importance: Importance.max,
        );
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);
      }

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      FirebaseMessaging.onMessage.listen(_onMessageHandler);

      RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {}

      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedAppHandler);
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
    }
  }

  static Future<void> _onMessageHandler(RemoteMessage message) async {
    _inAppNotificationController.add(message);

    if (!kIsWeb && message.notification != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'default_channel',
            'Default',
            channelDescription: 'Default channel for foreground notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await _flutterLocalNotificationsPlugin.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        notificationDetails: platformChannelSpecifics,
        payload: message.data['route'],
      );
    }
  }

  static void _onMessageOpenedAppHandler(RemoteMessage message) {
    final data = message.data;
    if (data['route'] != null) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).go(data['route']);
      }
    }
  }
}
