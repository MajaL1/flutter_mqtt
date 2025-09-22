class Alarm {
  String? deviceName;
  String? sensorAddress;
  String? friendlyName;
  int? typ;
  int? v;
  int? u;
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
      this.deviceName,
      this.friendlyName,
      this.typ,
      this.v,
        this.u,
      this.hiAlarm,
      this.loAlarm,
      this.ts,
      this.lb,
      this.bv,
      this.r,
      this.b,
      this.l,
      this.t});


  /*factory Alarm.fromJson(Map<String, dynamic> addjson){
    return Alarm(
        "sensor_address": sensorAddress,
        "typ": typ,
        "v": v,
        "l": l,
        "lb": lb,
        "bv": bv,
        "t": t,
        "r": r,
        "b": b,
        "hi_alarm": hiAlarm,
        "lo_alarm": loAlarm,
        "ts": ts == null ? null : ts?.toIso8601String()
    // "ts": ts

    );
  } */
  Map<String, dynamic> toJson() {
    return {
      "device_name" : deviceName,
      "sensor_address": sensorAddress,
      "friendlyName": friendlyName,
      "typ": typ,
      "v": v,
      "u": u,
      "l": l,
      "lb": lb,
      "bv": bv,
      "t": t,
      "r": r,
      "b": b,
      "hi_alarm": hiAlarm,
      "lo_alarm": loAlarm,
      "ts": ts?.toIso8601String()
      // "ts": ts
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
          int u = 0XFFFF;
          int lb = 0;
          int r = 0;
          int bv = 0;
          int b = 0;
          DateTime? ts;
          int t = 0;
          int l = 0;
          String friendlyName =  "";

          for (String key1 in value.keys) {
            value[key1];
            int value1 = value[key1];
//print("key1: $key1, value1: $value1");
            if (key1 == "typ") {
              typ = value1;
            }
            if (key1 == "v") {
              v = value1;
            }
            if (key1 == "u") {
              u = value1;
            }
            if (key1 == "hi_alarm") {
              hiAlarm = value1;
            }
            if (key1 == "lo_alarm") {
              loAlarm = value1;
            }
            if (key1 == "ts") {
              ts = DateTime.fromMillisecondsSinceEpoch(value1 * 1000);
              // ts = valueInt;
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
            if (key1 == "friendlyName") {
              friendlyName = value1 as String;
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
//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          Alarm alarm = Alarm(
              sensorAddress: key,
              friendlyName: friendlyName,
              typ: typ,
              v: v,
              u: u,
              hiAlarm: hiAlarm,
              loAlarm: loAlarm,
              ts: ts,
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
    return null;
  }

  // vrne sparsano listo alarmov iz preferenc
  static List<Alarm> getAlarmListFromPreferences(List json) {
    List<Alarm> alarmList = [];
    for (var alarm in json) {
      String deviceName = "";
      String sensorAddress = "";
      String friendlyName = "";
      int typ = 0;
      int hiAlarm = 0;
      int loAlarm = 0;
      int v = 0;
      int u = 0XFFFF;
      DateTime? ts;
      int lb = 0;
      int r = 0;
      int l = 0;
      int bv = 0;
      int b = 0;
      int t = 0;
      // String key1 = "";
      for (var key in alarm.keys) {
        //debugPrint("key:  $key");
        var value = alarm[key];

        if (key.isNotEmpty) {
          String valueStr = "";
          //debugPrint("key: $key");
          //debugPrint("value: $value");

          int valueInt = 0;
          if (value is String) {
            valueStr = value;
          } else {
            if (value != null) {
              valueInt = value;
            } else {
              valueInt = 0;
            }
          }
//print("key1: $key1, value1: $value1");
          if (key == "typ") {
            typ = valueInt;
          }
          if (key == "sensor_address") {
            sensorAddress = value;
          }
          if (key == "device_name") {
            deviceName = value ?? "";
          }
          if (key == "friendlyName") {
            friendlyName = value ?? "";
          }
          if (key == "v") {
            v = valueInt;
          }
          if (key == "u") {
            u = valueInt;
          }
          if (key == "hi_alarm") {
            hiAlarm = valueInt;
          }
          if (key == "lo_alarm") {
            loAlarm = valueInt;
          }
          if (key == "ts") {
            DateTime parse = DateTime.parse(value);
            ts = parse;
            // ts = value;//DateTime.fromMillisecondsSinceEpoch(int.parse(value) * 1000);
            //debugPrint("ts");
          }
          if (key == "lb") {
            lb = valueInt;
          }
          if (key == "t") {
            t = valueInt;
          }
          if (key == "r") {
            r = valueInt;
          }
          if (key == "bv") {
            bv = valueInt;
          }
          if (key == "l") {
            l = valueInt;
          }
          if (key == "b") {
            b = valueInt;
          }
        }
      }

      //print("Creating alarm: $sensorAddress, $typ, $t, $hiAlarm, $loAlarm");
      Alarm newAlarm = Alarm(
          sensorAddress: sensorAddress,
          deviceName: deviceName,
          friendlyName: friendlyName  ,
          typ: typ,
          v: v,
          u: u,
          hiAlarm: hiAlarm,
          loAlarm: loAlarm,
          ts: ts,
          lb: lb,
          bv: bv,
          r: r,
          b: b,
          l: l,
          t: t);
      alarmList.add(newAlarm);
    }

    return alarmList;
  }

  static List<Alarm> getAlarmList(Map<String, dynamic> json) {
    List<Alarm> alarmList = [];
    for (String key in json.keys) {
//print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];

//print("value:  $value");
        if (key.isNotEmpty) {
          String sensorName = key;
          int typ = 0;
          int hiAlarm = 0;
          int loAlarm = 0;
          int v = 0;
          int u = 0XFFFF;
          DateTime? ts;
          int lb = 0;
          int r = 0;
          int l = 0;
          int bv = 0;
          int b = 0;
          int t = 0;

          String valueStr = "";

          for (String key1 in value.keys) {
            //value[key1];
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
              if (key1 == "u") {
                u = valueInt;
              }
              if (key1 == "hi_alarm") {
                hiAlarm = valueInt;
              }
              if (key1 == "lo_alarm") {
                loAlarm = valueInt;
              }
              if (key1 == "ts") {
                ts = DateTime.fromMillisecondsSinceEpoch(valueInt * 1000);
                //  DateTime.fromMicrosecondsSinceEpoch(valueInt);
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
            }
                    }
//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          Alarm alarm = Alarm(
              sensorAddress: sensorName,
              deviceName: "",
              typ: typ,
              v: v,
              u: u,
              hiAlarm: hiAlarm,
              loAlarm: loAlarm,
              ts: ts,
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

  @override
  String toString() {
    return "Alarm{sensorAddress: $sensorAddress, deviceName: $deviceName,typ: $typ, "
        " high_alarm: $hiAlarm, loAlarm: $loAlarm, ts: $ts, lb: $lb, bv: $bv, r: $r, b: $b, u: $u, v:$v, t:$t"
        '}';
  }
}
