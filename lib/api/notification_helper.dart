import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/standalone.dart' as tz;

import '../main.dart';
import '../model/alarm.dart';
import '../model/user_data_settings.dart';
import '../util/utils.dart';

class NotificationHelper extends StatelessWidget {
  const NotificationHelper({Key? key}) : super(key: key);
  static FlutterBackgroundService service = FlutterBackgroundService();

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  static Future<void> initializeService() async {
    service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    //flutterLocalNotificationsPlugin.
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('launcher_notification'),
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
          initialNotificationTitle: 'ALARM',
          initialNotificationContent: 'Initializing',
          foregroundServiceNotificationId: 888,
          autoStartOnBoot: true),
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

  static Future<void> startMesagingService(String message) async {
    debugPrint("Messaging service started, message: $message");

    // setSendAlarm(message);
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

  static Future<void> sendMessage(Alarm? alarmMessage) async {
    final slovenia = tz.getLocation('Europe/London');
    final localizedDt = tz.TZDateTime.from(DateTime.now(), slovenia);

    String? sensorAddress = alarmMessage?.sensorAddress.toString();
    String? hiAlarm = alarmMessage?.hiAlarm.toString();
    String? loAlarm = alarmMessage?.loAlarm.toString();
    String? v = alarmMessage?.v.toString();

    String alarmValue = "";

    if (alarmMessage?.hiAlarm != 0 && alarmMessage?.hiAlarm != null) {
      alarmValue = "Hi alarm: $hiAlarm";
    }
    if (alarmMessage?.loAlarm != 0 && alarmMessage?.loAlarm != null) {
      alarmValue += " Lo alarm: $loAlarm";
    }

    debugPrint(
        "**************************alarm sending message  message: $alarmMessage");
    String date = alarmMessage?.ts.toString() ?? "";
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(alarmMessage!.ts!);

    final bigpicture = await Utils.getImageFilePathFromAssets(
        'assets/images/bell1.png', 'bigpicture');
    final smallpicture = await Utils.getImageFilePathFromAssets(
        'assets/images/bell1.png', 'smallpicture');

    /* final styleinformationDesign = BigPictureStyleInformation(
      FilePathAndroidBitmap(smallpicture),
      summaryText: "Alarm for $sensorAddress",
    ); */

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            "sensor: $sensorAddress",
            "$alarmValue, date: $formattedDate",
            color: Colors.redAccent,
            largeIcon: FilePathAndroidBitmap(bigpicture),
            //const DrawableResourceAndroidBitmap('bell2.png'),
            // styleInformation: styleinformationDesign,
            importance: Importance.max,
            priority: Priority.high);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        "Alarm from sensor: $sensorAddress",
        "v: $v, $alarmValue \n$formattedDate",
        tz.TZDateTime.now(slovenia).add(const Duration(seconds: 3)),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
    //localizedDt,//tz.initializeTimeZones(),//.add(const Duration(days: 3)),
    //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();
//service.runtimeType.
    // For flutter prior to version 3.0.0
    // We have to register the plugin manually

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.get("settings_mqtt").toString();
    String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
    debugPrint("****************** preferences settings_mqtt $data");
    Map<String, dynamic> jsonMap = json.decode(decodeMessage);
    List<UserDataSettings> userDataSettings =
        UserDataSettings.getUserDataSettings(jsonMap);

    /// OPTIONAL when use custom notification
    // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //     FlutterLocalNotificationsPlugin();

    if (service is AndroidServiceInstance) {
      debugPrint("setAsForeground message : ");
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        debugPrint("setAsBackground : ");
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    tzl.initializeTimeZones();
  }
}
