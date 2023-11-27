
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../model/user.dart';
import '../mqtt/MQTTConnectionManager.dart';
import '../mqtt/state/MQTTAppState.dart';

class MqttConnectUtil {
  static Future<User> readUserData() async {
    User user = await ApiService.getUserData();
    return user;
  }

  // Connectr to brokers
  Future<void> _configureAndConnect(MQTTAppState currentAppState) async {
    //final MQTTAppState appState = Provider.of<MQTTAppState>(context);

    // TODO: Use UUID
    String osPrefix = 'Flutter_iOS';
   /* if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    } */
    MQTTConnectionManager manager = MQTTConnectionManager(
        host: 'test.navis-livedata.com', //_hostTextController.text,
        topic: 'c45bbe821261/settings'
            '', //_topicTextController.text,
        identifier: osPrefix,
        state: currentAppState
    );
    manager.initializeMQTTClient();
    await manager.connect();

    var currentAppState;
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

  static void initalizeUserPrefs(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("username", user.username);
    sharedPreferences.setString("email", user.email ?? "");
    sharedPreferences.setString("mqtt_pass", user.mqtt_pass);
  }

  static List<String> getBrokerAddressList(User user) {
    List<String> brokerAddressList = [];
    var topicForUser = user.topic.topicList;
    debugPrint("user.topic.sensorName : ${user.topic.sensorName}");
    String deviceName = user.topic.sensorName;
    debugPrint("deviceName : $deviceName");

    for (var topic in topicForUser) {
      String topicName = topic.name;
      debugPrint("==== name:  ${topic.name}");
      debugPrint("==== rw:  ${topic.rw}");

      brokerAddressList.add(deviceName + "/" + topicName);
    }
    return brokerAddressList;
  }
}
