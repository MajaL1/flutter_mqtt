class UserSettings {
  String sensorAddress;
  BigInt alarmValue;
 
  UserSettings({required this.sensorAddress, required this.alarmValue});

  Map<String, dynamic> toJson() {
    return {"sensor_address": sensorAddress};
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
        sensorAddress: json["sensor_address"],
        alarmValue: json["alarm_value"]
    );
  }
}
