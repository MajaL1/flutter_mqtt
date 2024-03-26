import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_test/widgets/show_alarm_time_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/standalone.dart' as tz;

import '../main.dart';
import '../model/alarm.dart';
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

    String eventID = "as432445GFCLbd2in1en21093";
    int notificationId = eventID.hashCode;

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
          android: AndroidInitializationSettings('icon'),
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
          notificationChannelId: 'alarms',
          initialNotificationTitle: 'ALARM',
          initialNotificationContent: 'Initializing',
          foregroundServiceNotificationId: notificationId,
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
    //tzl.initializeTimeZones();
    tzl.initializeTimeZones();
    debugPrint("Sending alarm: NotificationHelper.sendMessage");
    // tz.setLocalLocation(tz.getLocation('Europe/London'));
    final slovenia = await tz.getLocation('Europe/London');

    //final localizedDt = tz.TZDateTime.from(DateTime.now(), slovenia);

    String? deviceName = alarmMessage?.deviceName.toString();
    String? hiAlarm = alarmMessage?.hiAlarm.toString();
    String? loAlarm = alarmMessage?.loAlarm.toString();
    String? v = alarmMessage?.v.toString();
    String? sensorAddress = alarmMessage?.sensorAddress;

    String alarmValue = "";

    if (alarmMessage?.hiAlarm != 0 && alarmMessage?.hiAlarm != null) {
      alarmValue = "Hi alarm: $hiAlarm";
    }
    if (alarmMessage?.loAlarm != 0 && alarmMessage?.loAlarm != null) {
      alarmValue += " Lo alarm: $loAlarm";
    }

    //   debugPrint(
    //       "**************************alarm sending message  message: $alarmMessage");
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(alarmMessage!.ts!);

    final bigPicture = await Utils.getImageFilePathFromAssets(
        'assets/images/bell1.png', 'bigpicture');

    /* final styleinformationDesign = BigPictureStyleInformation(
      FilePathAndroidBitmap(smallpicture),
      summaryText: "Alarm for $sensorAddress",
    ); */

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "deviceName: $deviceName, sensor: $sensorAddress",
      "$alarmValue, date: $formattedDate",
      color: Colors.redAccent,
      largeIcon: FilePathAndroidBitmap(bigPicture),
      importance: Importance.max,
      priority: Priority.high,
      groupKey: "alarms",
      setAsGroupSummary: false,
      colorized: true,
      enableLights: true,
      /*styleInformation: const BigTextStyleInformation(
          '<b>Your</b> notification',
          htmlFormatBigText: true,
        ), */
      category: AndroidNotificationCategory.alarm,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    String eventID = "as432445GFCLbd2in1en21093";
    int notificationId = eventID.hashCode;
    //Text text1 = Text("Alarm value: $v", style: TextStyle(fontWeight: FontWeight.bold));
    // Text text2 = Text("$alarmValue", style: TextStyle(fontWeight: FontWeight.bold));
    //Text text3 = Text("$sensorAddress", style: TextStyle(fontWeight: FontWeight.bold));

    //String ?t1 = text1.data;
    //String ?t2 = text2.data;
    //String ?t3 = text3.data;

    String? showInterval = await SharedPreferences.getInstance().then((value) {
      if (value.getString("alarm_interval") != null) {
        return value.getString("alarm_interval");
      }
    });
    debugPrint("sending message... interval $showInterval");

    int timeIntervalMinutes = 1;
    const int seconds = 5;
    switch (showInterval) {
      case ShowAlarmTimeSettings.minutes10:
        timeIntervalMinutes = 10;
        break;
      case ShowAlarmTimeSettings.minutes30:
        timeIntervalMinutes = 30;
        break;
      case ShowAlarmTimeSettings.hour:
        timeIntervalMinutes = 60;
        break;
      case ShowAlarmTimeSettings.hour6:
        timeIntervalMinutes = 360;
        break;
      case ShowAlarmTimeSettings.hour12:
        timeIntervalMinutes = 720;
        break;
      case ShowAlarmTimeSettings.day:
        timeIntervalMinutes = 1440;
        break;
      default:
        timeIntervalMinutes = 10;
    }
    final int minutes = timeIntervalMinutes;
    await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        "Alarm from: $sensorAddress, $deviceName",
        //"$t1 \n $t2 \n$t3",
        "v: $v, $alarmValue \n$formattedDate",
        tz.TZDateTime.now(slovenia).add(Duration(minutes: 1)),
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

    /// OPTIONAL when use custom notification
    // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //     FlutterLocalNotificationsPlugin();

    if (service is AndroidServiceInstance) {
      // debugPrint("setAsForeground message : ");
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        //  debugPrint("setAsBackground : ");
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    tzl.initializeTimeZones();
  }
}
