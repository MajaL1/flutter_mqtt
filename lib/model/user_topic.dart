import 'package:mqtt_test/model/topic_data.dart';

class UserTopic {
  String sensorName;
  List<TopicData> topicList = <TopicData>[];

  UserTopic({required this.sensorName, required this.topicList});

  Map<String, dynamic> toJson() {
    return {"sensorName": sensorName, "topicList": topicList};
  }

  factory UserTopic.fromJson(Map<String, dynamic> json) {
    return UserTopic(
      sensorName: json["sensorName"],
      //topicList: json["topicList"]
      topicList:
      (json['topicList']as List).map((item) => TopicData.fromJson(item)).toList(),

        // myModels=(json.decode(response.body) as List).map((i) =>
      //               MyModel.fromJson(i)).toList();
    );
  }
}
