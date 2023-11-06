import 'dart:convert';

class Data {
  String? sensorAddress;
  int? typ;
  int? l;
  int? t;
  int? b;
  int? r;
  int? lb;
  int? bv;

  Data({this.sensorAddress, this.typ, this.l, this.t, this.b, this.r, this.lb, this.bv});

  Map<String, dynamic> toJson() {
    return {
      "sensor_address": sensorAddress,
      "typ": typ,
      "l": l,
      "t": t,
      "b": b,
      "r": r,
      "lb": lb,
      "bv": bv
    };
  }


   List<Data> getDataList(Map<String, dynamic> json) {
    List<Data> dataList = [];
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
          Data data = Data(
            //this.sensorAddress, this.typ, this.l, this.t, this.b, this.r, this.lb, this.bv
              sensorAddress: sensorAddress, typ: typ, l: l, t:t, b: b, r:r,lb: lb, bv:bv);
          dataList.add(data);
        }
      }
    }
    return dataList;
  }
}
