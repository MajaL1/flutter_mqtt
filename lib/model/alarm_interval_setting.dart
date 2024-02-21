class AlarmIntervalSetting {
  String deviceName;
  String sensorAddress;
  String setting;
  String value;

  AlarmIntervalSetting(
      {required this.deviceName,
      required this.sensorAddress,
      required this.setting,
      required this.value});

  Map<String, dynamic> toJson() {
    return {
      "deviceName": deviceName,
      "sensor_address": sensorAddress,
      "setting": setting,
      "value": value,
      // "ts": ts
    };
  }
}
