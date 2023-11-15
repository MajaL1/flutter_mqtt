import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_test/model/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/alarm.dart';
import '../model/constants.dart';
import '../model/user_data_settings.dart';
import '../mqtt/MQTTConnectionManager.dart';
import '../mqtt/state/MQTTAppState.dart';

class DetailsPage extends StatefulWidget {
  MQTTAppState currentAppState;
  MQTTConnectionManager manager;

  DetailsPage(MQTTAppState appState, MQTTConnectionManager connectionManager,
      {Key? key})
      : currentAppState = appState,
        manager = connectionManager,
        super(key: key);

  get appState {
    return currentAppState;
  }

  get connectionManager {
    return manager;
  }

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int countTest = 0;

  @override
  Widget build(BuildContext context) {
    {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Alarm data"),
          ),
          //drawer: NavDrawer(),
          body: _buildDetailsView());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _buildDetailsView() {

    return FutureBuilder<List<Alarm>>(
      future: getAlarmData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Alarm>? alarmList = snapshot.data;
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(
                        top: 40.0, bottom: 40.0, left: 10.0, right: 40.0),
                    child: ListView(shrinkWrap: true, children: [
                      Text(
                          "${Constants.SENSOR_ID}: ${snapshot.data![index].sensorAddress.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Text(
                          "${Constants.T}: ${snapshot.data![index].ts.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Text(
                          "${Constants.TYP}: ${snapshot.data![index].typ.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Text(
                          "${Constants.R}: ${snapshot.data![index].r.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Text(
                          "${Constants.LB}: ${snapshot.data![index].lb.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Text(
                          "${Constants.T}: ${snapshot.data![index].t.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Text(
                          "${Constants.L}: ${snapshot.data![index].l.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Text(
                          "${Constants.BV}: ${snapshot.data![index].bv.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Text(
                          "${Constants.DEVICE_SETTING_HI_ALARM}: ${snapshot.data![index].hiAlarm.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Text(
                          "${Constants.DEVICE_SETTING_LO_ALARM}: ${snapshot.data![index].loAlarm.toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Column(children: [
                        Container(
                            alignment: Alignment.bottomCenter,
                            child: const Text(" ",
                                style: TextStyle(), textAlign: TextAlign.left)),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                      ])
                    ]));
              });
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
  Future<List<Alarm>> getAlarmData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.get("data_mqtt").toString();
    String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
    debugPrint("****************** alarm data $data");
    //alarm data {"135":{"typ":7,"l":0,"t":202,"b":0,"r":-73,"lb":1,"bv":384}}
    Map<String, dynamic> jsonMap = json.decode(decodeMessage);

    List<Alarm> alarmData =
    Alarm.getAlarmList(jsonMap);
    debugPrint("AlarmData from JSON: $alarmData");

    //List<Data> dataList  = Data.getDataList();
    return alarmData;
  }
}
