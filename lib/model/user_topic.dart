import 'dart:ffi';

class UserTopic {
  String name;
  String rw;

  UserTopic({required this.name, required this.rw});

  Map<String, dynamic> toJson() {
    return {"name": name, "name": name, "rw": rw};
  }

  factory UserTopic.fromJson(Map<String, dynamic> json) {
         return UserTopic(
        name: json['name'] as String,
        rw : json['rw'] as String,
      );
    //}
  }
  /*List<UserTopic> fromJson(Map<String, dynamic> parsedJson) {
    List<UserTopic> userTopicList = [];
    for (String key in parsedJson.keys) {
      print(key);
      print(parsedJson[key]);

      UserTopic userTopic = UserTopic(name: name, rw: rw);
      userTopicList.add(userTopic);
    }
    return userTopicList;
  } */
}
