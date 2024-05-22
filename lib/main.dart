import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/util/data_smart_mqtt.dart';
import 'package:mqtt_test/util/settings_smart_mqtt.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzl;

import 'api/notification_helper.dart';
import 'model/alarm.dart';
import 'model/constants.dart';
import 'mqtt/MQTTAppState.dart';
import 'pages/first_screen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
//ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;

Future<void> main() async {
  tzl.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  //DartPluginRegistrant.ensureInitialized();
  await initializeService();
  //SharedPreferences.setMockInitialValues({});
  SharedPreferences.getInstance().then((value) {
    if (value.getBool("isLoggedIn") != null) {
      if (!value.getBool("isLoggedIn")!) {
        value.setBool("isLoggedIn", false);
      }
    }
  });
  debugPrint("main method:: ");
  runApp(
    const NotificationsApp(),
  );
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  debugPrint("main.dart initializing background service");

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
       initialNotificationTitle: 'Alarm app',
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
  debugPrint("main.dart end initializing background service");
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

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

// Todo: premakni v UTIL

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
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

        Timer.periodic(const Duration(seconds: 180), (timer) async {
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
          prefs?.setBool("appRunInBackground", true);
          debugPrint("SmartMqtt:: ${SmartMqtt.instance.toString()}");
          Alarm alarm = Alarm(
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
          NotificationHelper.sendMessage(alarm);

          //SmartMqtt.instance.client;

          SharedPreferences.getInstance().then((val){
            String? smartMqtt = val.getString("smart_mqtt");
            debugPrint("///////////// SmartMqtt from preferences: ${smartMqtt.toString()}");
          });

          SharedPreferences.getInstance().then((val){
            String? clientMqtt = val.getString("client_mqtt");

            Object clientObj = json.decode(clientMqtt!);
            debugPrint("///////////// ClientMqtt from preferences: ${clientMqtt.toString()}");
          });

          SharedPreferences.getInstance().then((val){
            String ? currentState = val.getString("current_state");
            debugPrint("////////////////2 main.dart - currentState - $currentState");

            if(currentState == "MQTTAppConnectionState.connected"){
              debugPrint("////////////////2 main.dart - currentState is connected - $currentState");
              SmartMqtt.instance.ping();
              //SmartMqtt.instance.client!.connectionStatus;

            }
            else {
              debugPrint("////////////////2 main.dart - NOT CONNECTED currentState is connected - $currentState");

             // _reconnectToMqtt();
            }
          });
          /*
          MQTTAppConnectionState? appState = SmartMqtt.instance.currentState;
          debugPrint("////////////////2 main.dart - $appState");

          if (SmartMqtt.instance.getCurrentState() ==
              MQTTAppConnectionState.connected) {
            debugPrint("////////////////main.dart - connected:");
          }
          SmartMqtt.instance.getCurrentState().then((val){
            debugPrint("///////////// VAL: $val");
          });
          if (SmartMqtt.instance.currentState == null ||
              SmartMqtt.instance.currentState ==
                  MQTTAppConnectionState.disconnected) {
            debugPrint("////////////////main.dart - disconnected:");
            print("////////////////main.dart will call _reconnectToMqtt");

            /*** ce je povezava prekinjena, reconnect **/
            //await _reconnectToMqtt();
          } else {
            debugPrint("///main.dart - connected ??? x:");
          }
          */

          /// you can see this log in logcat
          print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}') as String?;



          // test using external plugin
          final deviceInfo = DeviceInfoPlugin();
          String? device;
          if (io.Platform.isAndroid) {
            final androidInfo = await deviceInfo.androidInfo;
            device = androidInfo.model;
          }

          if (io.Platform.isIOS) {
            final iosInfo = await deviceInfo.iosInfo;
            device = iosInfo.model;
          }

          service.invoke(
            'update',
            {
              "current_date": DateTime.now().toIso8601String(),
              "device": "aaa",
            },
          );
        });
      }
 /*   }
  });
} */

