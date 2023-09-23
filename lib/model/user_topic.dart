import 'dart:ffi';

import 'package:mqtt_test/model/topic_data.dart';

class UserTopic {
  String id;
  List<TopicData> topicList = <TopicData>[];

  UserTopic({required this.id, required this.topicList});

  Map<String, dynamic> toJson() {
    return {"id": id, "topicList": topicList};
  }

  factory UserTopic.fromJson(Map<String, dynamic> json) {
    return UserTopic(
        id: json["id"],
        topicList: json["topics"]
    );
  }
}
