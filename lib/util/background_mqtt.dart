import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
//mport 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:mqtt_test/main.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/constants.dart';
import 'log_file_helper.dart';

@pragma('vm:entry-point')
class BackgroundMqtt {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @pragma('vm:entry-point')
  BackgroundMqtt(this.flutterLocalNotificationsPlugin);

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
  static Future<bool> startMqttService() async {
    bool result = false;
    if (Platform.isAndroid) {
      result = await serviceAndroid.startService();
    }
   // else if (Platform.isIOS) {
   //   result = await serviceIOS.start();
   // }
    return result;
  }

  @pragma('vm:entry-point')
  static Future<void> stopMqttService() async {
      serviceAndroid.invoke("stopService");
    //return result;
  }
  @pragma('vm:entry-point')
  static Future<bool> publish(String message, String topicName) async{
    if (Platform.isAndroid) {
      serviceAndroid.invoke("invokeOnPublish", {
        "message": message,
        "topic": topicName,
      },);
    }
      //debugPrint("BackgroundMqtt: publish: ${BackgroundMqtt.smartMqtt}");
    //BackgroundMqtt.smartMqtt?.publish(message, topicName);
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setBool("serviceStopped", false);

    SharedPreferences.getInstance().then((value) {
      value.setBool("serviceStopped", false);
    });

    logger ??= await LogFileHelper.createLogger();
    logger.log(Level.info, "background_mqtt start onStart()");



    SmartMqtt ? smartMqtt;

    SmartMqtt.instance.addListener(() {});
      if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
        debugPrint(">>>>>>> service.setAsForegroundService()");
        logger.log(Level.info, ">>>>>>> service.setAsForegroundService()");

      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
        debugPrint(">>>>>>> service.setAsBackgroundService()");
        logger.log(Level.info, ">>>>>>> service.setAsBackgroundService()");
      });
    }
    if (service is IOSServiceInstance) {
      service.on('setAsForeground').listen((event) {
       // TODO service.invoke();
        //serviceIOS.invoke("setAsForeground", {
       
        //},);
        debugPrint(">>>>>>> service.setAsForegroundService()");
        logger.log(Level.info, ">>>>>>> service.setAsForegroundService()");

      });

      service.on('setAsBackground').listen((event) {
        //service.setAsBackgroundService();

        //serviceIOS.invoke("setAsBackgorund", {
        //},);
        debugPrint(">>>>>>> service.setAsBackgroundService()");
        logger.log(Level.info, ">>>>>>> service.setAsBackgroundService()");
      });
    }
    service.on('stopService').listen((event) {
      debugPrint(">>>>>>>stopped service.");
      logger.log(Level.info, ">>>>>>>stopped service.");
      service.invoke("stopService");
      if(smartMqtt!.getConnectionState()){
        smartMqtt?.disconnect();
        smartMqtt?.dispose();
      }
      service.stopSelf();
    });

    //StreamBuilder<Map<String, dynamic>?>(
    //  stream:
    service.on('invokeOnPublish').listen((event) {
      if(event!= null) {
        debugPrint("event: $event, $smartMqtt");
        String  message = event["message"];
        String ? topic = event["topic"];
        smartMqtt?.publish(message, topic!);
      }
    });
   // );
    //FlutterBackgroundService().invoke("setAsBackground");
    DateTime startTime = DateTime.now();

    DateTime currentTime = DateTime.now();
    debugPrint(" startTime, currentTime $startTime, $currentTime");
    debugPrint("SmartMqtt:: ${SmartMqtt.instance.toString()}");


    SharedPreferences.getInstance().then((val) {
      val.reload();

      if(val.getString("username") == null || val.getString("mqtt_pass")== null || val.getString("user_topic_list")==null) {
        debugPrint("1 - service.stopSelf();");
        logger.log(Level.info, "1 - service.stopSelf();");
        service.stopSelf();
        return;
      }

      if( smartMqtt != null) {
        debugPrint(" 2 - smartMqtt?.getConnectionState() ${smartMqtt?.getConnectionState()}");
        if(smartMqtt?.getConnectionState() == true )
        {
          return;
        }
      }
      else {
        debugPrint("3 - smartMqtt == null");
      }
      bool? appRunInBackground = val.getBool("appRunInBackground");
      debugPrint("main.dart appRunInBackground: $appRunInBackground");
      String? username = val.getString("username");
      String? password = val.getString("mqtt_pass");
      String? userTopicList = val.getString("user_topic_list");
      String? currentState = val.getString("current_state");
      String? clientIdentifier = val.getString("identifier");
      debugPrint("//////////////// 1 background_mqtt shared prefs in background: - $currentState, $clientIdentifier, $username, $password, $userTopicList $currentState");

      smartMqtt = SmartMqtt(mqttPass: password!,
          username: username!,
          topicList: userTopicList,
          port: Constants.BROKER_PORT,
          host: Constants.BROKER_IP);
      //MqttServerClient ? client = smartMqtt?.initializeMQTTClient();
      //debugPrint("::SmartMqtt.initalizeClient: $client");
      //smartMqtt?.setClient(client!);

    });
    logger.log(Level.info, "FLUTTER BACKGROUND SERVICE: ${DateTime.now()}'");
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}') as String?;
  }

  /* void callMqttConnect(DateTime startTime, ServiceInstance service) {
    DateTime currentTime = DateTime.now();
    debugPrint(" startTime, currentTime $startTime, $currentTime");
    debugPrint("SmartMqtt:: ${SmartMqtt.instance.toString()}");

    SharedPreferences.getInstance().then((val) {
      val.reload();

      if(val.getString("username") == null || val.getString("mqtt_pass")== null || val.getString("user_topic_list")==null) {
        debugPrint("1 - service.stopSelf();");
        service.stopSelf();
        return;
      }

      if( smartMqtt != null) {
        debugPrint(" 2 - smartMqtt?.getConnectionState() ${smartMqtt?.getConnectionState()}");
        if(smartMqtt?.getConnectionState() == true )
        {
         return;
        }
      }
      else {
        debugPrint("3 - smartMqtt == null");
      }
      bool? appRunInBackground = val.getBool("appRunInBackground");
      debugPrint("main.dart appRunInBackground: $appRunInBackground");
      String? username = val.getString("username");
      String? password = val.getString("mqtt_pass");
      String? userTopicList = val.getString("user_topic_list");
      String? currentState = val.getString("current_state");
      String? clientIdentifier = val.getString("identifier");
      debugPrint("//////////////// 1 background_mqtt shared prefs in background: - $currentState, $clientIdentifier, $username, $password, $userTopicList $currentState");

      smartMqtt = SmartMqtt(mqttPass: password!,
          username: username!,
          topicList: userTopicList,
          port: Constants.BROKER_PORT,
          host: Constants.BROKER_IP);
    });
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}') as String?;
  } */

  @pragma('vm:entry-point')
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

    /*if (io.Platform.isIOS || io.Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    //}*/ 

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
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Alarm app',
        initialNotificationContent: 'Running in background',
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
    debugPrint("main.dart end initializing background service");
    //logger.log(Level.info, "main.dart end initializing background service");

  }
}
