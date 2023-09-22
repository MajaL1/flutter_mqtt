import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_test/model/user_topic.dart';

class User {
  String username;
  int id;
  String ? email;
  String mqtt_pass;
  DateTime date_register;
  DateTime ? date_login;
  List<UserTopic> topicList = <UserTopic>[];

  User(
      {required this.id, required this.username, required this.email, required this.mqtt_pass, required this.date_register,
        this.date_login, required this.topicList});

  factory User.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> topicsJson;
    topicsJson = map['topics']; // as List<UserTopic>;

     List<UserTopic> topic = topicsJson.map((tagJson) => UserTopic.fromJson(tagJson));

  /*  for (final entry in topicsJson.entries) {
      print("==== ${entry}, ${entry}");
      UserTopic topic = UserTopic.fromJson(entry as Map<String, dynamic>);
    } */



    return User(
    id: map["id"],
    username: map["username"],
    email: map["email"],
    mqtt_pass: map["mqtt_pass"],
    date_register: DateTime.parse(map["date_register"]),
    date_login: map["date_login"] == null ? null : DateTime.tryParse(map["date_login"]),
    topicList: map["topics"] != null ? map["topics"].map((i) => i.toJson()).toList
    (
    )
    :
    null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "mqtt_pass": mqtt_pass,
      "date_register": date_register,
      "date_login": date_login,
      "topicList": topicList
    };
  }

  //List<Topic> topicList =

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
