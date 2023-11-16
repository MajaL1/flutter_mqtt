import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mqtt_test/model/user_data_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/drawer.dart';
import '../model/constants.dart';
import '../mqtt/MQTTConnectionManager.dart';
import '../mqtt/state/MQTTAppState.dart';

class UserSettings extends StatefulWidget {
  MQTTAppState currentAppState;
  MQTTConnectionManager manager;

  UserSettings(MQTTAppState appState, MQTTConnectionManager connectionManager,
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
  State<UserSettings> createState() => _UserSettingsState();
}

Future<List<UserDataSettings>> _getUserDataSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? data = preferences.get("settings_mqtt").toString();
  String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
  debugPrint("****************** user settings data $data");
  Map<String, dynamic> jsonMap = json.decode(decodeMessage);

  // vrne Listo UserSettingsov iz mqtt 'sensorId/settings'
  List<UserDataSettings> userDataSettings =
      UserDataSettings.getUserDataSettings(jsonMap);

  return userDataSettings;
  // debugPrint("UserSettings from JSON: $userSettings");
}

// parse userDataSettings v navadno listo, izloci tiste, ki jih ne prikazujemo za dolocen tip naprave
List<UserDataSettings> _parseUserDataSettingsToList(
    List<UserDataSettings> dataSettingsList) {
  List<UserDataSettings> dataSettingsListNew = [];
  for (UserDataSettings setting in dataSettingsList) {
    // Todo: ce ne prikazujemo tipov za veter
    //if(setting.equals(Constants.HI_ALARM)){} // if ne prikazi tipa za veter, prikazi samo hiAlarm in loAlarm
    dataSettingsListNew.add(UserDataSettings(
        sensorAddress: setting.sensorAddress,
        hiAlarm: setting.hiAlarm,
        u: setting.u,
        editableSetting: Constants.HI_ALARM_JSON));
    // if(){} // prikazi za loAlarm
    dataSettingsListNew.add(UserDataSettings(
        sensorAddress: setting.sensorAddress,
        loAlarm: setting.loAlarm,
        u: setting.u,
        editableSetting: Constants.LO_ALARM_JSON));
    dataSettingsListNew.add(UserDataSettings(
        sensorAddress: setting.sensorAddress,
        u: setting.u,
        editableSetting: Constants.U_JSON));
  }
  return dataSettingsListNew;
}

