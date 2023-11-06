import 'dart:convert';

import 'package:flutter/material.dart';
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
            title: const Text("Test data"),
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

    return FutureBuilder<List<UserDataSettings>>(
      future: getAlarmData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<UserDataSettings>? alarmList = snapshot.data;
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
                          "${Constants.DEVICE_ID}: ${snapshot.data![index].toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Column(children: [
                        Container(
                            alignment: Alignment.bottomCenter,
                            child: const Text(Constants.T,
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
  Future<List<UserDataSettings>> getAlarmData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.get("data_mqtt").toString();
    String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
    debugPrint("****************** user settings data $data");
    Map<String, dynamic> jsonMap = json.decode(decodeMessage);

    // vrne Listo UserSettingsov iz mqtt 'sensorId/alarm'
    List<UserDataSettings> userDataSettings =
    UserDataSettings.getUserDataSettings(jsonMap);

    return userDataSettings;
    // debugPrint("UserSettings from JSON: $userSettings");
  }
}
