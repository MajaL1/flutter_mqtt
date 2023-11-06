import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mqtt_test/util/mqtt_connect_util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/notification_helper.dart';
import 'model/user.dart';
import 'mqtt/MQTTConnectionManager.dart';
import 'mqtt/state/MQTTAppState.dart';
import 'util/app_preference_util.dart';
import 'pages/first_screen.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/standalone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  // init service for notifications
  await NotificationHelper.initializeService();

  //mqtt builder
  //final MQTTAppState appState = Provider.of<MQTTAppState>(context);


  runApp(
   /* ChangeNotifierProvider<MQTTAppState>(
      create: (BuildContext context) => MQTTAppState(),
      child: const MaterialApp(
        home: NotificationsApp(),
      ),
    ), */
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
    super.initState();
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

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<MQTTAppState>(create: (_) => MQTTAppState()),
        ],
        builder: (context, child) => Builder(builder: (context) {
              final MQTTAppState appState = Provider.of<MQTTAppState>(context, listen: false);
              debugPrint("build main.dart");
                setCurrentAppState(appState);
                  return MaterialApp(
                  home: FutureBuilder(
                      future: initializeConnection(appState),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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

  Future<void> connectToBroker(List<String> brokerAddressList) async {
    for (var brokerAddress in brokerAddressList) {
      if (brokerAddress.contains('/alarm')) {
      } else if (brokerAddress.contains('/settings')) {
      } else if (brokerAddress.contains('/data')) {}
      debugPrint("brokerAddress: $brokerAddress");
    }
    if (MQTTAppConnectionState.disconnected ==
        currentAppState.getAppConnectionState) {
        await configureAndConnect(currentAppState);
    }
  }

  // Initialize user data and connect
  Future<User> initializeConnection(currentAppState) async {
    debugPrint("calling initializeConnection in main.dart");

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    const storage = FlutterSecureStorage();

    // ***************** connect to broker ****************
    User user = await MqttConnectUtil.readUserData();
    MqttConnectUtil.initalizeUserPrefs(user);
    List<String> brokerAddressList = MqttConnectUtil.getBrokerAddressList(user);
    connectToBroker(brokerAddressList);
    // *****************************************************

    debugPrint("preferences ${sharedPreferences.toString()}");
    await storage.write(key: 'jwt', value: 'jwtTokenTest');
//storage.containsKey(key: "jwt")
    String? readToken = await storage.read(key: "token");
    debugPrint("token from flutter secure storage: $readToken");
    return user;
  }

  // Connect to brokers
  Future<void> configureAndConnect(currentAppState) async {
    // TODO: Use UUID
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    manager = MQTTConnectionManager(
        host: 'test.navis-livedata.com',
        //_hostTextController.text,
        topic1: 'c45bbe821261/settings'
            '',
        //_topicTextController.text,
       // topic2:
        topic2: 'c45bbe821261/data',
        identifier: osPrefix,
        state: currentAppState);
        //manager.initializeMQTTClient();
        //await manager.connect();


    // pridobivanje najprej settingov, samo za topic (naprave) -dodaj v object UserSettings
    if (MQTTAppConnectionState.connected ==
        currentAppState?.getAppConnectionState) {
      //MQTTConnectionManager._publishMessage(topic, text);
      String? t = await currentAppState?.getHistoryText;

      debugPrint("****************** $t");
    }

   /* SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.get("settings_mqtt").toString();

    String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
    debugPrint("****************** data $data");

    */
    //Map<String, dynamic> jsonMap = json.decode(decodeMessage);

    // vrne Listo UserSettingsov iz mqtt 'sensorId/alarm'
    // List<UserDataSettings> userSettings = UserDataSettings().getUserDataSettings(jsonMap);

    // debugPrint("UserSettings from JSON: $userSettings");

    // napolnimo nov object UserSettings
    // pridobivanje sporocil
    //ce je povezava connected, potem iniciramo zahtevo za pridobivanje alarmov
    //if(MQTTAppConnectionState.connected == true){
    //this.publish('topic');
    //}
  }
}
