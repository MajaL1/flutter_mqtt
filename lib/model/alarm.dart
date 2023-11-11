import 'dart:convert';

class Alarm {
  String? sensorAddress;
  int? typ;
  int? v;
  int? hiAlarm;
  int? loAlarm;
  DateTime? ts;

  Alarm(
      {this.sensorAddress,
      this.typ,
      this.v,
      this.hiAlarm,
      this.loAlarm,
      this.ts});

  Map<String, dynamic> toJson() {
    return {
      "sensor_address": sensorAddress,
      "typ": typ,
      "v": v,
      "hi_alarm": hiAlarm,
      "lo_alarm": loAlarm,
      "ts": ts
    };
  }

  static Alarm ? decodeAlarm(Map<String, dynamic> json) {
    for (String key in json.keys) {
//print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
//print("value:  $value");
        if (key.isNotEmpty) {
          int typ = 0;
          int hiAlarm = 0;
          int loAlarm = 0;
          int v = 0;
          int ts = 0;
          for (String key1 in value.keys) {
            if (key1 != null) {
              value[key1];
              int value1 = value[key1];
//print("key1: $key1, value1: $value1");
              if (key1 == "typ") {
                typ = value1;
              }
              if (key1 == "v") {
                v = value1;
              }
              if (key1 == "hi_alarm") {
                hiAlarm = value1;
              }
              if (key1 == "lo_alarm") {
                loAlarm = value1;
              }
              if (key1 == "dt") {
                hiAlarm = value1;
              }
            }
          }
//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          Alarm alarm = Alarm(
              sensorAddress: key,
              typ: typ,
              v: v,
              hiAlarm: hiAlarm,
              loAlarm: loAlarm);
          return alarm;
        }
      }throw Exception(["Cannot decode alarm"]);
    }
  }

  static List<Alarm> getAlarmList(Map<String, dynamic> json) {
    List<Alarm> alarmList = [];
    for (String key in json.keys) {
//print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
//print("value:  $value");
        if (key.isNotEmpty) {
          int typ = 0;
          int hiAlarm = 0;
          int loAlarm = 0;
          int v = 0;
          int ts = 0;
          for (String key1 in value.keys) {
            if (key1 != null) {
              value[key1];
              int value1 = value[key1];
//print("key1: $key1, value1: $value1");
              if (key1 == "typ") {
                typ = value1;
              }
              if (key1 == "v") {
                v = value1;
              }
              if (key1 == "hi_alarm") {
                hiAlarm = value1;
              }
              if (key1 == "lo_alarm") {
                loAlarm = value1;
              }
              if (key1 == "dt") {
                hiAlarm = value1;
              }
            }
          }
//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          Alarm alarm = Alarm(
              sensorAddress: key,
              typ: typ,
              v: v,
              hiAlarm: hiAlarm,
              loAlarm: loAlarm);
          alarmList.add(alarm);
        }
      }
    }
    return alarmList;
  }
}
