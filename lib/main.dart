import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';

//import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzl;

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
      debugPrint("service.setAsForegroundService()");
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      debugPrint("service.setAsBAckgroundService()");
    });
  }

  service.on('stopService').listen((event) {
    debugPrint(">>>>>>>stopped service.");
    service.stopSelf();
  });

  MQTTAppConnectionState? appState = SmartMqtt.instance.currentState;
  debugPrint("////////////////1 main.dart - $appState");

  // bring to foreground
  Timer.periodic(const Duration(seconds: 180), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
      }
    }
    prefs?.setBool("appRunInBackground", true);

    // TODO: PReveri, kako deluje z MqttClient autoReconnected = false
    // ali se ob delovanju v ozadju ugasne!

    MQTTAppConnectionState? appState = SmartMqtt.instance.currentState;
    debugPrint("////////////////2 main.dart - $appState");

    if (SmartMqtt.instance.currentState == MQTTAppConnectionState.connected) {
      debugPrint("////////////////main.dart - connected:");
    }
    if (SmartMqtt.instance.currentState == null ||
        SmartMqtt.instance.currentState ==
            MQTTAppConnectionState.disconnected) {
      debugPrint("////////////////main.dart - disconnected:");
      print("////////////////main.dart will call _reconnectToMqtt");
      /** Todo: if logged in _reconnect*/

      /*** ce je povezava prekinjena, reconnect **/
      await _reconnectToMqtt();
    } else {
      debugPrint("///main.dart - connected ??? x:");
    }

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
        "device": device,
      },
    );
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

    SmartMqtt.instance.client = MqttServerClient(
        Constants.BROKER_IP, identifier,
        maxConnectionAttempts: 1);
    SmartMqtt.instance.initializeMQTTClient(
        username, mqttPassword, identifier, userTopicList);
    //SmartMqtt.instance.client.
    //await SmartMqtt.instance.client.connect();
    print("================== connecting to client =========================");
    print("===========================================");

    print("current smartmqtt state: $SmartMqtt.instance.client");
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

  @override
  void initState() {
    // ce shared preferences se nimajo objekta za alarme, ustvari novega
    debugPrint("main init state: ");
    initAlarmHistoryList();
    //NotificationHelper.initializeService();
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

      initializeService().then((value) => {
            // if(SmartMqtt.instance.client.connectionStatus == MQTTAppConnectionState.disconnected)

            Future.delayed(const Duration(milliseconds: 500), () {
              print("SmartMqtt.instance.initializeMQTTClient()");
              /** Todo: if logged in _reconnect*/
              String currState = SmartMqtt.instance.currentState.toString();
              /*** ce je povezava prekinjena, reconnect **/
              _reconnectToMqtt();
            })

            // }
          });
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
              return MaterialApp(home: FirstScreen.base());
            }));
  }
}
