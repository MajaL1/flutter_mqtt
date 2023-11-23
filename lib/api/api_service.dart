import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' show Client, Response, post;
import 'package:mqtt_test/model/constants.dart';
import 'package:mqtt_test/model/notification_message.dart';
import 'package:mqtt_test/model/user_topic.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/alarm.dart';
import '../model/user.dart';

//import 'package:mqtt_test/assets/alarms.json' show rootBundle;

class ApiService {
  static Client client = Client();

  static Future<List<Alarm>> getAlarms() async {
    var data = await rootBundle.loadString("assets/alarms.json");
    final jsonResult = jsonDecode(data);
    //debugPrint("jsonResult from file: $jsonResult");
    final parsed = jsonDecode(data).cast<Map<String, dynamic>>();

    return parsed.map<Alarm>((json) => Alarm.getAlarmList(json));
  }

  static Future<List<Alarm>> getAlarmsHistory() async {
    List<Alarm> alarmList = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("alarm_list_mqtt")) {
      String alarmListData = preferences.get("alarm_list_mqtt") as String;
      List alarmMessageJson = json.decode(alarmListData);

      alarmList = Alarm.getAlarmListFromPreferences(alarmMessageJson);

      debugPrint("alarmList-:: $alarmList");
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

  static Future<User?> login(String email, password) async {
    //email = "test";
    //password = "Test@1234";
    try {
      Response response = await post(
          Uri.parse('http://test.navis-livedata.com:1002/api/auth.php'),
          body: {
            'login_username': email,
            'login_password': password,
            'login': '123'
          },
          headers: {
            "Content-type": "application/x-www-form-urlencoded",
            "Accept": "text/html,application/xhtml+xml,application/xml"
          });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        debugPrint(data['token']);
        debugPrint('=====Login successfully');
        List<UserTopic> topicList = [];
        UserTopic topic = UserTopic(id: '1', topicList: []);
        topicList.add(topic);
        User user = User(
            id: 1,
            username: 'User1',
            date_login: DateTime.now(),
            date_register: DateTime.now(),
            email: 'test@test.com',
            mqtt_pass: '12345',
            topic: topic);

        return user;
      } else {
        debugPrint('=====Login failed');
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
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
    final jsonResult = jsonDecode(data);
    debugPrint("jsonResult: $jsonResult");

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
