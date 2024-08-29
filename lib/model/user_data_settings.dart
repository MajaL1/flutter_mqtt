import 'dart:convert';

class UserDataSettings {
  String? deviceName;
  String? sensorAddress;
  String? friendlyName;
  DateTime? ts;

  int? t;
  int? typ;
  int? hiAlarm;
  int? loAlarm;
  int? u;
  String? editableSetting;
  int? rw;

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
      this.ts,
      this.rw});

  /*String ? _editableSetting;
  String ? get editableSetting => _editableSetting;

  set editableSetting(String ? value) {
    if (value!.isNotEmpty) {
      _editableSetting = value;
    }
  } */

  factory UserDataSettings.fromJson(Map<String, dynamic> parsedJson) {
    return UserDataSettings(
      deviceName: parsedJson['device_name'].toString(),
      sensorAddress: parsedJson['sensor_address'].toString(),
      friendlyName: parsedJson['friendlyName'].toString(),
      editableSetting: parsedJson['editableSetting'].toString(),
      u: parsedJson['u'],
      t: parsedJson['a'],
      typ: parsedJson['typ'],
      hiAlarm: parsedJson['hi_alarm'],
      loAlarm: parsedJson['lo_alarm'],
      // ts: "ts" == null ? null : ts?.toIso8601String()
    );
  }

  Map<String, dynamic> toJson() {
    //debugPrint("ToJson:: ");
    return {
      "device_name": deviceName,
      "friendlyName": friendlyName,
      "sensor_address": sensorAddress,
      "t": t,
      "typ": typ,
      "u": u,
      "hi_alarm": hiAlarm,
      "lo_alarm": loAlarm,
      "ts": ts == null ? null : ts?.toIso8601String()
    };
  }

  @override
  String toString() {
    return 'deviceName: ${deviceName}, rw: ${rw}, SensorAddress: ${sensorAddress}, friendlyName: ${friendlyName}, hiAlarm: ${hiAlarm}, loAlarm: ${loAlarm}., ts: ${ts}';
  }

  static List<UserDataSettings> getUserDataSettingsAlarm(List json) {
    List<UserDataSettings> userSettingsList = [];
    for (Map key in json) {
      //debugPrint("a-- json key $key");
      int t = 0;
      int typ = 0;
      int hiAlarm = 0;
      int loAlarm = 0;
      int u = 0;
      String friendlyName = "";
      String deviceName = "";
      String sensorAddress = "";
      DateTime? ts = null;

      if (key.isNotEmpty) {
        if (key == "ts") {
          continue;
        } else {
          for (var item in key.keys) {
            if (item != null) {
              if (item == "sensor_address") {
                sensorAddress = key[item];
              }
              if (item == "device_name") {
                deviceName = key[item];
              }
              if (item == "t") {
                t = key[item];
              }
              if (item == "typ") {
                t = key[item];
              }
              if (item == "hi_alarm") {
                hiAlarm = key[item];
              }
              if (item == "lo_alarm") {
                loAlarm = key[item];
              }
              if (item == "u") {
                u = key[item];
              }
              if (item == "ts") {
                // ts = DateTime.fromMillisecondsSinceEpoch(value1 * 1000);
              }
            }
          }
          UserDataSettings userDataSet = UserDataSettings(
            deviceName: deviceName,
            sensorAddress: sensorAddress,
            friendlyName: friendlyName,
            //editableSetting: editableSetting,
            hiAlarm: hiAlarm,
            loAlarm: loAlarm,
            typ: typ,
            t: t,
            u: u,
            ts: ts,
          );
          userSettingsList.add(userDataSet);
        }
        // debugPrint(
        //   "t, deviceName, friendlyNAme, ... $deviceName, $friendlyName");
      }
    }
    return userSettingsList;
  }

  static List<UserDataSettings> getUserDataSettings(Map<String, dynamic> json) {
    List<UserDataSettings> userSettingsList = [];
    for (String key in json.keys) {
      //print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
        //print("value:  $value");
        if (key.isNotEmpty) {
          if (key == "ts") {
            continue;
          }
          int t = 0;
          int typ = 0;
          int hiAlarm = 0;
          int loAlarm = 0;
          int u = 0;
          String friendlyName = "";
          String deviceName = "";
          DateTime? ts = null;

          for (String key1 in value.keys) {
            if (key1 != null) {
              value[key1];
              var value1 = value[key1];
              //print("key1: $key1, value1: $value1");
              if (key1 == "t") {
                t = value1;
              }
              if (key1 == "device_name") {
                deviceName = value1;
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
              if (key1 == "ts") {
                ts = DateTime.fromMillisecondsSinceEpoch(value1 * 1000);
              }
            }
          }
          //print("Creating userSettings: $key, $t, $hiAlarm, $loAlarm");
          UserDataSettings userSettings = UserDataSettings(
              friendlyName: friendlyName,
              deviceName: deviceName,
              sensorAddress: key,
              t: t,
              typ: typ,
              hiAlarm: hiAlarm,
              loAlarm: loAlarm,
              u: u,
              ts: ts);
          userSettingsList.add(userSettings);
        }
      }
    }
    return userSettingsList;
  }

// tale
  static List<UserDataSettings> getUserDataSettingsList(String? mqttSettings) {
    List<UserDataSettings> userDataSettingsList = [];
    //debugPrint("777777777 parse $mqttSettings");
    var jsonMap;
    // Todo: tole daj v novo metodo
    //jsonDecode(mqttSettings!);
    // end Todo
    var jsonMap1 = json.decode(mqttSettings!);
    jsonMap = jsonMap1;
    // jsonMap = jsonDecode(mqttSettings.toString()!);

    if (jsonMap is List) {}

    for (var key in jsonMap.keys) {
      String deviceName = "";
      String sensorAddress = "";
      String friendlyName = "";
      DateTime? ts;
      String editableSetting = "";
      int t = 0;
      int u = 0;
      int typ = 0;
      int hiAlarm = 0;
      int loAlarm = 0;

      sensorAddress = key.toString();

      if (key == "ts") {
        continue;
      }
      Map map = jsonMap[key];

      List<UserDataSettings> topicDataList = [];
      for (var key1 in map.keys) {
        if (key1 != null) {
          map[key1];
          var value1 = map[key1];
          //print("key1: $key1, value1: $value1");
          if (key1 == "t") {
            t = value1;
          }
          if (key1 == "friendlyName") {
            friendlyName = value1.toString();
          }
          if (key1 == "device_name") {
            deviceName = value1.toString();
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
          if (key1 == "ts") {
            ts = DateTime.fromMillisecondsSinceEpoch(value1 * 1000);
          }
        }
      }
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
        ts: ts,
      );
      userDataSettingsList.add(userDataSet);
    }
    //debugPrint("### $userDataSettingsList");
    return userDataSettingsList;
  }
}