class _UserSettingsState extends State<UserSettings> {
  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red);

  Widget? _connectMqtt;
  int countTest = 0;
  bool lockAppSwitchVal = true;
  bool fingerprintSwitchVal = false;
  bool changePassSwitchVal = true;

  TextStyle headingStyleIOS = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: CupertinoColors.inactiveGray,
  );
  TextStyle descStyleIOS = const TextStyle(color: CupertinoColors.inactiveGray);

  @override
  void initState() {
    super.initState();
    debugPrint("user_settings initState");
    //_connectToTopic();
    //WidgetsBinding.instance.addPostFrameCallback((_) {
    // widget.manager.unsubscribe("_topic1");
    // widget.manager.disconnect();
    // skonekta se na managerja
    //widget.manager.initializeMQTTClient();
    //widget.manager.connect();
    print("WidgetsBinding");
    //});
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // widget.manager.disconnect();
      // print("SchedulerBinding");
    });
  }

  // this is hack to ensure method is executed only once
  Container _clientConnectToTopic() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          //widget.manager.initializeMQTTClient();
          countTest++;
          debugPrint("counter: $countTest");
          //widget.manager.connect();
        }));
    return Container();
  }

  Widget _connectToTopic() {
    if (_connectMqtt == null) {
      _connectMqtt =
          _clientConnectToTopic(); //Container(); // here put whatever your function used to be.
    }
    return _connectMqtt!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //padding: const EdgeInsets.all(12),
      //alignment: Alignment.center,
      appBar: AppBar(
        title: const Text(Constants.SETTINGS),
      ),
      drawer: NavDrawer(widget.currentAppState, widget.manager),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(top: 30, bottom: 20),
        child: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 45),
          ),
          const Text("Device settings: ",
              style: TextStyle(color: Colors.black, fontSize: 20)),
          _buildMqttSettingsView(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
          ),
          const Divider(height: 40, color: Colors.black12, thickness: 5),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
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
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 20),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
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
            title: Text("Log out",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
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
      future: _getUserDataSettings().then(
          (dataSettingsList) => _parseUserDataSettingsToList(dataSettingsList)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //widget.manager.unsubscribe("_topic1");
          List<UserDataSettings>? userDataSettings = snapshot.data;
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                UserDataSettings item = snapshot.data![index];
                String sensorAddress =
                    snapshot.data![index].sensorAddress.toString();
                int? u = item.u;

                String? settingToChange = item.editableSetting ?? "";
                String? value = "";
                if (item.editableSetting == Constants.HI_ALARM_JSON) {
                  value = item.hiAlarm.toString();
                } else if (item.editableSetting == Constants.LO_ALARM_JSON) {
                  value = item.loAlarm.toString();
                }
                bool savePressed = false;
                TextEditingController controller = TextEditingController();
                return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(
                        top: 40.0, bottom: 1.0, left: 10.0, right: 40.0),
                    child: Column(children: [
                      settingToChange != Constants.U_JSON
                          ? _buildEditableSettingsItem(
                              sensorAddress,
                              u,
                              settingToChange,
                              value,
                              controller,
                              item,
                              savePressed)
                          : Container(height: 0)//ListTile(enabled: false)
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

  ListTile _buildEditableSettingsItem(
      String sensorAddress,
      int? u,
      String settingToChange,
      String value,
      TextEditingController controller,
      UserDataSettings item,
      bool savePressed) {
    return ListTile(
      title: Text("Sensor address: $sensorAddress, u:  $u \n"),
      //leading: Text(
      //  "Sensor address: $sensorAddress",
      // ),
      subtitle: Row(
        children: <Widget>[
          Text(
            settingToChange,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10.0),
          ),
          Expanded(
              child: TextFormField(
                  decoration: _setInputDecoration(value),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: controller,
                  onChanged: (text) {
                    debugPrint("onChanged $text");
                     text = value!;
                  },
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Required value"),
                    MaxLengthValidator(6, errorText: "Value too long")
                  ]))),
          const Padding(
            padding: EdgeInsets.only(right: 10.0),
          ),
          Container(
            height: 60,
            width: 60,
            // margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(10)),
            child: TextButton(
              onPressed: () {
                saveMqttSettings(
                    sensorAddress, item, controller, settingToChange);
                setState(() {
                  savePressed = !savePressed;
                });
                //saveMqttSettingsTest();
              },
              child: const Text(
                Constants.SAVE_DEVICE_SETTINGS,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

// test method with dummy parameters
  void saveMqttSettingsTest() {
    debugPrint("save test: ");
    if (MQTTAppConnectionState.connected ==
        widget.currentAppState.getAppConnectionState) {
// 'set:c45bbe821261:101:hi_alarm'
      var testText = "{\"135\":{\"hi_alarm\":111}}";
      widget.manager.publish(testText);
    }
    setState(() {});
  }

  void saveMqttSettings(String? sensorName, UserDataSettings settings,
      TextEditingController controller, String settingToChange) {
    String value = controller.text;

    debugPrint(
        "saveMqttSettings: $controller.text, $sensorName, $settingToChange");
    debugPrint("::: sensorName, paramName, paramValue  $sensorName ");
    var testText1 = "{\"135\":{\"hi_alarm\":111}}";
    var testText = "{\"$sensorName\":{\"$settingToChange\":$value}}";
    debugPrint("concatenated text: $testText");
    widget.manager.publish(testText);
  }

  _setInputDecoration(val) {
    return InputDecoration(
        labelText: val,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 3.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ));
  }

  Future<void> saveUserSettings() async {
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

  Future<void> setCurrentAppState(appState) async {
    widget.currentAppState = appState;
  }

  Future<void> setManager(manager) async {
    widget.manager = manager;
  }
}
