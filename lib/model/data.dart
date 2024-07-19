class Data {
  String? deviceName;
  String? sensorAddress;
  int? typ;
  int? w;
  int? t;
  int? d;
  int? r;
  int? lb;
  DateTime? ts;

  Data({
    this.deviceName,
    this.sensorAddress,
    this.typ,
    this.w,
    this.t,
    this.ts,
    this.d,
    this.r,
    this.lb,
  });

  static List<Data> fromJsonList(List<dynamic> json) {
    List<Data> listFromJson = [];
    Data data = Data();
    String sensorAddress = "";
    String deviceName = "";

    for (Map key in json) {
      int t = 0;
      int typ = 0;
      int w = 0;
      int r = 0;
      int lb = 0;
      int d = 0;
      DateTime ts = DateTime.now();

      if (key["sensorAddress"] != null) sensorAddress = key["sensor_address"];
      if (key["deviceName"] != null) deviceName = key["deviceName"];

      if (key["t"] != null) t = key["t"];
      if (key["w"] != null) w = key["w"];
      if (key["r"] != null) r = key["r"];
      if (key["d"] != null) d = key["d"];
      if (key["typ"] != null) typ = key["typ"];
      if (key["lb"] != null) lb = key["lb"];
      if (key["ts"] != null)
        ts = DateTime.fromMillisecondsSinceEpoch(key["ts"] * 1000);

      //"ts": ts == null ? null : ts?.toIso8601String()

      data = Data(
          //this.sensorAddress, this.typ, this.l, this.t, this.b, this.r, this.lb, this.bv
          sensorAddress: sensorAddress,
          deviceName: deviceName,
          typ: typ,
          w: w,
          d: d,
          t: t,
          ts: ts,
          r: r,
          lb: lb);
      //}
      listFromJson.add(data);
      //print("11 key:  $key");
    }
    return listFromJson;
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    Data data = Data();
    String sensorAddress;
    String deviceName;

    for (String key in json.keys) {
//print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
//print("value:  $value");
        if (key.isNotEmpty) {
          sensorAddress = key;
          int t = 0;
          int typ = 0;
          int w = 0;
          int r = 0;
          int lb = 0;
          int d = 0;
          DateTime? ts = null;

          for (String key1 in value.keys) {
            if (key1 != null) {
              value[key1];
              var value1 = value[key1];
//print("key1: $key1, value1: $value1");
              if (key1 == "t") {
                t = value1;
              }
              if (key1 == "typ") {
                typ = value1;
              }
              if (key1 == "deviceName") {
                deviceName = value1;
              }
              if (key1 == "w") {
                w = value1;
              }
              if (key1 == "ts") {
                ts = DateTime.fromMillisecondsSinceEpoch(value1 * 1000);
                // ts = valueInt;
              }
              if (key1 == "r") {
                r = value1;
              }
              if (key1 == "lb") {
                lb = value1;
              }
              if (key1 == "d") {
                d = value1;
              }
            }
          }
//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          data = Data(
              //this.sensorAddress, this.typ, this.l, this.t, this.b, this.r, this.lb, this.bv
              sensorAddress: key,
              typ: typ,
              w: w,
              d: d,
              t: t,
              r: r,
              ts: ts,
              lb: lb);
          //dataList.add(data);
          return data;
        }
      }
    }
    return data;
  }

  Data? getData(Map<String, dynamic> json) {
    List<Data> dataList = [];
    Data data;
    for (String key in json.keys) {
      print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
        print("value:  $value");
        if (key.isNotEmpty) {
          sensorAddress = key;
          int t = 0;

          for (String key1 in value.keys) {
            if (key1 != null) {
              value[key1];
              int value1 = value[key1];
              //  print("key1: $key1, value1: $value1");
              if (key1 == "t") {
                t = value1;
              }
              if (key1 == "typ") {
                typ = value1;
              }
              if (key1 == "w") {
                w = value1;
              }
              if (key1 == "d") {
                d = value1;
              }
              if (key1 == "r") {
                r = value1;
              }
              if (key1 == "lb") {
                lb = value1;
              }
              if (key1 == "ts") {
                ts = DateTime.fromMillisecondsSinceEpoch(value1 * 1000);
                // ts = valueInt;
              }
            }
          }
//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          data = Data(
              //this.sensorAddress, this.typ, this.l, this.t, this.b, this.r, this.lb, this.bv
              sensorAddress: key,
              deviceName: deviceName,
              typ: typ,
              w: w,
              d: d,
              t: t,
              ts: ts,
              r: r,
              lb: lb);
          //dataList.add(data);
          return data;
        }
      }
    }
    return null;
    // return dataList;
  }

  @override
  String toString() {
    return "Data{sensorAddress: $sensorAddress, deviceName: $deviceName,typ: $typ, "
        " t: $t, w: $w, ts: $ts, d: $d, r: $r, lb: $lb"
        '}';
  }

  Map<String, dynamic> toJson() {
    return {
      "sensor_address": sensorAddress,
      "deviceName": deviceName,
      "typ": typ,
      "d": d,
      "ts": ts, //DateTime.fromMillisecondsSinceEpoch(ts * 1000),
      "t": t,
      "w": w,
      "r": r,
      "lb": lb,
    };
  }
}
