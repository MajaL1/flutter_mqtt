import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/data.dart';

class DataSmartMqtt extends ChangeNotifier {
  Data? newMqttData;

  static final DataSmartMqtt _instance = DataSmartMqtt._internal();

  DataSmartMqtt._internal();

  static DataSmartMqtt get instance => _instance;

  factory DataSmartMqtt() {
    debugPrint("DATASMARTMQTT");
    return _instance;
  }

  Future<void> dataProcessor(String decodeMessage, String topicName,
      SharedPreferences preferences) async {
    debugPrint("___________________________________________________");
    debugPrint("from topic data $topicName");
    debugPrint("__________ $decodeMessage");
    debugPrint("___________________________________________________");

    Data? data = await convertMessageToData(decodeMessage, topicName);
    setDataListToPreferences(data!, preferences);
    //preferences.setString("data_mqtt", decodeMessage);
    debugPrint("data: ${data.toString()}");


    setNewMqttData(data);
    //newMqttData = data;
    notifyListeners();
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

  static void setDataListToPreferences(
      Data newData, SharedPreferences preferences) {
    String? dataListStr = preferences.getString("data_mqtt_list");
    List? dataList;

    // zaenkrat dodamo samo en element na listo
    /*if (dataListStr != null) {
      final jsonResult = jsonDecode(dataListStr!);
      if(jsonResult!= null) {
        dataList = Data.fromJsonList(jsonResult);
        dataList.add(newData);
      }
    }*/
    //else {

    dataList = [];
    dataList.add(newData);
    //}
    // popravi
    // String encodedData = json.encode(dataList);
    String json =
        jsonEncode(dataList.map((i) => i.toJson()).toList()).toString();
    //List jsonList = dataList.map((data) => data.toJson()).toList();
    print("jsonList: ${json}");

    debugPrint("encodedData data:  $json");
    debugPrint("datalist:  $dataList");

    preferences.setString("data_mqtt_list", json);
    debugPrint("setting data_mqtt_list encodedData: $json");
  }

  void setNewMqttData(Data data) {
    newMqttData = data;
  }

  Future<Data?> getNewDataList() async {
    return newMqttData;
  }
}
