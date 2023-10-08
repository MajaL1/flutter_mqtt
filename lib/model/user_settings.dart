class UserSettings {
  String? sensorAddress;
  BigInt? alarmValue;

  UserSettings({sensorAddress, t, hiAlarm, loAlarm});

  Map<String, dynamic> toJson() {
    return {"sensor_address": sensorAddress};
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    for (String key in json.keys) {
      print("key:  $key");
      if (key.isNotEmpty) {
        Map value = json[key];
        print("value:  $value");
        if (key.isNotEmpty) {
          int t = 0;
          int hiAlarm = 0;
          int loAlarm = 0;
          for (String key1 in value.keys) {
            value[key1];
            int value1 = value[key1];
            print("key1: $key1, value1: $value1");
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
          UserSettings userSettings = UserSettings(sensorAddress: key, t: t, hiAlarm: hiAlarm, loAlarm: loAlarm);
        }
        UserSettings userSettings =
        UserSettings(sensorAddress: 2);
      }
    }
    return UserSettings(
      sensorAddress: json["sensor_address"], //,json.keys.first.
      t: json["t"],
      hiAlarm: json["hi_alarm"],
      loAlarm: json["lo_alarm"],
    );
  }
}
