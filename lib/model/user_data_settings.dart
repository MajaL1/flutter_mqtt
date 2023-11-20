class UserDataSettings {
  String? deviceName;
  String? sensorAddress;
  int? t;
  int? typ;
  int? hiAlarm;
  int? loAlarm;
  int? u;
  String ? editableSetting;

  UserDataSettings({this.deviceName, this.sensorAddress, this.t, this.hiAlarm, this.loAlarm, this.u, this.editableSetting});

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
      "sensor_address": sensorAddress,
      "t": t,
      "u": u,
      "hi_alarm": hiAlarm,
      "lo_alarm": loAlarm,
    };
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
          int hiAlarm = 0;
          int loAlarm = 0;
          int u = 0;
          for (String key1 in value.keys) {
            if(key1 != null) {
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
              if (key1 == "u") {
                u = value1;
              }
            }
          }
          //print("Creating userSettings: $key, $t, $hiAlarm, $loAlarm");
          UserDataSettings userSettings = UserDataSettings(
              sensorAddress: key, t: t, hiAlarm: hiAlarm, loAlarm: loAlarm, u: u);
          userSettingsList.add(userSettings);
        }
      }
    }
    return userSettingsList;
  }
}