Future<void> _reconnectToMqtt() async {
  print("////////////////calling _reconnectToMqtt");

  String username;
  String mqttPassword;

  username = await SharedPreferences.getInstance().then((value) {
    if (value.getString("mqtt_username") != null) {
      username = value.getString("mqtt_username")!;
      return username;
    }
    return "";
  });

  mqttPassword = await SharedPreferences.getInstance().then((value) {
    if (value.getString("mqtt_pass") != null) {
      mqttPassword = value.getString("mqtt_pass")!;
      return mqttPassword;
    }
    return "";
  });

  String? userTopicListPref =
      await SharedPreferences.getInstance().then((value) {
    if (value.getString("user_topic_list") != null) {
      return value.getString("user_topic_list");
    }
  });
  List userTopicList = [];

  if (userTopicListPref != null) {
    userTopicList = json.decode(userTopicListPref).cast<String>();
  }

  if (username.isNotEmpty &&
      mqttPassword.isNotEmpty &&
      userTopicList!.isNotEmpty) {
    print(
        "////////////////main.dart _reconnectToMqtt username != null && pass != null && userTopicList != null");
    debugPrint("////////////////main.dart _reconnectToMqtt $username, $mqttPassword, $userTopicList");

    prefs?.setBool("appRunInBackground", true);

    /*SmartMqtt mqtt = SmartMqtt(
        host: Constants.BROKER_IP,
        port: Constants.BROKER_PORT,
        username: username,
        mqttPass: mqttPassword,
        topicList: userTopicList); */
    //await mqtt.initializeMQTTClient();
    String l = Utils.generateRandomString(10);
    //String identifier = "_12apxeeejjjewg";
    String identifier = l.toString();

    //SmartMqtt.instance.client = MqttServerClient(
    //    Constants.BROKER_IP, identifier,
    //    maxConnectionAttempts: 1);
    await SmartMqtt.instance.initializeMQTTClient();
    //SmartMqtt.instance.client.
    //await SmartMqtt.instance.client!.connect();
    print("================== connecting to client =========================");
    print("===========================================");


    print("current smartmqtt state: ${SmartMqtt.instance.client}");
  } else {
    print(
        "////////////////main.dart _reconnectToMqtt error -> null: username,pass,userTopicList == null, $username, $mqttPassword, $userTopicList");
  }
}

class NotificationsApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const NotificationsApp({Key? key}) : super(key: key);

  @override
  State<NotificationsApp> createState() => _NotificationsAppState();
}

class _NotificationsAppState extends State<NotificationsApp> {
  var prefs = 1;
  late final AppLifecycleListener _listener;
  final List<String> _states = <String>[];
  late AppLifecycleState? _state;

  //static SendPort? uiSendPort;

  // static MethodChannel methodChannel = const MethodChannel('com.tarazgroup');

  _NotificationsAppState() {
    //methodChannel.setMethodCallHandler((call) => call.);
    /*  methodChannel.setMethodCallHandler((call) {
      print(call.method);
      return Future(() => call);
    }); */
  }



  Future<void> initAlarmHistoryList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey("alarm_list_mqtt")) {
      List<Alarm> alarmList = [];
      //preferences.clear();
      // pocistimo settinge iz
      preferences.remove("settings_mqtt");
      String alarmListData = json.encode(alarmList);
      //json.decode(alarmListData);
      preferences.setString("alarm_list_mqtt", alarmListData);
    }
    preferences.get("alarm_list_mqtt");
  }

  @override
  Widget build(BuildContext context) {
    //SharedPreferences.getInstance().then((prefValue) => debugPrint(this));

    debugPrint("00000000000 main.dart build");

    return MultiProvider(
        providers: [
          //ChangeNotifierProvider<MQTTAppState>(create: (_) => MQTTAppState()),
          ChangeNotifierProvider(create: (context) => SmartMqtt.instance),
          ChangeNotifierProvider(create: (context) => DataSmartMqtt.instance),
         // ChangeNotifierProvider(create: (context) => SettingsSmartMqtt.instance),
        ],
        builder: (context, child) => Builder(builder: (context) {
              //  final MQTTAppState appState = Provider.of<MQTTAppState>(context, listen: false);
              debugPrint("build main.dart");
              return MaterialApp(home: FirstScreen.base());
            }));
  }
}
