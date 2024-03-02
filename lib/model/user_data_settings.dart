import 'dart:convert';

import 'package:flutter/cupertino.dart';

class UserDataSettings {
  String? deviceName;
  String? sensorAddress;
  String? friendlyName;
  String? data;

  int? t;
  int? typ;
  int? hiAlarm;
  int? loAlarm;
  int? u;
  String? editableSetting;

  UserDataSettings(
      {this.deviceName,
      this.sensorAddress,
      this.t,
      this.typ,
      this.hiAlarm,
      this.loAlarm,
      this.u,
      this.editableSetting,
      this.friendlyName,
      this.data});

  /*String ? _editableSetting;
  String ? get editableSetting => _editableSetting;

  set editableSetting(String ? value) {
    if (value!.isNotEmpty) {
      _editableSetting = value;
    }
  } */

  Map<String, dynamic> toJson() {
    return {
      "device_name": deviceName,
      "friendlyName": friendlyName,
      "sensor_address": sensorAddress,
      "t": t,
      "typ": typ,
      "u": u,
      "hi_alarm": hiAlarm,
      "lo_alarm": loAlarm,
      "data": data
    };
  }

  @override
  String toString() {
    return 'deviceName: ${deviceName}, SensorAddress: ${sensorAddress}, friendlyName: ${friendlyName}, hiAlarm: ${hiAlarm}, loAlarm: ${loAlarm}.';
  }

  static List<UserDataSettings> getUserDataSettings(Map<String, dynamic> json) {
    List<UserDataSettings> userSettingsList = [];
    for (String key in json.keys) {
      //print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
        //print("value:  $value");
        if (key.isNotEmpty) {
          int t = 0;
          int typ = 0;
          int hiAlarm = 0;
          int loAlarm = 0;
          int u = 0;
          String data = "";
          String friendlyName = "";

          for (String key1 in value.keys) {
            if (key1 != null) {
              value[key1];
              int value1 = value[key1];
              //print("key1: $key1, value1: $value1");
              if (key1 == "t") {
                t = value1;
              }
              if (key1 == "friendlyName") {
                friendlyName = value1.toString();
              }
              if (key1 == "hi_alarm") {
                hiAlarm = value1;
              }
              if (key1 == "lo_alarm") {
                loAlarm = value1;
              }
              if (key1 == "typ") {
                typ = value1;
              }
              if (key1 == "u") {
                u = value1;
              }
              if (key1 == "data") {
                data = value1.toString();
              }
            }
          }
          //print("Creating userSettings: $key, $t, $hiAlarm, $loAlarm");
          UserDataSettings userSettings = UserDataSettings(
              friendlyName: friendlyName,
              sensorAddress: key,
              t: t,
              typ: typ,
              hiAlarm: hiAlarm,
              loAlarm: loAlarm,
              u: u,
              data: data);
          userSettingsList.add(userSettings);
        }
      }
    }
    return userSettingsList;
  }

  static List<UserDataSettings> getUserDataSettingsList(
      String? mqttSettings, bool isDecode) {
    List<UserDataSettings> userDataSettingsList = [];
    debugPrint("### $mqttSettings");
    Iterable jsonMap;
    if (isDecode) {
      jsonMap = jsonDecode(mqttSettings.toString()!);
    } else {
      debugPrint("8888888888 parse: $mqttSettings");
      var str = json.decode(mqttSettings!);
      //jsonMap = str.runes.toList();
      //jsonMap = jsonDecode(mqttSettings.toString()!);
      jsonMap = json.decode(str);
    }
    for (var item in jsonMap) {
      String deviceName = item["device_name"];
      String sensorAddress = item["sensor_address"];
      String friendlyName = item["friendlyName"] ?? "";
      String data = item["data"] ?? "";
      String editableSetting = item["editableSetting"] ?? "";
      int t = item["t"];
      int u = item["u"];
      int typ = item["typ"] ?? 0;
      int hiAlarm = item["hi_alarm"] ?? 0;
      int loAlarm = item["lo_alarm"] ?? 0;

      UserDataSettings userDataSet = UserDataSettings(
        deviceName: deviceName,
        sensorAddress: sensorAddress,
        friendlyName: friendlyName,
        editableSetting: editableSetting,
        hiAlarm: hiAlarm,
        loAlarm: loAlarm,
        typ: typ,
        t: t,
        u: u,
        data: data,
      );
      userDataSettingsList.add(userDataSet);
    }
    debugPrint("### $userDataSettingsList");
    return userDataSettingsList;
  }
}
