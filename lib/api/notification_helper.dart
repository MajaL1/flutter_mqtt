import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/standalone.dart' as tz;
import '../main.dart';
import '../model/notification_message.dart';
import '../model/user_data_settings.dart';

class NotificationHelper extends StatelessWidget {
  const NotificationHelper({Key? key}) : super(key: key);
  static FlutterBackgroundService service = FlutterBackgroundService();

  @override
  Widget build(BuildContext context) {
    return Container();


   // List <NotifMessage> notifMessageList = new List<>();
  }

  static Future<void> initializeService() async {
    service = FlutterBackgroundService();
    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );


    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: false,

        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'TEST NOTIFICATIONS',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
    tzl.initializeTimeZones();
  }

 static void startMesagingService() {
    debugPrint("Messaging service started");
    service.startService();
  }


// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final log = preferences.getStringList('log') ?? <String>[];
    log.add(DateTime.now().toIso8601String());
    await preferences.setStringList('log', log);

    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // For flutter prior to version 3.0.0
    // We have to register the plugin manually

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.get("settings_mqtt").toString();
    String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
    debugPrint("****************** user settings data $data");
    Map<String, dynamic> jsonMap = json.decode(decodeMessage);
    List<UserDataSettings> userDataSettings =
    UserDataSettings.getUserDataSettings(jsonMap);


    /// OPTIONAL when use custom notification
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    /******** tole sem probala in prikaze vse razen prvega*******/
    tzl.initializeTimeZones();
    final slovenia = tz.getLocation('Europe/London');
    final localizedDt = tz.TZDateTime.from(DateTime.now(), slovenia);

    List<NotificationMessage> notificationList = await ApiService.getNotificationMessage();
    for (var i = 0; i < notificationList.length; i++) {
      debugPrint("showing notification: ${notificationList[i].title}. $i");

      await flutterLocalNotificationsPlugin.zonedSchedule(
          i,
          "A Notification From My App ",
          "$notificationList[i].title",
          tz.TZDateTime.now(slovenia).add(const Duration(seconds: 3)),
          //localizedDt,//tz.initializeTimeZones(),//.add(const Duration(days: 3)),
          const NotificationDetails(
              android: AndroidNotificationDetails(
                "1",
                "11",
              )),          //androidScheduleMode: AndroidScheduleMode,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
    }
  }
}