import 'package:flutter/services.dart';
import 'package:http/http.dart' show Client;
import 'package:mqtt_test/model/notif_message.dart';
import 'dart:async';
import 'dart:convert';
import '../model/alarm.dart';

//import 'package:mqtt_test/assets/alarms.json' show rootBundle;

class ApiService {
  static final String BASE_URL = "https://reqbin.com/sample/post/json";
  static Client client = Client();

  static Future<List<Alarm>> getAlarms() async {
    var data = await rootBundle.loadString("assets/alarms.json");
    final jsonResult = jsonDecode(data);
    print("jsonResult: $jsonResult");

    final parsed = jsonDecode(data).cast<Map<String, dynamic>>();

    return parsed.map<Alarm>((json) => Alarm.fromJson(json)).toList();
  }

  Future<bool> createAlarms(Alarm data) async {
    final response = await client.post(
      "$BASE_URL/api/alarm" as Uri,
      headers: {"content-type": "application/json"},
      body: alarmToJson(data),
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future void login(String email , password) async {
    
    try{
      Response response = await post(
        Uri.parse('https://reqres.in/api/login'),
        body: {
          'email' : 'eve.holt@reqres.in',
          'password' : 'cityslicka'
        }
      );

      if(response.statusCode == 200){
        
        var data = jsonDecode(response.body.toString());
        print(data['token']);
        print('Login successfully');

      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  static Future<List<NotifMessage>> getNotifMess() async {
    var data = await rootBundle.loadString("assets/test_notifications_list.json");
    final jsonResult = jsonDecode(data);
    print("jsonResult: $jsonResult");

    final parsed = jsonDecode(data).cast<Map<String, dynamic>>();

    return parsed.map<NotifMessage>((json) => NotifMessage.fromJson(json)).toList();
  }

   Future<bool> createNotifMessageFromJson(NotifMessage data) async {
    final response = await client.post("$BASE_URL/api/alarm" as Uri,
        headers: {"content-type": "application/json"},
        body: data.toJson()
        //NotifMessage().notifMessageToJson(data),
        );
    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
