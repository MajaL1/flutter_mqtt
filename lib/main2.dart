import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_test/model/topic_data.dart';

import 'model/user_data_settings.dart';
import 'model/user_topic.dart';

Future<void> main() async {
  runApp(
    NotificationsApp(),
  );
}

class NotificationsApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  //static FlutterBackgroundService service = FlutterBackgroundService();
  NotificationsApp({Key? key}) : super(key: key);

  @override
  State<NotificationsApp> createState() => _NotificationsAppState();
}

class _NotificationsAppState extends State<NotificationsApp>
    with WidgetsBindingObserver {
  _NotificationsAppState() {}

  @override
  void initState() {

    testParseData();

    setUserDeviceRw();
  }

  void setUserDeviceRw() {
    String userTopicListRw =
        '[{"sensorName":"c45bbe821255","topicList":[{"name":"settings","rw":2},{"name":"data","rw":1},{"name":"sensors","rw":1},{"name":"alarm","rw":1}]},{"sensorName":"c45bbe821261","topicList":[{"name":"settings","rw":1},{"name":"data","rw":1},{"name":"sensors","rw":1},{"name":"alarm","rw":1}]}]';
    List jsonMapTopic = json.decode(userTopicListRw!);
    debugPrint("---userTopicListRw LIST $jsonMapTopic");

    List<UserTopic> userTopicList = [];

    userTopicList = jsonMapTopic.map((val) => UserTopic.fromJson(val)).toList();
    String newUserSettings =
        '{"57":{"typ":1,"u":0,"ut":0,"hi_alarm":1,"device_name":"c45bbe821255"},"84":{"typ":1,"u":0,"ut":0,"hi_alarm":2,"device_name":"c45bbe821255"},"ts":1716292550,"26":{"typ":2,"u":0,"ut":0,"hi_alarm":1,"device_name":"c45bbe821261"},"135":{"typ":7,"u":8,"ut":0,"au":1,"hi_alarm":100,"lo_alarm":0,"device_name":"c45bbe821261"}}';

    List<UserDataSettings> userDataSettings = [];
    userDataSettings =
        UserDataSettings.getUserDataSettingsList(newUserSettings);
    debugPrint(
        "=== _checkAndPairOldSettingsWithNew === newUserSettings == null, userDataSettings $userDataSettings");

    for (UserDataSettings setting in userDataSettings) {
      for (UserTopic userTopic in userTopicList) {
        if (setting.deviceName == userTopic.sensorName) {
          List<TopicData> userTopicList = userTopic.topicList;
          for (TopicData topicData in userTopicList) {
            debugPrint("topicData:: $topicData");
            if (topicData.name == "settings") {
              setting.rw = topicData.rw;
              break;
            }
          }
        }
      }
    }
    debugPrint("userDataSettings: $userDataSettings");
  }

  void testParseData(){
    String inputData1 = '{"26":{"typ":2,"w":7,"d":279,"t":182,"r":-71,"lb":1,"u":0,"ts":1725893914}}';

    String? dataListStr = preferences.getString("data_mqtt_list");

    List dataList = [];
    List jsonMap1 = [];

    if(dataListStr != null) {
      if (dataListStr.isNotEmpty) {
        jsonMap1 = json.decode(dataListStr!);
        jsonMap1.map((val) => Data.fromJson(val));
        dataList = jsonMap1.map((val) => Data.fromJson(val)).toList();
        /*
        List jsonMap1 = json.decode(parsedMqttSettings!);
        parsedMqttSettingsList =
            jsonMap1.map((val) => UserDataSettings.fromJson(val)).toList();
         */

        debugPrint("encodedData dataListStr $dataList");
      }
    }


    // zaenkrat dodamo samo en element na listo
    /*if (dataListStr != null) {
      final jsonResult = jsonDecode(dataListStr!);
      if(jsonResult!= null) {
        dataList = Data.fromJsonList(jsonResult);
        dataList.add(newData);
      }
    }*/
    //else {

    //dataList = [];
    dataList.add(newData);
    //}
    // popravi
    // List test = dataList.map((i) => i.toJson()).toList();
    String json1 =
    jsonEncode(dataList);
    //List jsonList = dataList.map((data) => data.toJson()).toList();
    print("jsonList: ${json1}");

    debugPrint("encodedData data:  $json1");
    debugPrint("datalist:  $dataList");

    preferences.setString("data_mqtt_list", json1);
    debugPrint("setting data_mqtt_list encodedData: $json1");
  }



  }

  @override
  void dispose() {
    debugPrint("main.dart - dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
