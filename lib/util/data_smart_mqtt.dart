import 'dart:convert';
import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/data.dart';

class DataSmartMqtt extends ChangeNotifier {

  static final DataSmartMqtt _instance = DataSmartMqtt._internal();

  DataSmartMqtt._internal();

  static DataSmartMqtt get instance => _instance;

  factory DataSmartMqtt() {
    debugPrint("DATASMARTMQTT");
    return _instance;
  }
  List<Data> newMqttData = [];


  Future<void> dataProcessor(String decodeMessage, String topicName,
      SharedPreferences preferences) async {
    debugPrint("___________________________________________________");
    debugPrint("from topic data $topicName");
    debugPrint("__________ $decodeMessage");
    debugPrint("___________________________________________________");

    if(!decodeMessage.contains("con") || !decodeMessage.contains("dis") ) {
      Data? data = await convertMessageToData(decodeMessage, topicName);
      List<Data> dataList = await setDataListToPreferences(data!, preferences);
      //preferences.setString("data_mqtt", decodeMessage);
      debugPrint("''data: ${data.toString()}");
      await setNewMqttData(dataList).then((val){notifyListeners();});
      newMqttData = dataList;
      //notifyListeners();

    }
    else{
      debugPrint("data is weird: ${decodeMessage}");

    }//newMqttData = data;
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

  static Future<List<Data>> setDataListToPreferences (
      Data newData, SharedPreferences preferences) async {
    String? dataListStr = preferences.getString("data_mqtt_list");

    List<Data> dataList = [];
    List jsonMap1 = [];

    if(dataListStr != null) {
      if (dataListStr.isNotEmpty) {
        jsonMap1 = json.decode(dataListStr!);
        //debugPrint("!!!1 jsonMap1 $jsonMap1");

       // List dataList1 = jsonMap1.map((val) => Data.fromJsonList(val)).toList();
        dataList =  Data.fromJsonList(jsonMap1);

        String? sensorAddress = newData.sensorAddress;
        String ? deviceName = newData.deviceName;

        bool dataExistsInList = false;


        for(Data data in dataList) {
          if(data.deviceName == deviceName && data.sensorAddress== sensorAddress) {
            //data = Data(typ: newData.typ, sensorAddress: newData.sensorAddress, deviceName: newData.deviceName, ts: newData.ts, t: newData.t, d: newData.d, lb: newData.lb, r: newData.r, w: newData.w);
            dataList.remove(data);
            dataList.add(newData);
            dataExistsInList = true;
            break;
          }
        }
        if(!dataExistsInList){
          dataList.add(newData);
        }


        //dataList = jsonMap1.map((val) => Data.fromJson(val)).toList();
        /*
        List jsonMap1 = json.decode(parsedMqttSettings!);
        parsedMqttSettingsList =
            jsonMap1.map((val) => UserDataSettings.fromJson(val)).toList();
         */

        debugPrint("!datalist.size: ${dataList.length}");//, encodedData dataListStr $dataList");
      }
    }


    String json1 =
        jsonEncode(dataList);
    //List jsonList = dataList.map((data) => data.toJson()).toList();
    //debugPrint("jsonList: ${json1}");

    debugPrint("encodedData data:  $json1");
    //debugPrint("datalist:  $dataList");

    preferences.setString("data_mqtt_list", json1);
    debugPrint("setting data_mqtt_list encodedData: $json1");

    return dataList;
  }

  Future setNewMqttData(List<Data> dataList) async{
    debugPrint("setting new mqtt data: $dataList");
    newMqttData = dataList;
    if(dataList != null) {
      notifyListeners();
    }
  }

  Future<List<Data>?> getNewDataList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(newMqttData == null){
      debugPrint("newMqttData == null, vzemi stari data list iz prefs");
      String? dataListStr = prefs.getString("data_mqtt_list");
      List jsonMap1 = json.decode(dataListStr!);
      List <Data> dataList =  Data.fromJsonList(jsonMap1);
      return dataList;
    }
    else{
      debugPrint("newMqttData != null");
    }
   // notifyListeners();
    return newMqttData;
  }
}
