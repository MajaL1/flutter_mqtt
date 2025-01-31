import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' show Client, Response, post;
import 'package:mqtt_test/main.dart';
import 'package:mqtt_test/model/alarm.dart';
import 'package:mqtt_test/model/constants.dart';
import 'package:mqtt_test/model/notification_message.dart';
import 'package:mqtt_test/model/topic_data.dart';
import 'package:mqtt_test/model/user.dart';
import 'package:mqtt_test/model/user_topic.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/background_mqtt.dart';


class ApiService {
  static Client client = Client();

  static Future<List<Alarm>> getAlarms() async {
    var data = await rootBundle.loadString("assets/alarms.json");
    //final jsonResult = jsonDecode(data);
    //debugPrint("jsonResult from file: $jsonResult");
    final parsed = jsonDecode(data).cast<Map<String, dynamic>>();

    return parsed.map<Alarm>((json) => Alarm.getAlarmList(json));
  }

  static Future<List<Alarm>> getAlarmsHistory() async {
    List<Alarm> alarmList = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    if (preferences.containsKey("alarm_list_mqtt")) {
      String alarmListData = preferences.get("alarm_list_mqtt") as String;
      if (alarmListData.isNotEmpty) {
        List alarmMessageJson = json.decode(alarmListData);
        alarmList = Alarm.getAlarmListFromPreferences(alarmMessageJson);
      }
      debugPrint("alarmList-:: $alarmList");
    }
    alarmList.add(Alarm());
    alarmList = alarmList.reversed.toList();
    // Ce je vec kot 2000 zadetkov, izbrisi zadnje
    if (alarmList.length > 2000) {
      alarmList.removeRange(2000, alarmList.length);
    }
    return alarmList;
  }

  static Future<List<Alarm>> getAlarmsHistoryTest() async {
    List<Alarm> alarmList = [];
    int i = 0;
    while (i < 50) {
      Alarm alarm1 = Alarm(
          deviceName: "aa1",
          sensorAddress: "aa1bb2",
          hiAlarm: 10,
          loAlarm: 1,
          ts: DateTime.now());
      Alarm alarm2 = Alarm(
          deviceName: "aa1",
          sensorAddress: "bb1cc2",
          hiAlarm: 20,
          loAlarm: 2,
          ts: DateTime.now());
      Alarm alarm3 = Alarm(
          deviceName: "bb1",
          sensorAddress: "dd1ee1",
          hiAlarm: 40,
          loAlarm: 4,
          ts: DateTime.now());
      Alarm alarm4 = Alarm(
          deviceName: "bb1",
          sensorAddress: "bb1cc2",
          hiAlarm: 60,
          loAlarm: 6,
          ts: DateTime.now());
      alarmList.add(alarm1);
      alarmList.add(alarm2);
      alarmList.add(alarm3);
      alarmList.add(alarm4);
      i++;
    }
    return alarmList;
  }

  static Future<User> getUserData() async {
    var data = await rootBundle.loadString("assets/user.json");
    final jsonResult = jsonDecode(data);
    User user = User.fromJson(jsonResult);
    //print("jsonResult: $jsonResult");
    return user;
  }

  /*Future<bool> createAlarms(Alarm data) async {
    String url = Constants.BASE_URL;
    final response = await client.post(
      "$url/api/alarm" as Uri,
      headers: {"content-type": "application/json"},
      body: alarmToJson(data),
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } */

  static Future<User?> login(String username, password) async {
    try {
      debugPrint('=====Logging in ... $username, $password');

      Response response = await post(
          Uri.parse('http://test.navis-livedata.com:1002/api/auth.php'),
          body: {
            'login_username': username,
            'login_password': password,
            'login': '123'
          },
          headers: {
            "Content-type": "application/x-www-form-urlencoded",
            "Accept": "text/html,application/xhtml+xml,application/xml"
          });

      //User user = User.base();
      //user.licenceExpired = true;
      //return user;
      debugPrint("===RESPONSE status code:: ${response.statusCode}");

      if(response.statusCode == 403){
        debugPrint("===Api service login status code 403: ");
          User user = User.base();
          user.licenceExpired = true;
          return user;
      }
      if (response.statusCode == 200) {
        var data = await jsonDecode(response.body.toString());
        // debugPrint(data['token']);
        debugPrint('=====Login successfully');
        List<UserTopic> userTopicList;
        //UserTopic userTopic;
        if (data["topics"] != null) {
          // userTopic = getUserTopic(data["topics"]);
          userTopicList = await getUserTopicList(data["topics"]);

          //prefs?.reload();
          User user = User(
              id: 1,
              username: data["username"],
              date_login: DateTime.now(),
              date_register: DateTime.now(),
              email: data["email"], //?? "test@test.com",
              mqtt_pass: data["mqtt_pass"],
              userTopicList: userTopicList);
          return user;
        }
      } else {
        debugPrint('=====Login failed $username, $password');
        return null;
      }
    } catch (e) {
      debugPrint('=====Login failed exception $username, $password');

      debugPrint(e.toString());
      return null;
    }
    debugPrint('=====Login failed returning null $username, $password');

    return null;
  }

  static Future logout() async{
    debugPrint("logging out");
    await stopService();
    await _removeUserPreferences();
    Timer(const Duration(seconds: 2), () {
      debugPrint("logout delay");
    });
  }

