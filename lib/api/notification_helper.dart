import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_test/main.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzl;
//import 'package:timezone/timezone.dart' as tz;


import '../model/alarm.dart';
import '../widgets/units.dart';

@pragma('vm:entry-point')
class NotificationHelper extends ChangeNotifier {
  static FlutterBackgroundService service = FlutterBackgroundService();
  static final NotificationHelper _instance = NotificationHelper._internal();

  NotificationHelper._internal();
  static NotificationHelper get instance => _instance;

  Widget build(BuildContext context) {
    return Container();
  }

  @pragma('vm:entry-point')
  static Future<void> initializeService() async {


    //service = FlutterBackgroundService();

    String eventID = "as432445GFCLbd2in1en21093";
    int notificationId = eventID.hashCode;

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
      //sound:
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    //flutterLocalNotificationsPlugin.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    //flutterLocalNotificationsPlugin.initialize(initializationSettings, onSe)

    //flutterLocalNotificationsPlugin.
    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
          //onDidReceiveNotificationResponse:
          const InitializationSettings(
            iOS: DarwinInitializationSettings(),
            android: AndroidInitializationSettings(
              'icon'
            ),
          ),
          onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
          onDidReceiveNotificationResponse:
              (NotificationResponse details) async {
        Get.to(const AlarmHistory());
      });
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if(Platform.isAndroid){
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      }
          await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
    

    await service.configure(
      androidConfiguration: AndroidConfiguration(
          // this will be executed when app is in foreground or background in separated isolate
          onStart: onStart,
          // auto start service
          autoStart: true,
          isForegroundMode: true,
          notificationChannelId: 'alarms',
          initialNotificationTitle: 'ALARM',
          initialNotificationContent: '1Initializing',
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
  @pragma('vm:entry-point')
  static Future<void> startMesagingService(String message) async {
    debugPrint("Messaging service started, message: $message");

    // setSendAlarm(message);
    service.startService();
  }

  @pragma('vm:entry-point')
   static Future<void> notificationTapBackground(NotificationResponse details) async {
    debugPrint("TAP BACKGROUND");
    Get.to(const AlarmHistory());
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

   Future<void> sendMessage(Alarm? alarmMessage) async {
    debugPrint("Sending alarm: NotificationHelper.sendMessage");
    String? friendlyName = alarmMessage?.friendlyName;
    String? hiAlarm = alarmMessage?.hiAlarm.toString();
    String? loAlarm = alarmMessage?.loAlarm.toString();
    String? v = alarmMessage?.v.toString();
    int? u = alarmMessage?.u;
    String? sensorAddress = alarmMessage?.sensorAddress;
    String? deviceName = alarmMessage?.deviceName.toString();

    String units = UnitsConstants.getUnits(u);
    String alarmValue = "";

    if (alarmMessage?.hiAlarm != 0 && alarmMessage?.hiAlarm != null) {
      alarmValue = "$hiAlarm";
    }
    if (alarmMessage?.loAlarm != 0 && alarmMessage?.loAlarm != null) {
      alarmValue += "$loAlarm";
    }

    //   debugPrint(
    //       "**************************alarm sending message  message: $alarmMessage");
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(alarmMessage!.ts!);
   String? name = (friendlyName!= null && friendlyName.isNotEmpty) ? friendlyName : "";
   if(name.isEmpty) {
     name = "$deviceName $sensorAddress";
   }

       //: "deviceName: ${deviceName}, sensor:  ${sensorAddress}";
    //debugPrint(" 4444 friendlyName: , $friendlyName, na,me: $name");

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      name,
      "$alarmValue, date: $formattedDate",
      color: Colors.redAccent,
      icon: "icon",
      //actions: ,
      //largeIcon: FilePathAndroidBitmap(bigPicture),
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

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();


    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSPlatformChannelSpecifics

    );

    String eventID = "as432445GFCLbd2in1en2103";
    int notificationId = eventID.hashCode;

    debugPrint("showing alarm... $alarmMessage");
    await flutterLocalNotificationsPlugin.show(notificationId, "Alarm on $name","$v $units\nalarm level $alarmValue $units,  $formattedDate", notificationDetails);

    await SharedPreferences.getInstance().then((value) {
      value.setBool("historyChanged", true);
    });

     //await flutterLocalNotificationsPlugin.show(notificationId, "Alarm on device $name", "v: $v $units, $alarmValue \n$formattedDate", notificationDetails);
    //  notifyListeners();
  }


  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    //await Navigator.push(
    //  context as BuildContext,
    //  MaterialPageRoute<void>(builder: (context) => AlarmHistory()),
    //);
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    //service.runtimeType.
    // For flutter prior to version 3.0.0
    // We have to register the plugin manually

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.get("settings_mqtt").toString();
    //String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
    debugPrint("****************** preferences settings_mqtt $data");


    /// OPTIONAL when use custom notification
    // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //     FlutterLocalNotificationsPlugin();

    //if (service is AndroidServiceInstance) {
      // debugPrint("setAsForeground message : ");
      service.on('setAsForeground').listen((event) {
        service.invoke("startService");
        debugPrint(" running in foreground Updated at ${DateTime.now()}");
      });

      service.on('setAsBackground').listen((event) {
        service.invoke("stopService");
        debugPrint(" running in background Updated at ${DateTime.now()}");
        //  debugPrint("setAsBackground : ");
        //service.setAsBackgroundService();
      });

    
    //}

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    tzl.initializeTimeZones();
  }

  Future<List<Alarm>> getRefreshedAlarmList() async {
    List<Alarm> refreshedAlarmList = [];
    // return shared prefs
    return refreshedAlarmList;
  }
}
