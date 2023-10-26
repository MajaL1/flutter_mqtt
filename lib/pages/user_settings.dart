import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_test/model/user_data_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mqtt/MQTTConnectionManager.dart';
import '../mqtt/state/MQTTAppState.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({Key? key}) : super(key: key);

  const UserSettings.base();

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

Future<List<UserDataSettings>> getUserDataSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? data = preferences.get("settings_mqtt").toString();
  String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
  print("****************** data $data");
  Map<String, dynamic> jsonMap = json.decode(decodeMessage);

  // vrne Listo UserSettingsov iz mqtt 'sensorId/alarm'
  List<UserDataSettings> userDataSettings =
      UserDataSettings.getUserDataSettings(jsonMap);
  return userDataSettings;
  // debugPrint("UserSettings from JSON: $userSettings");
}

class _UserSettingsState extends State<UserSettings> {
  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red);

  bool lockAppSwitchVal = true;
  bool fingerprintSwitchVal = false;
  bool changePassSwitchVal = true;

  TextStyle headingStyleIOS = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: CupertinoColors.inactiveGray,
  );
  TextStyle descStyleIOS = const TextStyle(color: CupertinoColors.inactiveGray);

  final TextEditingController controllerT = TextEditingController();
  final TextEditingController controllerHiAlarm = TextEditingController();
  final TextEditingController controllerLoAlarm = TextEditingController();

  String value = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //padding: const EdgeInsets.all(12),
      //alignment: Alignment.center,
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(top: 30, bottom: 20),
        child: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 35),
          ),
          const Text("Device settings: ",
              style: TextStyle(color: Colors.black, fontSize: 20)),
          _buildMqttSettingsView(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 35),
          ),
          const Text("Personal settings: ",
              style: TextStyle(color: Colors.black, fontSize: 20)),
          _buildUserPersonalSettings(),
        ]),
      ),
    );
  }

  Widget _buildUserPersonalSettings() {
    return Container(
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Common",
                style: headingStyle,
              ),
            ],
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text("Language"),
            subtitle: Text("English"),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.cloud),
            title: Text("Environment"),
            subtitle: Text("Production"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Account", style: headingStyle),
            ],
          ),
          const ListTile(
            leading: Icon(Icons.phone),
            title: Text("Phone Number"),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.mail),
            title: Text("Email"),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Sign Out"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Security", style: headingStyle),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.phonelink_lock_outlined),
            title: const Text("Lock app in background"),
            trailing: Switch(
                value: lockAppSwitchVal,
                activeColor: Colors.redAccent,
                onChanged: (val) {
                  setState(() {
                    lockAppSwitchVal = val;
                  });
                }),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text("Use fingerprint"),
            trailing: Switch(
                value: fingerprintSwitchVal,
                activeColor: Colors.redAccent,
                onChanged: (val) {
                  setState(() {
                    fingerprintSwitchVal = val;
                  });
                }),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            trailing: Switch(
                value: changePassSwitchVal,
                activeColor: Colors.redAccent,
                onChanged: (val) {
                  setState(() {
                    changePassSwitchVal = val;
                  });
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Misc", style: headingStyle),
            ],
          ),
          const ListTile(
            leading: Icon(Icons.file_open_outlined),
            title: Text("Terms of Service"),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.file_copy_outlined),
            title: Text("Open Source and Licences"),
          ),
        ],
      ),
    );
  }

  Widget _buildMqttSettingsView() {
    return FutureBuilder<List<UserDataSettings>>(
      future: getUserDataSettings(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
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
                    child: Table(
                      columnWidths: const {
                        0: FractionColumnWidth(0.99),
                      },
                      children: [
                        TableRow(
                            //decoration: ,
                            children: [
                              Table(
                                children: [
                                  TableRow(children: <Widget>[
                                    Text(
                                        "Id: ${snapshot.data![index].sensorAddress.toString()}",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        textAlign: TextAlign.justify),
                                    Container(
                                        alignment: Alignment.bottomCenter,
                                        child: const Text("T: ",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16),
                                            textAlign: TextAlign.justify)),
                                    TextField(
                                      controller: controllerT,
                                      decoration: _setInputDecoration(
                                          snapshot.data![index].t.toString()),
                                      onChanged: (text) {
                                        controllerT.text =
                                            snapshot.data![index].t.toString();
                                      },
                                    ),
                                    const Text("Hi alarm:"),
                                    TextField(
                                      controller: controllerHiAlarm,
                                      decoration: _setInputDecoration(snapshot
                                          .data![index].hiAlarm
                                          .toString()),
                                      onChanged: (text) {
                                        controllerHiAlarm.text = snapshot
                                            .data![index].hiAlarm
                                            .toString();
                                      },
                                    ),
                                    const Text(
                                      "Lo alarm:",
                                      style: TextStyle(),
                                    ),
                                    TextField(
                                      controller: controllerLoAlarm,

                                      decoration: _setInputDecoration(snapshot
                                          .data![index].loAlarm
                                          .toString()),
                                      // labelText: data![index].loAlarm,,
                                      onChanged: (text) {
                                        controllerLoAlarm.text = snapshot
                                            .data![index].loAlarm
                                            .toString();
                                      },
                                    ),
                                  ]),
                                ],
                              ),
                            ]),
                        TableRow(children: [
                          TableCell(
                              child: Container(
                            height: 30,
                            width: 50,
                            margin: EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10)),
                            child: TextButton(
                              onPressed: () {
                                saveMqttSettings();
                              },
                              child: const Text(
                                'Save device settings',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ))
                        ])
                      ],
                    ));
              });
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  void saveMqttSettings() {
    var t = controllerT.text;
    var hiAlarm = controllerHiAlarm.text;
    var loAlarm = controllerLoAlarm.text;

    debugPrint("t, hiAlarm, loAlarm $t, $hiAlarm, $loAlarm");
  }

  _setInputDecoration(val) {
    return InputDecoration(
        labelText: val,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.greenAccent, width: 5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ));
  }

  Future<void> saveUserSettings() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //var password = passwordController.text;
    debugPrint("Save user settings");

    /** pridobivanje iz settingsov **/

    // ali je mqtt state connected?
    // kako dobimo connected state?
    // verjetno je potrebno to dodati nekam na shared memory
    //if (MQTTAppConnectionState.connected ==  // currentAppState.getAppConnectionState) {
    //MQTTConnectionManager.publish("100");
    //String t = await currentAppState.getHistoryText;

    //print("****************** $t");

    //this.publish('topic');
  }
}
