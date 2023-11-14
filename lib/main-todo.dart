import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzl;

import 'api/notification_helper.dart';
import 'model/alarm.dart';
import 'mqtt/MQTTConnectionManager.dart';
import 'mqtt/state/MQTTAppState.dart';
import 'pages/first_screen.dart';
import 'util/app_preference_util.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  tzl.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();

  runApp(
    const NotificationsApp(),
  );
  //ApiService.login("test", "Test1234");
}

class NotificationsApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const NotificationsApp({Key? key}) : super(key: key);

  @override
  State<NotificationsApp> createState() => _NotificationsAppState();
}

class _NotificationsAppState extends State<NotificationsApp> {
  var prefs = 1;

  late MQTTConnectionManager manager;

  late MQTTAppState currentAppState;

  @override
  void initState() {
    // ce shared preferences se nimajo objekta za alarme, ustvari novega
    initAlarmHistoryList();
    NotificationHelper.initializeService();
    super.initState();
  }

  Future<void> initAlarmHistoryList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey("alarm_list_mqtt")) {
      List<Alarm> alarmList = [];
      String alarmListData = json.encode(alarmList);
      json.decode(alarmListData);
      preferences.setString("alarm_list_mqtt", alarmListData);
    }
    preferences.get("alarm_list_mqtt");
  }

  Future<void> setCurrentAppState(appState) async {
    currentAppState = appState;
  }

  void sharedData() async {
    SharedPreferences.getInstance().then((prefValue) => setState(() {
          prefValue.setString("test", "test1");
        }));
  }

  @override
  Widget build(BuildContext context) {
    //SharedPreferences.getInstance().then((prefValue) => debugPrint(this));

    debugPrint("00000000000 main.dart build");
    bool loggedIn = true;

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<MQTTAppState>(create: (_) => MQTTAppState()),
        ],
        builder: (context, child) => Builder(builder: (context) {
              final MQTTAppState appState =
                  Provider.of<MQTTAppState>(context, listen: false);
              debugPrint("build main.dart");
              setCurrentAppState(appState);
              return MaterialApp(home: FutureBuilder(
                  //future: loggedIn ?? _initializeConnection(appState),
                  builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasError) {
                    return ErrorWidget(Exception(
                        'Error occured when fetching data from database'));
                  } else if (!snapshot.hasData) {
                    debugPrint("snapshot:: $snapshot");
                    return const Center(child: Text('Data is empty!'));
                  } else {
                    return FirstScreen(appState, manager);
                  }
                  // }
                }
              }));
            }));
  }
}
