import 'dart:convert';
import 'package:mqtt_test/model/topic_data.dart';
import 'package:mqtt_test/model/user_topic.dart';

class User {
  late String username;
  late int id;
  late String email;
  late String mqtt_pass;
  late DateTime date_register;
  late DateTime? date_login;
  late List<UserTopic> userTopicList;
  bool licenceExpired = false;

  User.base();

  User(
      {required this.id,
      required this.username,
      required this.email,
      required this.mqtt_pass,
      required this.date_register,
      this.date_login,
      required this.userTopicList});

  factory User.fromJson(Map<String, dynamic> map) {
    Map topicsJson;
    topicsJson = map['topics']; // as List;
    UserTopic userTopic = UserTopic(sensorName: "", topicList: []);
    for (final key in topicsJson.keys) {
      //print("==== ${key}, ${topicsJson[key]}");
      List topicData1 = topicsJson[key];
      //print("==== topicData1 ${topicData1}");
      List<TopicData> topicDataList = [];
      for (var topic in topicData1) {
        //print(
        //   "==== topic['topic']:  ${topic['topic']}, topic['rw']: ${topic['rw']}");
        TopicData topicData = TopicData(name: topic['topic'], rw: topic['rw']);
        topicDataList.add(topicData);
      }
      userTopic = UserTopic(sensorName: key, topicList: topicDataList);
    }

    return User(
        id: map["id"],
        username: map["username"],
        email: map["email"],
        mqtt_pass: map["mqtt_pass"],
        date_register: DateTime.parse(map["date_register"]),
        date_login: map["date_login"] == null
            ? null
            : DateTime.tryParse(map["date_login"]), userTopicList: [],
    //    userTopicList: userTopicList
    );
  }

  List<TopicData> getTopicDataList(topicData) {
    List<TopicData> topicDataList = [];
    for (var topic in topicData) {
      TopicData topicData = TopicData(name: topic.name, rw: topic.rw);
      topicDataList.add(topicData);
    }
    return topicDataList;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "mqtt_pass": mqtt_pass,
      "date_register": date_register,
      "date_login": date_login,
      "userTopicList": userTopicList
    };
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
