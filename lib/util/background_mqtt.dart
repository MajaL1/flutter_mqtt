import 'dart:async';
import 'dart:ui';

import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import '../model/constants.dart';

class BackgroundMqtt {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  BackgroundMqtt(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin):
    flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;


  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
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

    /// OPTIONAL when use custom notification
    //final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //  FlutterLocalNotificationsPlugin();

    SmartMqtt.instance.addListener(() {});
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
        debugPrint(">>>>>>> service.setAsForegroundService()");
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
        debugPrint(">>>>>>> service.setAsBAckgroundService()");
      });
    }

    service.on('stopService').listen((event) {
      debugPrint(">>>>>>>stopped service.");
      service.stopSelf();
    });

    //FlutterBackgroundService().invoke("setAsBackground");

    Timer.periodic(const Duration(seconds: 40), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          /// OPTIONAL for use custom notification
          /// the notification id must be equals with AndroidConfiguration when you call configure() method.
          /*flutterLocalNotificationsPlugin.show(
                888,
                'COOL SERVICE',
                'Awesome ${DateTime.now()}',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'my_foreground',
                    'MY FOREGROUND SERVICE',
                    icon: 'ic_bg_service_small',
                    ongoing: true,
                  ),
                ),
              ); */

          // if you don't using custom notification, uncomment this
          service.setForegroundNotificationInfo(
            title: "My App Service",
            content: "Updated at ${DateTime.now()}",
          );
        }
      }
      debugPrint("SmartMqtt:: ${SmartMqtt.instance.toString()}");
      /*Alarm alarm = Alarm(
              sensorAddress: "start connect to client",
              typ: 2,
              v: 1,
              hiAlarm: 10,
              loAlarm: 2,
              ts: DateTime.timestamp(),
              lb: 1,
              bv: 3,
              r: 1,
              l: 3,
              b: 2,
              t: 3);
          NotificationHelper.sendMessage(alarm); */

      //debugPrint("///// toString: ${instance.toString()}");
      SharedPreferences.getInstance().then((val) {
        //var smartMqtt = val.getString("smart_mqtt");
        //String smartMqtt1 =json.decode(smartMqtt!);
        //var smartMqttObj = SmartMqttConnect.fromJson(smartMqtt!);
        //val?.setBool("appRunInBackground", true);
        bool? appRunInBackground = val.getBool("appRunInBackground");
        debugPrint("main.dart appRunInBackground: $appRunInBackground");
        String ? username = val.getString("username");
        String ? password = val.getString("pass");
        String ? userTopicList = val.getString("user_topic_list");
        String? currentState = val.getString("current_state");
        String? clientIdentifier = val.getString("identifier");
        bool? connected = val.getBool("connected");

        debugPrint(
            "////////////////main shared prefs in background: - $currentState, $username, $password, $userTopicList $currentState");
        SmartMqtt(mqttPass: password!,
            username: username!,
            topicList: userTopicList,
            port: Constants.BROKER_PORT,
            host: Constants.BROKER_IP);

        if (connected == null || !connected) {
          debugPrint(
              "zakomentirano recconect////////////////connected== null && !connected");

          //_reconnectToMqtt();
          val.setBool("connected", true);
        }

        if (currentState != null) {
          if (currentState != "MQTTAppConnectionState.disconnected") {
            debugPrint(
                "////////////////currentState != MQTTAppConnectionState.connected && currentState != connecting - $currentState");
          }
        }
      });
      print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}') as String?;
    });
  }

  Future<void> initializeService(service) async {
    debugPrint("main.dart initializing background service");

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    //final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //    FlutterLocalNotificationsPlugin();

    if (io.Platform.isIOS || io.Platform.isAndroid) {
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
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Alarm app',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: false,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
    debugPrint("main.dart end initializing background service");
  }

}