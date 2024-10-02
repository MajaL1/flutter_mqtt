import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//import 'package:flutter_native_timezone/flutter_native_timezone.dart';
//import 'package:flutter_push_notifications/utils/download_util.dart';
import 'package:rxdart/subjects.dart';

class NotificationService {
  NotificationService();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_bg_service_small');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            notificationCategories: [
              DarwinNotificationCategory(
                'demoCategory',
                actions: <DarwinNotificationAction>[
                  DarwinNotificationAction.plain('id_1', 'Action 1'),
                  DarwinNotificationAction.plain(
                    'id_2',
                    'Action 2',
                    options: <DarwinNotificationActionOption>{
                      DarwinNotificationActionOption.destructive,
                    },
                  ),
                  DarwinNotificationAction.plain(
                    'id_3',
                    'Action 3',
                    options: <DarwinNotificationActionOption>{
                      DarwinNotificationActionOption.foreground,
                    },
                  ),
                ],
                options: <DarwinNotificationCategoryOption>{
                  DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
                },
              )
            ],
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      //onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
    );
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    debugPrint('id $id');
  }

  void selectNotification(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      behaviorSubject.add(payload);
    }
  }
}
