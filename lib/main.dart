import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:logger/logger.dart';
import 'package:mqtt_test/util/background_mqtt.dart';
import 'package:mqtt_test/util/log_file_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzl;

import 'model/alarm.dart';
import 'pages/first_screen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final serviceAndroid = FlutterBackgroundService();
//final service = FlutterBackgroundService();

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;

var logger;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  tzl.initializeTimeZones();

  if (Platform.isAndroid) {
    //final serviceAndroid = FlutterBackgroundService();

    var status = await Permission.storage.status;
    if (status.isDenied) {
      debugPrint("yes status.isDenied");
      Map<Permission, PermissionStatus> statuses = await [
        //Permission.location,
        Permission.storage,
      ].request();
    } else {
      logger = await LogFileHelper.createLogger();
      debugPrint("not status.isDenied");
      //await FileDownloaderHelper.saveFileOnDevice();


      //dodamo ios permission za plugin
      /* await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
*/

    }
  }
      if (await serviceAndroid.isRunning()) { 
        debugPrint("----isRunning on Android");
        logger.log(Level.info, "---- service is running on Android: isRunning");
      }
       else {
        print("----notRunning on Android");
       // logger.log(Level.info, "---- service NOT running on Android: notRunning");

        await BackgroundMqtt(flutterLocalNotificationsPlugin).initializeService(serviceAndroid);
      }
    
  
  /*else if(Platform.isIOS) {
    FlutterBackgroundServiceIOS serviceIOS = FlutterBackgroundServiceIOS();
    // TODO
    if (await serviceIOS.isServiceRunning()) {
      debugPrint("----isRunning on IOS");
      logger.log(Level.info, "---- service is running on IOS: isRunning");
    } else {
      print("----notRunning on IOS");
      serviceIOS.start();
     // logger.log(Level.info, "---- service NOT running on IOS: notRunning");
      serviceIOS.invoke("startService", {
       
        },);
      await BackgroundMqtt(flutterLocalNotificationsPlugin).initializeService(serviceIOS);
    }
  }*/
  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final log = preferences.getStringList('log') ?? <String>[];
    log.add(DateTime.now().toIso8601String());
    print("ON IOS BACKGROUND");
    await preferences.setStringList('log', log);

    return true;
  }


  // SharedPreferences.setMockInitialValues({});
  await SharedPreferences.getInstance().then((value) {
    if (value.getBool("isLoggedIn") != null) {
      if (!value.getBool("isLoggedIn")!) {
        value.setBool("isLoggedIn", false);
      }
    }
  });
  debugPrint("main method:: ");

  //var initialNotification = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  //if (initialNotification?.didNotificationLaunchApp == true) {
  // LocalNotifications.onClickNotification.stream.listen((event) {

  //}
  runApp(
    const NotificationsApp(),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

class NotificationsApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  //static FlutterBackgroundService service = FlutterBackgroundService();
  const NotificationsApp({Key? key}) : super(key: key);

  @override
  State<NotificationsApp> createState() => _NotificationsAppState();
}

class _NotificationsAppState extends State<NotificationsApp> with WidgetsBindingObserver {
  var prefs = 1;

  //late final AppLifecycleListener _listener;
  //final List<String> _states = <String>[];
  //late AppLifecycleState? _state;
  //SendPort? _sendPort;

  //bool _inForeground = true;
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initAlarmHistoryList();
    //NotificationHelper.initializeService();
    //WidgetsBinding.instance.addObserver(this);
    super.initState();
    /* _state = SchedulerBinding.instance.lifecycleState;
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
    ); */
    /*SharedPreferences.getInstance().then((val){
      val.setBool("appRunInBackground", false);
    });*/
    /* if (_state != null) {
      _states.add(_state!.name);
    } */
  }

  @override
  /*void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint("&&&  didChangeAppLifecycleState");

    _sendPort ??= IsolateNameServer.lookupPortByName('appState');
    switch(state){
      case AppLifecycleState.resumed:
        setState(() {
          _inForeground = true;
        });
        debugPrint("&&&&&&&&&&&&&&&  AppLifecycleState.resumed");
        break;
      case AppLifecycleState.paused:
        setState(() {
          _inForeground = false;
        });
        debugPrint("&&&&&&&&&&&&&&&  AppLifecycleState.paused");
        break;
      case AppLifecycleState.inactive:
        setState(() {
          _inForeground = true;
        });
        debugPrint("&&&&&&&&&&&&&&&  AppLifecycleState.inactive");
        break;
      case AppLifecycleState.detached:
        setState(() {
          _inForeground = false;
        });
        debugPrint("&&&&&&&&&&&&&&&&  AppLifecycleState.detached");
        break;
      default:
        break;
    }
  } */

  /*Future<AppExitResponse> _onExitRequested() async {
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
  } */

  @override
  void dispose() {
    debugPrint("main.dart - dispose");
    //_listener.dispose();
    //WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /*Future<void> _handleTransition(String name) async {
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
  } */

  /*void _handleStateChange(AppLifecycleState state) {
    setState(() {
      _state = state;
    });
  } */

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

    debugPrint("build main.dart");
    return GetMaterialApp(home: FirstScreen.base());
  }
}
