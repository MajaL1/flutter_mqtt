import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/notification_helper.dart';
import '../model/alarm.dart';
import '../model/constants.dart';
import '../model/data.dart';
import '../mqtt/MQTTAppState.dart';
import '../widgets/show_alarm_time_settings.dart';

class DataSmartMqtt extends ChangeNotifier {

  Data ?newMqttData;


  static final DataSmartMqtt _instance = DataSmartMqtt._internal();

  DataSmartMqtt._internal();

  static DataSmartMqtt get instance => _instance;

  factory DataSmartMqtt(
      ) {

    debugPrint("DATASMARTMQTT");
    return _instance;
  }




   Future<void> dataProcessor(String decodeMessage, String topicName, SharedPreferences preferences) async {
    Data? data = await convertMessageToData(decodeMessage, topicName);
    setDataListToPreferences(data!, preferences);
    //preferences.setString("data_mqtt", decodeMessage);

    debugPrint("___________________________________________________");
    debugPrint("from topic data $topicName");
    debugPrint("__________ $decodeMessage");
    debugPrint("___________________________________________________");
    debugPrint("data: ${data.toString()}");

    setNewMqttData(data);
     //newMqttData = data;
    // notifyListeners();
  }

  static Data? convertMessageToData(String message, String deviceName) {
    String decodeMessage = const Utf8Decoder().convert(message.codeUnits);
    Map<String, dynamic> dataStr = json.decode(decodeMessage);

    Data? data = Data().getData(dataStr);
    // Data data = json.decode(dataStr);
    data?.deviceName = deviceName.split("/data").first;

    debugPrint(
        "converting data object...${data?.deviceName}, ${data?.sensorAddress}, ${data?.typ}, ${data?.t}");

    return data;
  }

  static void setDataListToPreferences(Data newData, SharedPreferences preferences) {
    String? dataListStr = preferences.getString("data_mqtt_list");
    List? dataList;

    // zaenkrat dodamo samo eno element na listo
    /*if (dataListStr != null) {
      final jsonResult = jsonDecode(dataListStr!);
      dataList = Data.fromJsonList(jsonResult);
      dataList.add(newData);
    } else { */
    dataList = [];
    dataList.add(newData);
    // }
    String encodedData = json.encode(dataList);
    debugPrint("encodedData:  $encodedData");
    preferences.setString("data_mqtt_list", encodedData);
    debugPrint("setting data_mqtt_list encodedData: $encodedData");
  }

   void setNewMqttData(Data data) {
    newMqttData = data;
  }
}









  Data? convertMessageToData(String message, String deviceName) {
    String decodeMessage = const Utf8Decoder().convert(message.codeUnits);
    Map<String, dynamic> dataStr = json.decode(decodeMessage);

    Data? data = Data().getData(dataStr);
    // Data data = json.decode(dataStr);
    data?.deviceName = deviceName.split("/data").first;

    debugPrint(
        "converting data object...${data?.deviceName}, ${data?.sensorAddress}, ${data?.typ}, ${data?.t}");

    return data;
  }

  void setDataListToPreferences(Data newData, SharedPreferences preferences) {
    String? dataListStr = preferences.getString("data_mqtt_list");
    List? dataList;

    // zaenkrat dodamo samo eno element na listo
    /*if (dataListStr != null) {
      final jsonResult = jsonDecode(dataListStr!);
      dataList = Data.fromJsonList(jsonResult);
      dataList.add(newData);
    } else { */
      dataList = [];
      dataList.add(newData);
   // }
    String encodedData = json.encode(dataList);
    debugPrint("encodedData:  $encodedData");
    preferences.setString("data_mqtt_list", encodedData);
    debugPrint("setting data_mqtt_list encodedData: $encodedData");
  }


