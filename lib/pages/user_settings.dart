import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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

Future<List<UserDataSettings>> getUserDataSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? data = preferences.get("settings_mqtt").toString();
  String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
  debugPrint("****************** user settings data $data");
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
          widget.manager.initializeMQTTClient();
          countTest++;
          debugPrint("counter: $countTest");
          widget.manager.connect();
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
          //widget.manager.unsubscribe("_topic1");
          List<UserDataSettings>? userDataSettings = snapshot.data;
          List<TextEditingController> textEditingControllerList =
              _generateTextEditControllerList(userDataSettings!);
          debugPrint(textEditingControllerList.toString());
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                UserDataSettings item = snapshot.data![index];
                String sensorAddress = snapshot.data![index].sensorAddress.toString();

               TextEditingController controller = TextEditingController();
                debugPrint("item: $item");
                return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(
                        top: 40.0, bottom: 40.0, left: 10.0, right: 40.0),
                    child: ListView(shrinkWrap: true, children: [
                      Text(
                          "${Constants.SENSOR_ID}: ${sensorAddress.toString()}",
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
                        /*_generateTextField(
                            snapshot.data![index], Constants.DEVICE_SETTING_T) */
                        TextField(
                         // key: ValueKey("${item.sensorAddress}-${item.t}"),
                          decoration: _setInputDecoration("${item.t}"),
                          //_setInputDecoration(snapshot.data![index].t.toString()),

                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: controller,
                          onChanged: (text) {
                            debugPrint("onChanged $text");
                            debugPrint("onChanged $controller.value()");
                            //   snapshot.data![index].t.toString();
                          },
                        ),
                      ]),
                      Column(children: [
                        const Text(
                          Constants.HI_ALARM,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                        TextField(
                         // key: ValueKey("${item.sensorAddress}-${item.hiAlarm}"),
                          decoration: _setInputDecoration("${item.hiAlarm}"),
                          //_setInputDecoration(snapshot.data![index].t.toString()),

                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: controller,
                          onChanged: (text) {
                            debugPrint("onChanged $text");
                            //controllerT.text =
                            //   snapshot.data![index].t.toString();
                          },
                        ),
                        const Text(
                          Constants.LO_ALARM,
                          style: TextStyle(),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                        TextField(
                          //key: ValueKey("${item.sensorAddress}-${item.loAlarm}"),
                          decoration: _setInputDecoration("${item.loAlarm}"),
                          //_setInputDecoration(snapshot.data![index].t.toString()),

                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: controller,
                          onChanged: (text) {
                            debugPrint("onChanged $text");
                            //controllerT.text =
                            //   snapshot.data![index].t.toString();
                          },
                        ),
                      ]),
                      Container(
                        height: 30,
                        width: 50,
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10)),
                        child: TextButton(
                          onPressed: () {
                            saveMqttSettings(
                                sensorAddress,
                                item,
                                controller);
                            //saveMqttSettingsTest();
                          },
                          child: const Text(
                            Constants.SAVE_DEVICE_SETTINGS,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      )
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

  TextField _generateTextField(var snapshotItem, String type) {
    int setting = 0;
    switch (type) {
      case "t":
        setting = snapshotItem.t;
        break;
      case "hiAlarm":
        setting = snapshotItem.hiAlarm;
        break;
      case "loAlarm":
        setting = snapshotItem.loAlarm;
        break;
      case "u":
        setting = snapshotItem.u;
        break;
    }
    //debugPrint("$setting, $snapshotItem.sensorAddress");
    return TextField(
      controller:
          _returnTextEditingController(snapshotItem.sensorAddress, setting),
      decoration: _setInputDecoration(setting.toString()),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      onChanged: (text) {
        //controllerT.text =
        //   snapshot.data![index].t.toString();
      },
    );
  }

  TextEditingController getTextEditController(
      String deviceName,
      String property,
      int index,
      List<TextEditingController> textEditControllerList) {
    // Todo: najdi pravilen kontroler glede na index in parametre
    return textEditControllerList[index];
  }

  /***
   * dynamically cretes controller text name based on device name and property
   *  example: controller name: 135 ==>  135_t, 135_hiAlarm, 135_loAlarm
   * ***/ //

  // Todo: Generiraj specificen kontroler, build liste kontrolerjev

  List<TextEditingController> _generateTextEditControllerList(
      List<UserDataSettings> shapshotData) {
    List<TextEditingController> textEditControllerList = [];
    for (var deviceProp in shapshotData) {
      var sensorAddress = deviceProp.sensorAddress;

      String controllerT = "t";

      textEditControllerList.add(TextEditingController(text: controllerT));

      String controllerHiAlarm = "hiAlarm";
      textEditControllerList
          .add(TextEditingController(text: controllerHiAlarm));

      String controllerU = "u";
      textEditControllerList.add(TextEditingController(text: controllerU));

      String controllerLoAlarm = "loAlarm";
      textEditControllerList
          .add(TextEditingController(text: controllerLoAlarm));
    }
    /** kontrolerji si sledijo:
     *
     * 111_t_5
     * 111_u_8
     * 111_hiAlarm_0
     * 111_loAlarm_0
     *
     * 101_t_1
     * 111_u_0
     * 101_hiAlarm_0
     * 101_loAlarm_0
     *
     * 135_t_7
     * 111_u_8
     * 135_hiAlarm_0
     * 135_loAlarm_0
     *
     * **/

    return textEditControllerList;
  }

  // Todo: Kako posljemo vrednosti v kontrolerju

// finds specific TextEditingController
  TextEditingController _returnTextEditingController(
      String? index, int? parameter) {
    String controllerName = "$parameter";
    //debugPrint("controller: $controllerName");
    TextEditingController controller =
        TextEditingController(text: controllerName);

    return controller;
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

  void saveMqttSettings(
      String? sensorName, UserDataSettings settings, TextEditingController controller) {
    debugPrint("text editing controller: $controller.text, $settings.t, ${settings.hiAlarm}, ${settings.loAlarm}");
    debugPrint(
        "saveMqttSettings::: sensorName, paramName, paramValue  $sensorName ");
    var testText = "{\"135\":{\"hi_alarm\":111}}";
    widget.manager.publish(testText);
  }

  _setInputDecoration(val) {
    return InputDecoration(
        labelText: val,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.greenAccent, width: 5.0),
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
