import 'package:http/http.dart' show Client;
import 'dart:async';
import 'dart:convert';
import '../model/alarm.dart';

class ApiService {
  final String BASE_URL = "https://reqbin.com/sample/post/json";
  static Client client = Client();

  /*Future<List<Alarm>?> getAlarms() async {
    final response = await client.get("$BASE_URL/api/alarm" as Uri);
    if (response.statusCode == 200) {
      return alarmFromJson(response.body);
    } else {
      return null;
    }
  }*/

  static Future<List<Alarm>> getAlarms() async {
    var url = Uri.parse('https://jsonplaceholder.typicode.com/albums');
    final response = await client.get(url);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print("-fetch alarms $jsonResponse");
      return jsonResponse.map((data) => Alarm.fromJson(data)).toList();
    } else {
      throw Exception('Unexpected error occured!');
    }
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
}
