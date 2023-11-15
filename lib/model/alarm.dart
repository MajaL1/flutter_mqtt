class Alarm {
  String? sensorAddress;
  int? typ;
  int? v;
  int? hiAlarm;
  int? loAlarm;
  DateTime? ts;
  int? lb;
  int? r;
  int? bv;
  int? l;
  int? b;
  int? t;

  Alarm(
      {this.sensorAddress,
      this.typ,
      this.v,
      this.hiAlarm,
      this.loAlarm,
      this.ts,
      this.lb,
      this.bv,
      this.r,
      this.b,
      this.l,
      this.t});

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

  static Alarm? decodeAlarm(Map<String, dynamic> json) {
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
          int lb = 0;
          int r = 0;
          int bv = 0;
          int b = 0;
          int ts = 0;
          int t = 0;
          int l = 0;


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
              if (key1 == "ts") {
                ts = value1;
              }
              if (key1 == "lb") {
                lb = value1;
              }
              if (key1 == "b") {
                b = value1;
              }
              if (key1 == "r") {
                r = value1;
              }
              if (key1 == "bv") {
                bv = value1;
              }
              if (key1 == "t") {
                t = value1;
              }
              if (key1 == "l") {
                l = value1;
              }
            }
          }
//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          Alarm alarm = Alarm(
              sensorAddress: key,
              typ: typ,
              v: v,
              hiAlarm: hiAlarm,
              loAlarm: loAlarm,
              //ts: ts,
              lb: lb,
              bv: bv,
              r: r,
              l: l,
              b: b,
              t: t);
          return alarm;
        }
      }
      throw Exception(["Cannot decode alarm"]);
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
          int lb = 0;
          int r = 0;
          int l = 0;
          int bv = 0;
          int b = 0;
          int t = 0;

          String valueStr = "";

          for (String key1 in value.keys) {
            if (key1 != null) {
              value[key1];
              int valueInt;
              if (value[key1] is String) {
                valueStr = value[key1];
              } else {
                if (value[key1] != null) {
                  valueInt = value[key1];
                } else {
                  valueInt = 0;
                }
//print("key1: $key1, value1: $value1");
                if (key1 == "typ") {
                  typ = valueInt;
                }
                if (key1 == "v") {
                  v = valueInt;
                }
                if (key1 == "hi_alarm") {
                  hiAlarm = valueInt;
                }
                if (key1 == "lo_alarm") {
                  loAlarm = valueInt;
                }
                if (key1 == "ts") {
                  ts = valueInt;
                }
                if (key1 == "lb") {
                  lb = valueInt;
                }
                if (key1 == "t") {
                  t = valueInt;
                }
                if (key1 == "r") {
                  r = valueInt;
                }
                if (key1 == "bv") {
                  bv = valueInt;
                }
                if (key1 == "l") {
                  l = valueInt;
                }
                if (key1 == "b") {
                  b = valueInt;
                }

                /* if (key1 == "dt") {
                hiAlarm = value1;
              } */
              }
            }
          }
//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          Alarm alarm = Alarm(
              sensorAddress: key,
              typ: typ,
              v: v,
              hiAlarm: hiAlarm,
              loAlarm: loAlarm,
              //ts: ts,
              lb: lb,
              bv: bv,
              r: r,
              b: b,
              l: l,
              t: t);
          alarmList.add(alarm);
        }
      }
    }
    return alarmList;
  }
}
