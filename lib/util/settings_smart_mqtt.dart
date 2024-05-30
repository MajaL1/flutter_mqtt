import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/notification_helper.dart';
import '../model/alarm.dart';
import '../model/constants.dart';
import '../model/data.dart';
import '../mqtt/MQTTAppState.dart';
import '../widgets/show_alarm_time_settings.dart';

class SettingsSmartMqtt extends ChangeNotifier {

  Data ?newMqttData;


  static final SettingsSmartMqtt _instance = SettingsSmartMqtt._internal();

  SettingsSmartMqtt._internal();

  static SettingsSmartMqtt get instance => _instance;
  String newUserSettings = "";


  factory SettingsSmartMqtt() {
    debugPrint("SETTINGS_SMARTMQTT");
    return _instance;
  }


  Future<void> settingsProcessor(String decodeMessage, String topicName,
      SharedPreferences preferences) async {
    debugPrint("___________________________________________________");
    debugPrint("from topic $topicName");
    debugPrint("__________ $decodeMessage");
    debugPrint("___________________________________________________");

    //preverimo, ker je prvo sporocilo
    // po shranjevanju oblike {"135":{"hi_alarm":111}}
    // in tega izpustimo
    if ((decodeMessage.contains("v") ||
        decodeMessage.contains("typ") ||
        decodeMessage.contains("u"))) {
      // debugPrint("got new settings");
      // ali novi settingi niso enaki prejsnim
      // ali ce so v zacetku prazni
      if (newUserSettings.compareTo(decodeMessage) != 0 &&
          decodeMessage.isNotEmpty) {
        await _parseMqttSettingsForTopic(
            preferences, decodeMessage, topicName);
        //{\"57\":{\"typ\":1,\"u\":0,\"ut\":0,\"hi_alarm\":0,\"ts\":455},\"84\":{\"typ\":1,\"u\":0,\"ut\":0,\"hi_alarm\":0,\"ts\":455}}
      }
    }
  }

  Future<void> _parseMqttSettingsForTopic(SharedPreferences preferences,
      String decodeMessage, String topicName) async {
    debugPrint("new user settings");
    preferences.setString("current_mqtt_settings", decodeMessage);
    // parse trenutno sporocilo
    Map decodeMessageSettings = <String, String>{};
    decodeMessageSettings = json.decode(decodeMessage);
    //debugPrint("AAAAAAAA  decodeMessageSettings: ${decodeMessageSettings}");
    await setDeviceNameToSettings(
        decodeMessageSettings, topicName
        .split("/settings")
        .first);
    //-----
    //String oldUserSettings = newUserSettings;
    Map newSettings = <String, String>{};
    if (newUserSettings.isEmpty) {
      // debugPrint(
      //   "1 AAAAAAAA  newUserSettings.isEmpty:, newUserSettings: ${decodeMessage}");
      newUserSettings = decodeMessage;
      newSettings = json.decode(newUserSettings);
      //debugPrint("1 AAAAAAAA newSettings: ${newSettings}");

      await setDeviceNameToSettings(
          newSettings, topicName
          .split("/settings")
          .first);
      //debugPrint("1 AAAAAAAA2 newSettings: ${newSettings}");

      await setNewUserSettings(newSettings);
      notifyListeners();
      debugPrint("notifying listeners 0.. $newSettings");
    } else if (newUserSettings.isNotEmpty &&
        !newUserSettings.contains(decodeMessage)) {
     // debugPrint(
       //   "2 AAAAAAAA  newUserSettings.isNotEmpty &&!decodeMessage.contains(newUserSettings),");
      //debugPrint("3 AAAAAAAA: decodeMessageSettings ${decodeMessageSettings}");

      //debugPrint("4 AAAAAAAA: newSettings ${newUserSettings}");
      newSettings = json.decode(newUserSettings);

      //  stare settinge za doloceno napravo zamenja za nove
      // ... je concatenate, iz mapa nadomesti key-e z decodemessagesettings
      final concatenatedSettings = {
        ...newSettings,
        ...decodeMessageSettings,
      };
      if (newUserSettings != null || newUserSettings.isNotEmpty) {
        newUserSettings = json.encode(concatenatedSettings);
        debugPrint("notifying listeners.. $newUserSettings");
        preferences.setString("current_mqtt_settings", newUserSettings);
        notifyListeners();
      }

      //print("map: ${concatenatedSettings}");
      //debugPrint("5 AAAAAAAA: concatenatedSettings ${concatenatedSettings}");
    }
  }

  Future<String> getNewUserSettingsList() async {
    // if(newUserSettings != null) {
    //debugPrint(
    //    "1111111111111 new User settings - smart mqtt: $newUserSettings");

    return newUserSettings;
    //}
  }

  Future<void> setNewUserSettings(Map concatenatedSettings) async {
    newUserSettings = json.encode(concatenatedSettings);
    debugPrint("map: ${concatenatedSettings}");
  }

  // iz historija dobi zadnji alarm za napravo in vrne njen datum
  Future<DateTime?> _getLastAlarmDateFromHistory(String? deviceName,
      String? sensorName) async {
    List<Alarm> alarmList = [];

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("alarm_list_mqtt")) {
      String alarmListData = preferences.get("alarm_list_mqtt") as String;
      if (alarmListData.isNotEmpty) {
        List alarmMessageJson = json.decode(alarmListData);
        alarmList = Alarm.getAlarmListFromPreferences(alarmMessageJson);
      }
    }

    /**
     * Todo: najdi zadnji alarm za napravo
     * ***/
    bool found = true;
    DateTime? lastSentAlarm;
    for (Alarm alarm in alarmList) {
      String? alarmDeviceName = alarm.deviceName;
      String? alarmSensorAddress = alarm.sensorAddress;
      // zadnji datum
      if (alarmDeviceName == deviceName && alarmSensorAddress == sensorName) {
        found = true;
        lastSentAlarm = alarm.ts;
        if (lastSentAlarm!.isAfter(alarm.ts!)) {
          lastSentAlarm = alarm.ts;
          break;
        }
      }
    }
  }

  Data? convertMessageToData(String message, String deviceName) {
    String decodeMessage = const Utf8Decoder().convert(message.codeUnits);
    Map<String, dynamic> dataStr = json.decode(decodeMessage);

    Data? data = Data().getData(dataStr);
    // Data data = json.decode(dataStr);
    data?.deviceName = deviceName
        .split("/data")
        .first;

    debugPrint(
        "converting data object...${data?.deviceName}, ${data
            ?.sensorAddress}, ${data?.typ}, ${data?.t}");

    return data;
  }

  Future<void> setDeviceNameToSettings(Map settings, String deviceName) async {
    for (String key in settings.keys) {
      if (settings[key] != null) {
        Map val = settings[key];

        for (String key1 in val.keys) {
          //print("key1: $key1");
        }
        final Map<String, String> deviceNameMap = {"device_name": deviceName};
        val.addAll(deviceNameMap);
      }
    }
  }

  void setDataListToPreferences(Data newData, SharedPreferences preferences) {
    String? dataListStr = preferences.getString("data_mqtt_list");
    List? dataList;

    // zaenkrat dodamo samo eno element na listo
    /*if (dataListStr != null) {
      final jsonResult = jsonDecode(dataListStr!);
      dataList = Data.fromJsonList(jsonResult);
      dataList.add(newData);
    } else { */
    dataList = [];
    dataList.add(newData);
    // }
    String encodedData = json.encode(dataList);
    debugPrint("encodedData:  $encodedData");
    preferences.setString("data_mqtt_list", encodedData);
    debugPrint("setting data_mqtt_list encodedData: $encodedData");
  }
}

