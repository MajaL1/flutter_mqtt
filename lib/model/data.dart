class Data {
  String? deviceName;
  String? sensorAddress;
  int? typ;
  int? w;
  int? t;
  int? d;
  int? r;
  int? lb;

  Data({
    this.deviceName,
    this.sensorAddress,
    this.typ,
    this.w,
    this.t,
    this.d,
    this.r,
    this.lb,
  });

  Map<String, dynamic> toJson() {
    return {
      "sensor_address": sensorAddress,
      "typ": typ,
      "d": d,
      "t": t,
      "w": w,
      "r": r,
      "lb": lb,
    };
  }

  static List<Data> fromJsonList(List<dynamic> json) {
    List<Data> listFromJson = [];
    Data data = Data();
    String sensorAddress;
    for (Map key in json) {
      int t = 0;
      int typ = 0;
      int w = 0;
      int r = 0;
      int lb = 0;
      int d = 0;
      sensorAddress = key["sensor_address"];
      if (key["t"] != null) t = key["t"];
      if (key["w"] != null) w = key["w"];
      if (key["r"] != null) r = key["r"];
      if (key["d"] != null) d = key["d"];
      if (key["typ"] != null) typ = key["typ"];
      if (key["lb"] != null) lb = key["lb"];

      data = Data(
          //this.sensorAddress, this.typ, this.l, this.t, this.b, this.r, this.lb, this.bv
          // sensorAddress: key1,
          typ: typ,
          w: w,
          d: d,
          t: t,
          r: r,
          lb: lb);
      //}
      listFromJson.add(data);
      print("11 key:  $key");
    }
    return listFromJson;
  }

  static List<Data> fromJsonList1(Map<String, dynamic> json) {
    List<Data> listFromJson = [];
    Data data = Data();
    String sensorAddress;
    for (String key in json.keys) {
//print("key:  $key");
      //sensorAddress = key1;
      int t = 0;
      int typ = 0;
      int loAlarm = 0;
      int w = 0;
      int r = 0;
      int lb = 0;
      int d = 0;
      if (key.isNotEmpty) {
        Map value = json[key];
        for (String key1 in value.keys) {

//print("Creating alarm: $key, $t, $hiAlarm, $loAlarm");
          data = Data(
              //this.sensorAddress, this.typ, this.l, this.t, this.b, this.r, this.lb, this.bv
              // sensorAddress: key1,
              typ: typ,
              w: w,
              d: d,
              t: t,
              r: r,
              lb: lb);
          //dataList.add(data);
        }
      }
    }
    return listFromJson;
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    Data data = Data();
    String sensorAddress;
    for (String key in json.keys) {
//print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
//print("value:  $value");
        if (key.isNotEmpty) {
          sensorAddress = key;
          int t = 0;
          int typ = 0;
          int loAlarm = 0;
          int w = 0;
          int r = 0;
          int lb = 0;
          int d = 0;
          for (String key1 in value.keys) {
            if (key1 != null) {
              value[key1];
              int value1 = value[key1];
//print("key1: $key1, value1: $value1");
              if (key1 == "t") {
                t = value1;
              }
              if (key1 == "typ") {
                typ = value1;
              }
              if (key1 == "w") {
                w = value1;
              }
              if (key1 == "r") {
                r = value1;
              }
              if (key1 == "lb") {
                lb = value1;
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
//print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
//print("value:  $value");
        if (key.isNotEmpty) {
          sensorAddress = key;
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
              if (key1 == "typ") {
                typ = value1;
              }
              if (key1 == "w") {
                w = value1;
              }
              if (key1 == "r") {
                r = value1;
              }
              if (key1 == "lb") {
                lb = value1;
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
              lb: lb);
          //dataList.add(data);
          return data;
        }
      }
    }
    return null;
    // return dataList;
  }
}
