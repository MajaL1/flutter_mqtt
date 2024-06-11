import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:ui';
import 'dart:isolate';


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
import 'package:mqtt_test/util/smart_mqtt_connect.dart';
import 'package:mqtt_test/util/smart_mqtt_obj.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:mqtt_test/widgets/constants.dart';
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

//final service = FlutterBackgroundService();

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';


/// A port used to communicate from a background isolate to the UI isolate.
//ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;


Future<void> main() async {

  Isolate.spawn<IsolateModel>(heavyTask, IsolateModel(355000, 500));
  tzl.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  //DartPluginRegistrant.ensureInitialized();
  final service = FlutterBackgroundService();

  await initializeService(service);
 // SharedPreferences.setMockInitialValues({});
  SharedPreferences.getInstance().then((value) {
    if (value.getBool("isLoggedIn") != null) {
      if (!value.getBool("isLoggedIn")!) {
        value.setBool("isLoggedIn", false);
      }
    }
  });
  debugPrint("main method:: ");

  var initialNotification =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  //if (initialNotification?.didNotificationLaunchApp == true) {
    // LocalNotifications.onClickNotification.stream.listen((event) {

  //}
  runApp(
     NotificationsApp(service),
  );
}

void heavyTask(IsolateModel model) {
  int total = 0;


  /// Performs an iteration of the specified count
  for (int i = 1; i < model.iteration; i++) {

    /// Multiplies each index by the multiplier and computes the total
    total += (i * model.multiplier);
  }

  debugPrint("FINAL TOTAL: $total");
}

class IsolateModel {
  IsolateModel(this.iteration, this.multiplier);

  final int iteration;
  final int multiplier;
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
      autoStart: true,
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
          SharedPreferences.getInstance().then((val){
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

            debugPrint("////////////////main shared prefs in background: - $currentState, $username, $password, $userTopicList $currentState");

            if(connected== null || !connected) {
              debugPrint("////////////////connected!= null && !connected");

              _reconnectToMqtt();
              val.setBool("connected", true);
            }

            if(currentState != null) {
              if (currentState != "MQTTAppConnectionState.disconnected") {
                debugPrint(
                    "////////////////currentState != MQTTAppConnectionState.connected && currentState != connecting - $currentState");
              }
            }
          });
          print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}') as String?;
        });
      }


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

   // prefs?.setBool("appRunInBackground", true);

    /*SmartMqtt mqtt = SmartMqtt(
        host: Constants.BROKER_IP,
        port: Constants.BROKER_PORT,
        username: username,
        mqttPass: mqttPassword,
        topicList: userTopicList); */
    //await mqtt.initializeMQTTClient();

    print("================== connecting to client from main.dart =========================");
    print("===========================================");

     //SmartMqtt.instance.initializeMQTTClient();
    SmartMqtt smartMqtt = SmartMqtt(host: Constants.BROKER_IP, port: Constants.BROKER_PORT, username: username, mqttPass: password, topicList: userTopicList);
    smartMqtt.initializeMQTTClient();
    print("current smartmqtt state: ${SmartMqtt.instance.client}");
  } else {
    print(
        "////////////////main.dart _reconnectToMqtt error -> null: username,pass,userTopicList == null, $username, $mqttPassword, $userTopicList");
  }
}

class NotificationsApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static FlutterBackgroundService service = FlutterBackgroundService();
    NotificationsApp(service, {Key? key}) : super(key: key) {
      service = service;
   }


  @override
  State<NotificationsApp> createState() => _NotificationsAppState(service);
}



class _NotificationsAppState extends State<NotificationsApp> {
  var prefs = 1;
  late final AppLifecycleListener _listener;
  final List<String> _states = <String>[];
  late AppLifecycleState? _state;
  late FlutterBackgroundService service;
  //static SendPort? uiSendPort;

  // static MethodChannel methodChannel = const MethodChannel('com.tarazgroup');

  _NotificationsAppState(FlutterBackgroundService service) {
    service = service;
    debugPrint("main==>service: $service");
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
    NotificationHelper.initializeService();
    //WidgetsBinding.instance.addObserver();
    super.initState();
    _state = SchedulerBinding.instance.lifecycleState;
    _listener = AppLifecycleListener(
      onShow: () => _handleTransition('show'),
      onResume: () => _handleTransition('resume'),
      onHide: () => _handleTransition('hide'),
      onInactive: () => _handleTransition('inactive'),
      onPause: () => _handleTransition('pause'),
      onDetach: () => _handleTransition('detach'),
      onRestart: () => _handleTransition('restart'),
      onExitRequested: () => _onExitRequested(),
      // This fires for each state change. Callbacks above fire only for
      // specific state transitions.
      onStateChange: _handleStateChange,
    );
    /*SharedPreferences.getInstance().then((val){
      val.setBool("appRunInBackground", false);
    });*/
    if (_state != null) {
      _states.add(_state!.name);
    }
  }

  Future<AppExitResponse> _onExitRequested() async {
    final response = await showDialog<AppExitResponse>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Are you sure you want to quit this app?'),
        content: const Text('All unsaved progress will be lost.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(AppExitResponse.cancel);
            },
          ),
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop(AppExitResponse.exit);
            },
          ),
        ],
      ),
    );

    return response ?? AppExitResponse.exit;
  }

  @override
  void dispose() {
    debugPrint("main.dart - dispose");
    _listener.dispose();
    super.dispose();
  }

  Future<void> _handleTransition(String name) async {
    setState(() {
      _states.add(name);
    });

    debugPrint("--handleTransition $name");
    if (name == "detach") {
      debugPrint("--handleTransition $name detaching from app");
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool("appRunInBackground", true);
      preferences.reload();
    }
  }

  void _handleStateChange(AppLifecycleState state) {
    setState(() {
      _state = state;
    });
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
      preferences.reload();
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
