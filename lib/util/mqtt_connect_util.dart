import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../model/user.dart';

class MqttConnectUtil {
  static Future<User> readUserData() async {
    User user = await ApiService.getUserData();
    return user;
  }

  static void initalizeUserPrefs(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("username", user.username);
    sharedPreferences.setString("email", user.email ?? "");
    sharedPreferences.setString("mqtt_pass", user.mqtt_pass);
  }

  static List<String> getBrokerAddressList(User user) {
    List<String> brokerAddressList = [];
    var topicForUser = user.topic.topicList;
    debugPrint("user.topic.sensorName : ${user.topic.sensorName}");
    String deviceName = user.topic.sensorName;
    debugPrint("deviceName : $deviceName");

    for (var topic in topicForUser) {
      String topicName = topic.name;
      debugPrint("==== name:  ${topic.name}");
      debugPrint("==== rw:  ${topic.rw}");

      brokerAddressList.add(deviceName + "/" + topicName);
    }
    return brokerAddressList;
  }
}
