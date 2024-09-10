import 'dart:convert';
import 'dart:async';


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

    if(!decodeMessage.contains("con") || !decodeMessage.contains("dis") ) {
      Data? data = await convertMessageToData(decodeMessage, topicName);
      await setDataListToPreferences(data!, preferences);
      //preferences.setString("data_mqtt", decodeMessage);
      debugPrint("data: ${data.toString()}");
      setNewMqttData(data);
    }
    else{
      debugPrint("data is weird: ${decodeMessage}");

    }
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

  static Future<void> setDataListToPreferences (
      Data newData, SharedPreferences preferences) async {
    String? dataListStr = preferences.getString("data_mqtt_list");

    List<Data> dataList = [];
    List jsonMap1 = [];

    if(dataListStr != null) {
      if (dataListStr.isNotEmpty) {
        jsonMap1 = json.decode(dataListStr!);
        debugPrint("!!!1 jsonMap1 $jsonMap1");

       // List dataList1 = jsonMap1.map((val) => Data.fromJsonList(val)).toList();
        dataList =  Data.fromJsonList(jsonMap1);
        dataList.add(newData);

        //dataList = jsonMap1.map((val) => Data.fromJson(val)).toList();
        /*
        List jsonMap1 = json.decode(parsedMqttSettings!);
        parsedMqttSettingsList =
            jsonMap1.map((val) => UserDataSettings.fromJson(val)).toList();
         */

        debugPrint("!datalist.size: ${dataList.length});//, encodedData dataListStr $dataList");
      }
    }
    else {
      dataList.add(newData);
    }

    String json1 =
        jsonEncode(dataList);
    //List jsonList = dataList.map((data) => data.toJson()).toList();
    print("jsonList: ${json1}");

    debugPrint("encodedData data:  $json1");
    debugPrint("datalist:  $dataList");

    preferences.setString("data_mqtt_list", json1);
    debugPrint("setting data_mqtt_list encodedData: $json1");
  }

  void setNewMqttData(Data data) {
    newMqttData = data;
  }

  Future<Data?> getNewDataList() async {
    return newMqttData;
  }
}
