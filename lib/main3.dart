import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_test/util/data_smart_mqtt.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:workmanager/workmanager.dart';

import 'model/alarm.dart';
import 'pages/first_screen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

SharedPreferences? prefs;
const failedTaskKey = "failedTask";
const simplePeriodicTask = "simplePeriodicTask";

Future<void> main() async {
  tzl.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  //DartPluginRegistrant.ensureInitialized();

  // await initializeService(service);
  //SharedPreferences.setMockInitialValues({});
  SharedPreferences.getInstance().then((value) {
    if (value.getBool("isLoggedIn") != null) {
      if (!value.getBool("isLoggedIn")!) {
        value.setBool("isLoggedIn", false);
      }
    }
  });
  debugPrint("main method:: ");

  //var initialNotification =
  //await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  //if (initialNotification?.didNotificationLaunchApp == true) {
  // LocalNotifications.onClickNotification.stream.listen((event) {

  //}
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager().registerPeriodicTask("simplePeriodicTask", "simplePeriodicTask1");
  runApp(
    NotificationsApp(),
  );

}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, inputData) async {
    Workmanager().registerPeriodicTask(
      "simplePeriodicTask",
      "simplePeriodicTask1",
      //existingWorkPolicy: ExistingWorkPolicy.replace,
      //initialDelay:
      //    Duration(seconds: 5), //duration before showing the notification
      constraints: Constraints(networkType: NetworkType.connected),
      frequency: Duration(seconds: 10),
    );
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("workmanagerStarted", true);
    print("simplePeriodicTask was executed");
    return true;
  });
}

class NotificationsApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NotificationsApp({Key? key}) : super(key: key) {}

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
