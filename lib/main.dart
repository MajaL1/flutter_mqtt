import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:mqtt_test/util/mqtt_connect_util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'model/notification_message.dart';
import 'model/user.dart';
import 'mqtt/MQTTConnectionManager.dart';
import 'mqtt/state/MQTTAppState.dart';
import 'util/app_preference_util.dart';
import 'pages/first_screen.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/standalone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  await initializeService();
  runApp(
    const NotificationsApp(),
  );
}

// ToDo: zamenjaj klic za awsome service
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

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();

  if (Platform.isIOS || Platform.isAndroid) {
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
      isForegroundMode: false,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'TEST NOTIFICATIONS',
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
  tzl.initializeTimeZones();
  service.startService();
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

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  /******** tole sem probala in prikaze vse razen prvega*******/
  tzl.initializeTimeZones();
  final slovenia = tz.getLocation('Europe/London');
  final localizedDt = tz.TZDateTime.from(DateTime.now(), slovenia);

  List<NotificationMessage> notificationList = await ApiService.getNotifMess();
  for (var i = 0; i < notificationList.length; i++) {
    debugPrint("showing notification: ${notificationList[i].title}. $i");

    await flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        "A Notification From My App ",
        "$notificationList[i].title",
        tz.TZDateTime.now(slovenia).add(const Duration(minutes: 5)),
        //localizedDt,//tz.initializeTimeZones(),//.add(const Duration(days: 3)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
          "1",
          "11",
        )),
        //androidScheduleMode: AndroidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
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

  late MQTTConnectionManager? manager;

  late MQTTAppState? currentAppState;

  @override
  void initState() {
    super.initState();
    //initalizeConnection();

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
    String channelKey = "alerts1Main";
    String channelName = "Alerts1Main";
    String channelDescription = "Notification tests as alerts1Main";

    // NotificationController.initializeLocalNotifications(
    //    channelKey, channelDescription, channelName);
    // SharedPreferences prefs =  getPrefs() ;

    // home: LoginForm(), //
    return MultiProvider(
        providers: [
          //Provider for theme
          ChangeNotifierProvider<MQTTAppState>(create: (_) => MQTTAppState()),
        ],
        builder: (context, child) => Builder(builder: (context) {
          final MQTTAppState appState =  Provider.of<MQTTAppState>(context);
          setCurrentAppState(appState);
          MQTTConnectionManager manager = MQTTConnectionManager(
              host: 'test.navis-livedata.com', //_hostTextController.text,
              topic: 'c45bbe821261/settings'
                  '', //_topicTextController.text,
              identifier: "Android",
              state: appState);

          return MaterialApp(
              home: FutureBuilder(
              future: initalizeConnection(appState),
              builder: (context, snapshot) {
                //if (currentAppState != null) {
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
              }}));
         /* return MaterialApp(
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                initialRoute: '/',
                home: FirstScreen(appState, manager),
              ); */
            }));
  }

  Future<void> connectToBroker(List<String> brokerAddressList) async {
    for (var brokerAddress in brokerAddressList) {
      // ali vsebuje alarme
      if (brokerAddress.contains('/alarm')) {
      } else if (brokerAddress.contains('/settings')) {
      } else if (brokerAddress.contains('/data')) {}
      debugPrint("brokerAddress: $brokerAddress");
    }
    if (MQTTAppConnectionState.disconnected ==
        currentAppState?.getAppConnectionState) {
      await _configureAndConnect(currentAppState);
    }
  }

  // Initalize user data and connect
  Future<User> initalizeConnection(currentAppState) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final storage = const FlutterSecureStorage();

    // ***************** connect to broker ****************
    User user = await MqttConnectUtil.readUserData();
    MqttConnectUtil.initalizeUserPrefs(user);
    List<String> brokerAddressList = MqttConnectUtil.getBrokerAddressList(user);
    connectToBroker(brokerAddressList);
    // *****************************************************

    debugPrint("preferences ${sharedPreferences.toString()}");
    await storage.write(key: 'jwt', value: 'jwtTokenTest');
    // todo: inicializiraj Mqtt service za settingse
//storage.containsKey(key: "jwt")
    String? readToken = await storage.read(key: "token");
    print("token from flutter secure storage: $readToken");
    return user;
  }

  // Connect to brokers
  Future<void> _configureAndConnect(currentAppState) async {

    // TODO: Use UUID
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    manager = MQTTConnectionManager(
        host: 'test.navis-livedata.com', //_hostTextController.text,
        topic: 'c45bbe821261/settings'
            '', //_topicTextController.text,
        identifier: osPrefix,
        state: currentAppState);
    manager?.initializeMQTTClient();
    await manager?.connect();

    if (MQTTAppConnectionState.connected ==
        currentAppState?.getAppConnectionState) {
      String ? t = await currentAppState?.getHistoryText;

      print("****************** $t");
    }

    // pridobivanje najprej settingov, samo za topic (naprave) -dodaj v objekt UserSettings
    if (MQTTAppConnectionState.connected ==
        currentAppState?.getAppConnectionState) {
      //MQTTConnectionManager._publishMessage(topic, text);
      String ? t = await currentAppState?.getHistoryText;

      print("****************** $t");
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.get("settings_mqtt").toString();
    String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
    print("****************** data $data");
    Map<String, dynamic> jsonMap = json.decode(decodeMessage);

    // vrne Listo UserSettingsov iz mqtt 'sensorId/alarm'
    // List<UserDataSettings> userSettings = UserDataSettings().getUserDataSettings(jsonMap);

    // debugPrint("UserSettings from JSON: $userSettings");

    // napolnimo nov objekt UserSettings
    // pridobivanje sporocil
    //ce je povezava connected, potem iniciramo zahtevo za pridobivanje alarmov
    //if(MQTTAppConnectionState.connected == true){
    //this.publish('topic');
    //}
  }
}
