import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mqtt_test/model/topic_data.dart';



import 'package:shared_preferences/shared_preferences.dart';

import 'model/alarm.dart';
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




class _NotificationsAppState extends State<NotificationsApp> with WidgetsBindingObserver{

  _NotificationsAppState() {

  }
  @override
  void initState() {

    String userTopicListRw =  '[{"sensorName":"c45bbe821255","topicList":[{"name":"settings","rw":2},{"name":"data","rw":1},{"name":"sensors","rw":1},{"name":"alarm","rw":1}]},{"sensorName":"c45bbe821261","topicList":[{"name":"settings","rw":1},{"name":"data","rw":1},{"name":"sensors","rw":1},{"name":"alarm","rw":1}]}]';
    List jsonMapTopic = json.decode(userTopicListRw!);
    debugPrint("---userTopicListRw LIST $jsonMapTopic");

    List<UserTopic> userTopicList = [];

    userTopicList =
        jsonMapTopic.map((val) => UserTopic.fromJson(val)).toList();
    String newUserSettings ='{"57":{"typ":1,"u":0,"ut":0,"hi_alarm":1,"device_name":"c45bbe821255"},"84":{"typ":1,"u":0,"ut":0,"hi_alarm":2,"device_name":"c45bbe821255"},"ts":1716292550,"26":{"typ":2,"u":0,"ut":0,"hi_alarm":1,"device_name":"c45bbe821261"},"135":{"typ":7,"u":8,"ut":0,"au":1,"hi_alarm":100,"lo_alarm":0,"device_name":"c45bbe821261"}}';

    List<UserDataSettings> userDataSettings = [];
    userDataSettings =
        UserDataSettings.getUserDataSettingsList(newUserSettings);
    debugPrint("=== _checkAndPairOldSettingsWithNew === newUserSettings == null, userDataSettings $userDataSettings");



    for(UserDataSettings setting in userDataSettings){
      for(UserTopic userTopic in userTopicList){

        if(setting.deviceName == userTopic.sensorName){

          List<TopicData> userTopicList = userTopic.topicList;
          for (TopicData topicData in userTopicList)
          {
            debugPrint("topicData:: $topicData");
            if(topicData.name == "settings"){
              setting.rw = topicData.rw;
              break;
            }
          }
        }
      }
    }
debugPrint("userDataSettings: $userDataSettings");

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
