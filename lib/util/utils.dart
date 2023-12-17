import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

import '../model/alarm.dart';
import '../model/topic_data.dart';
import '../model/user.dart';

class Utils {
  static Future<String> downloadFile(String URL, String filename) async {
    final direactory = await getApplicationSupportDirectory();
    final filepath = '${direactory.path}/$filename';
    final response = await http.get(Uri.parse(URL));
    print(response);

    final file = File(filepath);

    await file.writeAsBytes(response.bodyBytes);
    return filepath;
  }

  /*static int compareDatesInMinutes(List<Alarm> currentAlarmList, List<dynamic> oldAlarmList) {
    Duration? duration =  currentAlarmList.first.ts?.difference(oldAlarmList.last.ts);
    int differenceInMinutes = duration!.inMinutes;
    return differenceInMinutes;
  } */

  static int compareDatesInMinutes(DateTime lastSentAlarm) {
    Duration? duration =  DateTime.now().difference(lastSentAlarm);
    int differenceInMinutes = duration!.inMinutes;
    return differenceInMinutes;
  }


  static List<String> createTopicListFromApi(User user) {
    List<TopicData> userTopicDataList = user.topic.topicList;
    List<String> userTopicList = [];
    String deviceName = user.topic.sensorName;
    for (TopicData topicData in userTopicDataList) {
      if (topicData.name.contains("settings")) {
        userTopicList.add(deviceName + "/settings");
      }
      if (topicData.name.contains("alarm")) {
        userTopicList.add(deviceName + "/alarm");
      }
    }
    return userTopicList;
  }
  static Future<String> getImageFilePathFromAssets(
      String asset, String filename) async {
    final byteData = await rootBundle.load(asset);
    final temp_direactory = await getTemporaryDirectory();
    final file = File('${temp_direactory.path}/$filename');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file.path;
  }
}