  static Future _removeUserPreferences() async{
    SharedPreferences.getInstance().then((value) {
      if (value.getString("username") != null) {
        value.remove("username");
      }
    });
    SharedPreferences.getInstance().then((value) {
      if (value.getString("email") != null) {
        value.remove("email");
      }
    });
    SharedPreferences.getInstance().then((value) {
      if (value.getBool("isLoggedIn") != null) {
        value.setBool("isLoggedIn", false);
      }
    });
    /*SharedPreferences.getInstance().then((value) {
      if (value.getString("settings_mqtt_device_name") != null) {
        value.remove("settings_mqtt_device_name");
      }
    });*/
    SharedPreferences.getInstance().then((value) {
      if (value.getString("current_mqtt_settings") != null) {
        value.remove("current_mqtt_settings");
      }
    });
    SharedPreferences.getInstance().then((value) {
      if (value.getBool("appRunInBackground") != null) {
        value.remove("appRunInBackground");
      }
    });
  }

  static Future<bool> startService() async {
    if(await service.isRunning()){
      print("----isRunning");
      debugPrint("----isRunning");
      return false;
    }
    else {
      debugPrint("----notRunning");
      print("----notRunning");
      await BackgroundMqtt(flutterLocalNotificationsPlugin).initializeService(
          service);
      return true;
    }
  }

  static Future<void> stopService() async {
    final result = await BackgroundMqtt.stopMqttService();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("serviceStopped", true);
    //service.invoke("stopService");
    var isRunning;
    int i = 5;
    while(i > 0) {
      isRunning = await service.isRunning();
      if (!isRunning) {
        break;
      }
     else {
        sleep(Duration(seconds:1));
      }
     i--;
    }
    
    if(i == 0 ){
      debugPrint("error stop service");
    }
    debugPrint(" isRunning $isRunning");

    //} else {
     // debugPrint(" isRunning FALSE, logout service");
      //service.startService();
   // }
    debugPrint("stopping service");
    return result;
  }

// Todo: use this method
  static Future<List<UserTopic>> getUserTopicList(Map topics) async{
    List<TopicData> topicList = [];
    List<UserTopic> userTopicList = [];

    for (var devices in topics.keys) {
      var deviceName = devices;

      String topicName = "";
      int rw = 0;
      UserTopic topic = UserTopic(sensorName: '1', topicList: []);
      topic.sensorName = deviceName;
      for (var topicVal in topics[deviceName]) {
        //debugPrint("topicVal: $topicVal");

        topicName = topicVal["topic"];
        rw = topicVal["rw"];

        //debugPrint("topic: $topicName");
        //debugPrint("topic: $rw");

        TopicData topicData = TopicData(name: topicName, rw: rw);
        //debugPrint("-- create new topicData: topicName: $topicName, rw: $rw");
        topicList.add(topicData);
        //debugPrint("-- adding new topicData: to topicList: length: ${topicList.length} ${topicData}");
      }
      userTopicList.add(UserTopic(sensorName: deviceName, topicList: topicList));
      topicList = [];
    }
    return userTopicList;
  }

  static UserTopic getUserTopic(Map topics) {
    List<TopicData> topicList = [];
    UserTopic topic = UserTopic(sensorName: '1', topicList: []);

    for (var devices in topics.keys) {
      var deviceName = devices;
      topic.sensorName = deviceName;
      String topicName = "";
      int rw = 0;
      for (var topicVal in topics.values) {
        for (var topicVal1 in topicVal) {
          //debugPrint("topicVal1: $topicVal1");

          topicName = topicVal1["topic"];
          rw = topicVal1["rw"];

          //debugPrint("topic: $topicName");
          //debugPrint("topic: $rw");

          //debugPrint("rw: $rw");
          TopicData topicData = TopicData(name: topicName, rw: rw);
          topicList.add(topicData);
        }
      }
    }
    topic.topicList = topicList;
    return topic;
  }

/* Future<Map<String, dynamic>> register(String email, String password, String passwordConfirmation) async {

    final Map<String, dynamic> registrationData = {
      'user': {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation
      }
    };


   // _registeredInStatus = Status.Registering;
   // notifyListeners();

    /*return await post(AppUrl.register,
        body: json.encode(registrationData),
        headers: {'Content-Type': 'application/json'})
        .then(onValue)
        .catchError(onError);
  }

  static Future<FutureOr> onValue(Response response) async {
    var result;
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {

      var userData = responseData['data'];

      User authUser = User.fromJson(userData);

      /*UserPreferences().saveUser(authUser);
      result = {
        'status': true,
        'message': 'Successfully registered',
        'data': authUser
      }; */
    } else {

      result = {
        'status': false,
        'message': 'Registration failed',
        'data': responseData
      };
    }

    return result;
  }

  static onError(error) {
    print("the error is $error.detail");
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }
*/

 */
  static Future<List<NotificationMessage>> getNotificationMessage() async {
    var data =
        await rootBundle.loadString("assets/test_notifications_list.json");
    //final jsonResult = jsonDecode(data);
    //debugPrint("jsonResult: $jsonResult");

    final parsed = jsonDecode(data).cast<Map<String, dynamic>>();

    return parsed
        .map<NotificationMessage>((json) => NotificationMessage.fromJson(json))
        .toList();
  }

  Future<bool> createNotificationMessageFromJson(
      NotificationMessage data) async {
    String url = Constants.BASE_URL;
    final response = await client.post("$url/api/alarm" as Uri,
        headers: {"content-type": "application/json"}, body: data.toJson()
        //NotificationMessage().notificationMessageToJson(data),
        );
    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
