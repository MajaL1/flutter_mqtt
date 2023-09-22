import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_test/model/user_topic.dart';

class User {
  String username;
  int id;
  String email;
  String mqtt_pass;
  DateTime date_register;
  DateTime date_login;
  List<UserTopic> topicList = <UserTopic>[];

  User({required this.id, required this.username, required this.email, required this.mqtt_pass, required this.date_register,
      required this.date_login, required this.topicList});

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
        id: map["id"],
        username: map["_username"],
        email: map["email"],
        mqtt_pass: map["mqtt_pass"],
        date_register: map["date_register"],
        date_login: map["date_login"],
        topicList: map["_topics"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "username": username, "mqtt_pass": mqtt_pass, "date_register": date_register, "date_login": date_login, "topicList": topicList};
  }

  @override
  String toString() {
    return 'User{id: $id, name: $username}';
  }
}

List<User> userFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<User>.from(data.map((item) => User.fromJson(item)));
}

String userToJson(User data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
