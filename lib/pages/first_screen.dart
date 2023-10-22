import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mqtt_test/mqtt/MQTTConnectionManager.dart';
import 'package:mqtt_test/util/app_preference_util.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import '../mqtt/state/MQTTAppState.dart';
import '../util/mqtt_connect_util.dart';
import 'login_form.dart';
import 'alarm_history.dart';

class FirstScreen extends StatefulWidget {
  //final  sharedPref;
  MQTTConnectionManager? manager;

  /* FirstScreen(MQTTConnectionManager manager, {Key? key}) : super(key: key) {
    this.manager;
  } */

  var username = SharedPrefs().username;
  var token = SharedPrefs().token;

  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  late MQTTAppState currentAppState;

  @override
  initState() {
    super.initState();
    // ignore: avoid_print
    print("-- firstScreen initstate");
    initalizeConnection();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("token: $SharedPrefs().token, ${SharedPrefs().token == null}");

    // return Scaffold(
    return ChangeNotifierProvider<MQTTAppState>(
        create: (_) => MQTTAppState(),
        child: FirstScreen(),
        builder: (context, child) {
          // No longer throws
          //return Text(context.watch<MQTTView>().toString());
          final MQTTAppState appState = Provider.of<MQTTAppState>(context);

          currentAppState = appState;
          return SharedPrefs().token.isEmpty ? LoginForm() : MQTTView();
        });
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
        currentAppState.getAppConnectionState) {
      await _configureAndConnect();
    }
  }

  // Initalize user data and connect
  Future<void> initalizeConnection() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final storage = const FlutterSecureStorage();

    // ***************** connect to broker ****************
    User user = await MqttConnectUtil.readUserData();
    MqttConnectUtil.getBrokerAddressList(user);
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
  }

  // Connect to brokers
  Future<void> _configureAndConnect() async {
    //final MQTTAppState appState = Provider.of<MQTTAppState>(context);

    // TODO: Use UUID
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    MQTTConnectionManager manager = MQTTConnectionManager(
        host: 'test.navis-livedata.com', //_hostTextController.text,
        topic: 'c45bbe821261/settings'
            '', //_topicTextController.text,
        identifier: osPrefix,
        state: currentAppState);
    manager.initializeMQTTClient();
    await manager.connect();

    if (MQTTAppConnectionState.connected ==
        currentAppState.getAppConnectionState) {
      String t = await currentAppState.getHistoryText;

      print("****************** $t");
    }

    // pridobivanje najprej settingov, samo za topic (naprave) -dodaj v objekt UserSettings
    if (MQTTAppConnectionState.connected ==
        currentAppState.getAppConnectionState) {
      //MQTTConnectionManager._publishMessage(topic, text);
      String t = await currentAppState.getHistoryText;

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
