import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_service.dart';
import 'model/alarm.dart';
import 'model/constants.dart';
import 'model/topic_data.dart';
import 'model/user.dart';
import 'mqtt/state/MQTTAppState.dart';
import 'pages/first_screen.dart';
import 'package:intl/intl_standalone.dart';

import 'package:timezone/data/latest.dart' as tzl;
//import 'package:timezone/standalone.dart' as tz;
//import 'package:timezone/browser.dart' as tz;
//import 'package:timezone/browser.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;

Future<void> main() async {
  //tzl.initializeTimeZones();
   tzl.initializeTimeZones();
   //tz.initializeTimeZone();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

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
List<String> createTopicListFromApi(User user) {
  List<TopicData> userTopicDataList = user.topic.topicList;
  List<String> userTopicList = [];
  String deviceName = user.topic.sensorName;
  for (TopicData topicData in userTopicDataList) {
    if (topicData.name.contains("settings")) {
      userTopicList.add(deviceName + "/settings");
    }
    if (topicData.name.contains("alarm")) {
      userTopicList.add(deviceName + "/alarm");
    }
  }
  return userTopicList;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  SmartMqtt.instance.addListener(() {});
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    debugPrint(">>>>>>>stopped service.");
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 180), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
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
        );

        // if you don't using custom notification, uncomment this
        service.setForegroundNotificationInfo(
          title: "My App Service",
          content: "Updated at ${DateTime.now()}",
        );
      }
    }
    String currState = SmartMqtt.instance.currentState.toString();

    if (MQTTAppConnectionState.disconnected ==
        SmartMqtt.instance.currentState) {
      print("SmartMqtt.instance.initializeMQTTClient()");

      User? user = await ApiService.login("test", "Test1234");
      if (user != null) {
        debugPrint(
            "loginForm, user: $user.username, $user.password, $user.topic");

        List<String> userTopicList = createTopicListFromApi(user);
        SmartMqtt mqtt = SmartMqtt(
            host: Constants.BROKER_IP,
            port: Constants.BROKER_PORT,
            username: user.username,
            mqttPass: user.mqtt_pass,
            topicList: userTopicList);
        await mqtt.initializeMQTTClient();
        await SmartMqtt.instance.client.connect();
        print("================== connectig to client =========================");
        print("===========================================");

        print("current smartmqtt state: $currState");
      }
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

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
        "device": device,
      },
    );
  });
}

class NotificationsApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const NotificationsApp({Key? key}) : super(key: key);

  @override
  State<NotificationsApp> createState() => _NotificationsAppState();
}

class _NotificationsAppState extends State<NotificationsApp> {
  var prefs = 1;

  static SendPort? uiSendPort;

  // static MethodChannel methodChannel = const MethodChannel('com.tarazgroup');

  _NotificationsAppState() {
    //methodChannel.setMethodCallHandler((call) => call.);
    /*  methodChannel.setMethodCallHandler((call) {
      print(call.method);
      return Future(() => call);
    }); */
  }

  @override
  void initState() {
    // ce shared preferences se nimajo objekta za alarme, ustvari novega
    debugPrint("main init state: ");
    initAlarmHistoryList();
    //NotificationHelper.initializeService();

    super.initState();
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
          ChangeNotifierProvider(create: (context) => SmartMqtt.instance)
        ],
        builder: (context, child) => Builder(builder: (context) {
              //  final MQTTAppState appState = Provider.of<MQTTAppState>(context, listen: false);
              debugPrint("build main.dart");
              //setCurrentAppState(appState);
              return MaterialApp(home: FutureBuilder(
                  //future: initializeConnection(appState),
                  builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  /*if (snapshot.hasError) {
                            return ErrorWidget(Exception(
                                'Error occured when fetching data from database'));
                          } else if (!snapshot.hasData) {
                            debugPrint("snapshot:: $snapshot");
                            return const Center(child: Text('Data is empty!'));
                          */
                  return FirstScreen.base();
                }
                // }
              }));
            }));
  }
}
