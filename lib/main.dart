import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:isolate';


import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/util/background_mqtt.dart';
import 'package:mqtt_test/util/data_smart_mqtt.dart';
import 'package:mqtt_test/util/settings_smart_mqtt.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
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

final service = FlutterBackgroundService();

//final service = FlutterBackgroundService();

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';


/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;


Future<void> main() async {

  tzl.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  //DartPluginRegistrant.ensureInitialized();

  final service = FlutterBackgroundService();
  await BackgroundMqtt(flutterLocalNotificationsPlugin).initializeService(service);

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
     NotificationsApp(),
  );
}


// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch



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
  //static FlutterBackgroundService service = FlutterBackgroundService();
    NotificationsApp({Key? key}) : super(key: key);



  @override
  State<NotificationsApp> createState() => _NotificationsAppState();
}




class _NotificationsAppState extends State<NotificationsApp> with WidgetsBindingObserver{
  var prefs = 1;
  late final AppLifecycleListener _listener;
  final List<String> _states = <String>[];
  late AppLifecycleState? _state;
  SendPort? _sendPort;
 // late FlutterBackgroundService service;
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
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _sendPort ??= IsolateNameServer.lookupPortByName('appState');
    switch(state){
      case AppLifecycleState.resumed:
        _sendPort?.send(false);
        break;
      case AppLifecycleState.paused:
        _sendPort?.send(true);
        break;
      default:
        break;
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
              return GetMaterialApp(home: FirstScreen.base());
            }));
  }
}
