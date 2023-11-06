import 'dart:convert';

class Alarm {
  String? sensorAddress;
  int? t;
  int? hiAlarm;
  int? loAlarm;

  Alarm({this.sensorAddress, this.t, this.hiAlarm, this.loAlarm});

  Map<String, dynamic> toJson() {
    return {
      "sensor_address": sensorAddress,
      "t": t,
      "hi_alarm": hiAlarm,
      "lo_alarm": loAlarm
    };
  }


  static List<Alarm> getAlarmList(Map<String, dynamic> json) {
    List<Alarm> alarmList = [];
    for (String key in json.keys) {
//print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
//print("value:  $value");
        if (key.isNotEmpty) {
          int t = 0;
          int hiAlarm = 0;
          int loAlarm = 0;
          for (String key1 in value.keys) {
            if (key1 != null) {
              value[key1];
              int value1 = value[key1];
//print("key1: $key1, value1: $value1");
              if (key1 == "t") {
                t = value1;
              }
              if (key1 == "hi_alarm") {
                hiAlarm = value1;
              }
              if (key1 == "lo_alarm") {
                loAlarm = value1;
              }
            }
          }
//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          Alarm alarm = Alarm(
              sensorAddress: key, t: t, hiAlarm: hiAlarm, loAlarm: loAlarm);
          alarmList.add(alarm);
        }
      }
    }
    return alarmList;
  }
}
