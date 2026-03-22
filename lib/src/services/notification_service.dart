import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test_app/src/features/app/data/models/notification_settings_model.dart';
import 'package:test_app/src/router/app_page.dart';
import 'package:test_app/src/router/app_router.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  /// Set by the app on startup. Used for context-free navigation.
  static AppRouterDelegate? router;

  static final StreamController<RemoteMessage> _inAppNotificationController =
      StreamController.broadcast();

  static Stream<RemoteMessage> get inAppNotifications =>
      _inAppNotificationController.stream;

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static NotificationResponse? _pendingNotificationLaunchResponse;
  static DateTime? _notificationLaunchHandledAt;

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
              handleNotificationNavigation(
                payload,
                tab: details.data['tab'] != null
                    ? int.tryParse(details.data['tab']!) ?? 0
                    : 0,
                friendsSection: details.data['friendsSection'] != null
                    ? int.tryParse(details.data['friendsSection']!) ?? 0
                    : 0,
                projectsSection: details.data['projectsSection'] != null
                    ? int.tryParse(details.data['projectsSection']!) ?? 0
                    : 0,
              );
            }
          },
        );

        final notificationAppLaunchDetails =
            await _flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();
        final didNotificationLaunchApp =
            notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
        final lastHandled = _notificationLaunchHandledAt;
        final isRecentHandling =
            lastHandled != null &&
            DateTime.now().difference(lastHandled).inSeconds < 2;
        if (didNotificationLaunchApp &&
            notificationAppLaunchDetails?.notificationResponse != null &&
            !isRecentHandling) {
          _pendingNotificationLaunchResponse =
              notificationAppLaunchDetails!.notificationResponse;
        }

        final androidPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        const AndroidNotificationChannel directChatsChannel =
            AndroidNotificationChannel(
              'direct_chats_channel',
              'Direct Chats',
              description: 'Notifications for direct chat messages',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            );
        const AndroidNotificationChannel groupChatsChannel =
            AndroidNotificationChannel(
              'group_chats_channel',
              'Group Chats',
              description: 'Notifications for group chat messages',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            );
        const AndroidNotificationChannel friendsChannel =
            AndroidNotificationChannel(
              'friends_channel',
              'Friends',
              description: 'Notifications for friend requests and updates',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            );
        const AndroidNotificationChannel projectsChannel =
            AndroidNotificationChannel(
              'projects_channel',
              'Projects',
              description: 'Notifications for project updates',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            );
        await androidPlugin?.createNotificationChannel(directChatsChannel);
        await androidPlugin?.createNotificationChannel(groupChatsChannel);
        await androidPlugin?.createNotificationChannel(friendsChannel);
        await androidPlugin?.createNotificationChannel(projectsChannel);
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

  static NotificationSettings? _settings;

  static void updateSettings(NotificationSettings settings) {
    _settings = settings;
  }

  static void handlePendingNotificationLaunch() {
    final response = _pendingNotificationLaunchResponse;
    if (response == null) return;
    _pendingNotificationLaunchResponse = null;
    _notificationLaunchHandledAt = DateTime.now();
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationNavigation(
          payload,
          tab: response.data['tab'] != null
              ? int.tryParse(response.data['tab']!) ?? 0
              : 0,
          friendsSection: response.data['friendsSection'] != null
              ? int.tryParse(response.data['friendsSection']!) ?? 0
              : 0,
          projectsSection: response.data['projectsSection'] != null
              ? int.tryParse(response.data['projectsSection']!) ?? 0
              : 0,
        );
      });
    }
  }

  static void handleNotificationNavigation(
    String route, {
    int tab = 0,
    int friendsSection = 0,
    int projectsSection = 0,
  }) {
    try {
      final page = AppPage.fromRoute(
        route,
        tab,
        friendsSection,
        projectsSection,
      );
      router?.navigateTo(page);
    } catch (e) {
      debugPrint('Failed to navigate from notification: $e');
    }
  }

  static Future<void> _onMessageHandler(RemoteMessage message) async {
    final settings = _settings;
    if (settings == null || !settings.pushNotificationsEnabled) return;

    final type = message.data['type'];
    if (type == 'message' && !settings.messageNotificationsEnabled) return;
    if (type == 'friend_request' &&
        !settings.friendRequestNotificationsEnabled) {
      return;
    }
    if (type == 'project_invite' &&
        !settings.projectInviteNotificationsEnabled) {
      return;
    }

    _inAppNotificationController.add(message);

    if (!kIsWeb && message.notification != null) {
      String channelId = 'direct_chats_channel';
      String channelName = 'Direct Chats';
      String channelDescription = 'Notifications for direct chat messages';
      if (type == 'group') {
        channelId = 'group_chats_channel';
        channelName = 'Group Chats';
        channelDescription = 'Notifications for group chat messages';
      } else if (type == 'friend_request') {
        channelId = 'friends_channel';
        channelName = 'Friends';
        channelDescription = 'Notifications for friend requests and updates';
      } else if (type == 'project_invite') {
        channelId = 'projects_channel';
        channelName = 'Projects';
        channelDescription = 'Notifications for project updates';
      }
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
      );
      final platformDetails = NotificationDetails(android: androidDetails);
      await _flutterLocalNotificationsPlugin.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        notificationDetails: platformDetails,
        payload: message.data['route'],
      );
    }
  }

  static void _onMessageOpenedAppHandler(RemoteMessage message) {
    final data = message.data;
    if (data['route'] != null) {
      handleNotificationNavigation(
        data['route'],
        tab: data['tab'] != null ? int.tryParse(data['tab']) ?? 0 : 0,
        friendsSection: data['friendsSection'] != null
            ? int.tryParse(data['friendsSection']) ?? 0
            : 0,
        projectsSection: data['projectsSection'] != null
            ? int.tryParse(data['projectsSection']) ?? 0
            : 0,
      );
    }
  }
}
