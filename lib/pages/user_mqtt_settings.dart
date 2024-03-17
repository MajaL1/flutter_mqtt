import 'dart:async';
import 'dart:convert';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mqtt_test/model/user_data_settings.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:mqtt_test/widgets/units.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/constants.dart';
import '../model/data.dart';
import '../util/gui_utils.dart';
import '../util/utils.dart';
import '../widgets/sensor_type.dart';

class UserMqttSettings extends StatefulWidget {
  const UserMqttSettings.base({Key? key}) : super(key: key);

  @override
  State<UserMqttSettings> createState() => _UserMqttSettingsState();
}

Future<List<Data>> _getMqttData(String data) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String? decodeMessage = const Utf8Decoder().convert(data.codeUnits);
  List<Data> dataMqtt = [];

  if (preferences.getBool("isLoggedIn") != null) {
    if (preferences.getBool("isLoggedIn") == true) {
      // ali app tece v ozadju
      // if (preferences.getBool("appRunInBackground") != null) {
      // if (preferences.getBool("appRunInBackground") == true) {
      if (decodeMessage.isEmpty) {
        debugPrint("############33 get friendly name");

        decodeMessage = preferences.getString("data_mqtt_list");

        //}
        // }
      } else {
        decodeMessage = const Utf8Decoder().convert(data.codeUnits);
      }
      //debugPrint("****************** user settings data $data");
      //debugPrint("user_settings decodeMessage $decodeMessage");
      if (decodeMessage != null) {
        Map<String, dynamic> jsonMap = json.decode(decodeMessage);
        debugPrint("get mqtt data from json decode message");

        dataMqtt = Data.fromJsonList(jsonMap as List);
        return dataMqtt;
      }
    }
  }
  return dataMqtt;
}

// ustvari novo listo UserDataSettings iz Shared Preferecncea
Future<List<UserDataSettings>?> _getUserDataSettings(String data) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // debugPrint("################ _getUserDataSettings");
  String? decodeMessage = const Utf8Decoder().convert(data.codeUnits);

  /*** get new user settings list, ce je iz vecih naprav
   *  ***/

  /*if (decodeMessage.isNotEmpty) {
    Utils.currentSettingsContainNewSettings(decodeMessage, preferences);
  } */
  bool isDecode = false;
  if (preferences.getBool("isLoggedIn") != null) {
    if (preferences.getBool("isLoggedIn") == true) {
      // ali app tece v ozadju
      // if (preferences.getBool("appRunInBackground") != null) {
      // if (preferences.getBool("appRunInBackground") == true) {

      bool isDecode = false;
      if (decodeMessage.isEmpty) {
        debugPrint("get data from current_mqtt_settings");

        decodeMessage = preferences.getString("parsed_current_mqtt_settings");
        isDecode = true;
        //}
        // }
      } else {
        decodeMessage = const Utf8Decoder().convert(data.codeUnits);
      }
      //debugPrint("****************** user settings data $data");
      List<UserDataSettings> userDataSettings = [];
      //debugPrint("user_settings decodeMessage $decodeMessage");
      if (decodeMessage != null) {
        if (!isDecode) {
          // var s = json.decode(decodeMessage);
          //String s1 = s.toString();
          userDataSettings =
              UserDataSettings.getUserDataSettingsList(decodeMessage, true);
        }

        var jsonMap0 = json.decode(decodeMessage);

        // Map<String, dynamic> jsonMap = json.decode(decodeMessage);
        debugPrint("get user data from json decode message");

        userDataSettings = UserDataSettings.getUserDataSettings(jsonMap0);
        debugPrint("################ userDataSettings $decodeMessage");

       // String? deviceName = preferences.getString("settings_mqtt_device_name");
        //userDataSettings[0].deviceName = deviceName;


        _setUserDataSettings(userDataSettings, preferences);
        String userDataSettingsStr = json.encode(userDataSettings);
        preferences.setString("current_mqtt_settings", userDataSettingsStr);
        //debugPrint("################ userDataSettingsStr $userDataSettingsStr");

        return await pairOldMqttSettingsWithNew(preferences);

        //return userDataSettings;
      }
    }
  }
  return null;
}

Future<List<UserDataSettings>> pairOldMqttSettingsWithNew(
    SharedPreferences preferences) async {
  String? oldMqttSettings = preferences.getString("current_mqtt_settings");
  String? parsedMqttSettings =
      preferences.getString("parsed_current_mqtt_settings");

  List<UserDataSettings> oldMqttSettingsList = [];
  List<UserDataSettings> parsedMqttSettingsList = [];

  bool isDecode = true;
  oldMqttSettingsList =
      UserDataSettings.getUserDataSettingsList1(oldMqttSettings, true);
  if (parsedMqttSettings == null || parsedMqttSettings?.compareTo("[]") == 0) {
    //List<UserDataSettings> userDataSettings = [];
    String userDataSettingsStr = json.encode(oldMqttSettings);
    preferences.setString("parsed_current_mqtt_settings", userDataSettingsStr);
    parsedMqttSettingsList = oldMqttSettingsList;
    isDecode = false;
  } else {
    parsedMqttSettingsList =
        UserDataSettings.getUserDataSettingsList1(parsedMqttSettings, false);
  }

  // copy friendly name

  for (UserDataSettings oldSetting in oldMqttSettingsList) {
    String? friendlyNameOld = oldSetting.friendlyName;
    for (UserDataSettings newSetting in parsedMqttSettingsList) {
      if (friendlyNameOld != null && friendlyNameOld.isNotEmpty) {
        newSetting.friendlyName = friendlyNameOld;
      }
    }
  }

  // debugPrint("################ parsedMqttSettingsList $parsedMqttSettingsList");

  // ---
  return parsedMqttSettingsList;
}

void _setUserDataSettings(
    userDataSettings, SharedPreferences preferences) {

  List<String>? topicNameList = preferences.getStringList("user_topics");


  /*for (UserDataSettings userDataSetting in userDataSettings) {
    userDataSetting.deviceName = deviceName;
    userDataSetting.data = _addDataToSettings(preferences);
  } */
}

String? _addDataToSettings(SharedPreferences preferences) {
  String dataString = "";
  String? data = preferences.getString("data_list_mqtt");
  return data;
}

List<TextEditingController> _createControllerForEditSettings(
    List<UserDataSettings> editableSettingsList) {
  List<TextEditingController> editableSettingsControllerList = [];
  for (UserDataSettings editableSetting in editableSettingsList) {
    //preverjanje, katere editable vrednosti moramo dodati
    if (editableSetting.editableSetting == "hi_alarm") {
      editableSettingsControllerList
          .add(TextEditingController(text: editableSetting.hiAlarm.toString()));
    } else if (editableSetting.editableSetting == "lo_alarm") {
      editableSettingsControllerList
          .add(TextEditingController(text: editableSetting.loAlarm.toString()));
    } else {
      editableSettingsControllerList.add(TextEditingController(text: ""));
    }
  }
  return editableSettingsControllerList;
}

// parse userDataSettings v navadno listo, izloci tiste, ki jih ne prikazujemo za dolocen tip naprave
List<UserDataSettings> _parseUserDataSettingsToList(
    List<UserDataSettings> dataSettingsList) {
  // debugPrint(
  //   "###################### _parseUserDataSettingsToList $dataSettingsList");
  List<UserDataSettings> dataSettingsListNew = [];
  for (UserDataSettings setting in dataSettingsList) {
    // tipa WS in WSD imata samo hi_alarm

    String sensorType = SensorTypeConstants.getSensorType(setting.typ);

    // Hi alarm prikazi za vse senzorje
    dataSettingsListNew.add(UserDataSettings(
        deviceName: setting.deviceName,
        friendlyName: setting.friendlyName,
        sensorAddress: setting.sensorAddress,
        hiAlarm: setting.hiAlarm,
        // Todo: add data
        data: setting.data,
        //setting.data,
        u: setting.u,
        editableSetting: Constants.HI_ALARM_JSON));

    // ce ni nobeden od tipov WS ali WSD -> lo alarm  prikazi samo za WS ali WSD
    if (!(sensorType == SensorTypeConstants.WS ||
        sensorType == SensorTypeConstants.WSD)) {
      dataSettingsListNew.add(UserDataSettings(
          deviceName: setting.deviceName,
          friendlyName: setting.friendlyName,
          sensorAddress: setting.sensorAddress,
          loAlarm: setting.loAlarm,
          u: setting.u,
          editableSetting: Constants.LO_ALARM_JSON));
      debugPrint("SensorType = WS");
    }

    /*dataSettingsListNew.add(UserDataSettings(
        deviceName: setting.deviceName,
        sensorAddress: setting.sensorAddress,
        u: setting.u,
        editableSetting: Constants.U_JSON)); */
  }
  return dataSettingsListNew;
}

class _UserMqttSettingsState extends State<UserMqttSettings> {
  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);
  final debouncer = Debouncer();
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
    // SmartMqtt.instance.isSaved = false;
    SmartMqtt.instance.isSaved = false;
    debugPrint("user_settings initState");
    initializePreference();
    SharedPreferences.getInstance().then((value) {
      //value.getString("data_mqtt_list");
      //  debugPrint(
      //    "###################: ${value.getString("parsed_current_mqtt_settings")}");
    });

    // debugPrint("got Mqtt Data: $dataMqtt");
  }

  /* Widget _connectToTopic() {
    if (_connectMqtt == null) {
      _connectMqtt =
          _clientConnectToTopic(); //Container(); // here put whatever your function used to be.
    }
    return _connectMqtt!;
  } */

  @override
  Widget build(BuildContext context) {
    debugPrint("calling build method user_settings.dart");

    debugPrint("[[[[isSaved ${SmartMqtt.instance.isSaved.toString()}]]]]");
    debugPrint(
        "[[[[newSettingsMessageLoaded ${SmartMqtt.instance.newSettingsMessageLoaded.toString()}]]]]");

    // if(isSaved)
    /*String newUserSettings = SmartMqtt.instance.newUserSettings;
    setState(() {
      preferences?.setString("settings_mqtt", newUserSettings);
    }); */

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        // padding:
        //    const EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 10),
        child: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
          ),
          const Text("Device settings ",
              style: TextStyle(
                  color: Colors.black,
                  decorationColor: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const Divider(height: 10, color: Colors.transparent, thickness: 5),
          const Divider(height: 4, color: Colors.black12, thickness: 5),

          _buildMqttSettingsView(),
          /* const Padding(
           padding: EdgeInsets.symmetric(vertical: 5),
          ), */
          //_buildIntervalSpinBox(context),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          const Divider(height: 1, color: Colors.black12, thickness: 5),
          Container(height: 30),
        ]),
      ),
    );
  }

  Column _buildIntervalSpinBox(BuildContext context) {
    int value;
    return Column(
      //leading: const Icon(Icons.exit_to_app, color: Colors.black87),
      children: [
        const SizedBox(
            child: (Text("Alarm interval (in minutes)",
                style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)))),
        Row(children: [
          const SizedBox(
            width: 30,
            height: 5,
          ),
          SizedBox(
              width: 150,
              height: 50,
              child: SpinBox(
                iconSize: 18,
                value: 10,
                max: 60,
                min: 5,
                readOnly: true,
                decoration: GuiUtils.buildAlarmIntervalDecoration(),
                onChanged: (val) {
                  value = val as int;
                  debugPrint(val as String?);
                },
              )),
          SizedBox(
            width: 20,
            height: 5,
          ),
          Container(
              height: 20,
              width: MediaQuery.of(context).size.width / 5,
              margin: const EdgeInsets.only(right: 10),
              //decoration: Utils.buildSaveMqttSettingsButtonDecoration(),
              child: //SmartMqtt.instance.isSaved != true
                  ElevatedButton(
                style: GuiUtils.buildElevatedButtonSettings(),
                onPressed: () {
                  // saveInterval(value);
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              )),
        ])
      ],
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.blue, //Color.fromRGBO(0, 87, 153, 60),
      borderRadius: BorderRadius.circular(9),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 4,
          blurRadius: 5,
          offset: const Offset(0, 2), // changes position of shadow
        ),
      ],
    );
  }

  Future<String> _getNewDataList() async {
    return await Provider.of<SmartMqtt>(context, listen: true).getNewDataList();
  }

  Future<String> _getNewUserSettingsList() async {
    debugPrint("################### getNewSettingsList");

    return await Provider.of<SmartMqtt>(context, listen: true)
        .getNewUserSettingsList();
  }

  Widget _buildFriendlyNameView(friendlyName, deviceName, sensorAddress) {
    // String $settingsData = ": ";
    TextEditingController controllerFriendlyName =
        TextEditingController(text: friendlyName);
    return Column(children: [
      const Text(
        "Friendly name: ",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      Container(
          width: 120,
          height: 40,
          child: (TextFormField(
            style: const TextStyle(
                fontFamily: 'Roboto',
                color: Color.fromRGBO(00, 20, 20, 80),
                fontSize: 16),
            decoration: GuiUtils.buildFriendlyNameDecoration(),
            controller: controllerFriendlyName,
          ))),
      ElevatedButton(
        style: GuiUtils.buildElevatedButtonSettings(),
        onPressed: () {
          saveFriendlyName(
              controllerFriendlyName.text, deviceName!, sensorAddress);
        },
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ]);
  }

  /*Widget _buildDataView() {
    String $settingsData = "Data: ";

    return FutureBuilder<List<Data>>(
        future: //Provider.of<SmartMqtt>(context, listen: true)
            //.getNewUserSettingsList()
            _getNewDataList().then((dataList) => _getMqttData(dataList)),
        builder: (context, snapshot) {
          //debugPrint(
          //  "00000 snapshot.hasData: $snapshot.hasData, SmartMqtt.instance.isNewSettings: $SmartMqtt.instance.isNewSettings");
          // if (snapshot.hasData) {
          return Container(
            child: Text($settingsData,
                style: const TextStyle(color: Colors.indigo)),
          );
          // } else {
          //   return Container();
          // }
        });
  }*/

  // returns settings for hin alarm, lo alarm, ...

  Widget _buildMqttSettingsView() {
    return FutureBuilder<List<UserDataSettings>>(
      future: //Provider.of<SmartMqtt>(context, listen: true)
          //  .getNewUserSettingsList()
          _getNewUserSettingsList()
              .then(
                  (dataSettingsList) => _getUserDataSettings(dataSettingsList))
              .then((dataSettingsList) =>
                  _parseUserDataSettingsToList(dataSettingsList!)),

      // tole spodaj dela, stem da se najprej osvezi na staro vrednost, potem pa na novo
      // _getUserDataSettingsTEST(testNew).then((dataSettingsList) => _parseUserDataSettingsToList(dataSettingsList)),
      builder: (context, snapshot) {
        //debugPrint(
        //  "00000 snapshot.hasData: $snapshot.hasData, SmartMqtt.instance.isNewSettings: $SmartMqtt.instance.isNewSettings");
        if (snapshot.hasData) {
          List<UserDataSettings>? editableSettingsList = snapshot.data;
          List<TextEditingController> textControllerList =
              _createControllerForEditSettings(editableSettingsList!);
          /* debugPrint("START print editableSettingsList: ");
          for (UserDataSettings userDataSettings in editableSettingsList) {
            debugPrint(
                "// editableSetting: ${userDataSettings.deviceName}, ${userDataSettings.editableSetting}, ${userDataSettings.hiAlarm}, ${userDataSettings.hiAlarm}, ${userDataSettings.t}, $userDataSettings.typ, $userDataSettings.u");
          }
          debugPrint("END print editableSettingsList ");
          */
          return Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    UserDataSettings item = snapshot.data![index];
                    String sensorAddress =
                        snapshot.data![index].sensorAddress.toString();
                    int? u = item.u;

                    String? deviceName = snapshot.data![index].deviceName;
                    String? settingToChange = item.editableSetting ?? "";
                    String? value = "";
                    String? data = item.data;
                    String? friendlyName = item.friendlyName;

                    if (item.editableSetting == Constants.HI_ALARM_JSON) {
                      value = item.hiAlarm.toString();
                    } else if (item.editableSetting ==
                        Constants.LO_ALARM_JSON) {
                      value = item.loAlarm.toString();
                    }

                    String unitText = UnitsConstants.getUnits(u);

                    bool savePressed = false;
                    TextEditingController controller = TextEditingController();
                    TextEditingController controllerFriendlyName =
                        TextEditingController(text: friendlyName);
                    debugPrint("000000000000000 build SingleChildScroollView: sensorAddress: $sensorAddress deviceName: $deviceName ");
                    //if(sensorAddress == "135" || sensorAddress == "26") { debugPrint("container"); return Container();}

                    return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.only(
                            top: 30.0, bottom: 1.0, left: 0.0, right: 30.0),
                        child: Column(children: [
                          Container(
                              //color: Colors.tealAccent,
                              alignment: Alignment.center,
                              decoration: //index % 2 == 0
                                  //?
                              GuiUtils.buildBoxDecorationSettings(),
                                  //: null,
                              padding: const EdgeInsets.only(bottom: 0),
                              //padding: EdgeInsets.all(5),
                              child: settingToChange != "u"
                                  ? Wrap(children: [
                                     // index % 2 == 0
                                  //        ?
                                  Container(
                                              // color: Colors.red,
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(15),
                                              child: Wrap(children: [
                                                SizedBox(
                                                    // padding: EdgeInsets.all(5),
                                                    child: Wrap(children: [
                                                  const Text(
                                                    "Device: ",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  Text(
                                                    "$deviceName",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 18,
                                                      letterSpacing: 1.1,
                                                    ),
                                                  ),
                                                  _buildFriendlyNameView(
                                                      friendlyName,
                                                      deviceName,
                                                      sensorAddress),
                                                  Text(
                                                    "Data: $data",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 18,
                                                      letterSpacing: 1.1,
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 10,
                                                  ),
                                                  const SizedBox(
                                                      child: Text(
                                                          "Sensor address:  ",
                                                          style: TextStyle(
                                                              letterSpacing:
                                                                  0.8,
                                                              fontSize: 18))),
                                                  SizedBox(
                                                      child: Text(sensorAddress,
                                                          style:
                                                              const TextStyle(
                                                            letterSpacing: 0.8,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ))),
                                                  Container(
                                                    height: 10,
                                                  ),
                                                  const SizedBox(
                                                      child: Text(
                                                    "units:  ",
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  )),
                                                  SizedBox(
                                                      child: Text(
                                                    unitText,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 18,
                                                      letterSpacing: 0.8,
                                                    ),
                                                  ))
                                                ]))
                                              ]))
                                          //: const Text(""),
                                    ])
                                  : Container()),
                          Container(height: 25),
                          Wrap(children: [
                            /* const Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 10, left: 5, right: 8),
                                                      ), */
                            // Column(children: [Text("a1"), Text("a2")]),
                            settingToChange != Constants.U_JSON
                                ? _buildEditableSettingsTest2(
                                    sensorAddress,
                                    deviceName,
                                    index,
                                    u,
                                    settingToChange,
                                    value,
                                    controller,
                                    item,
                                    savePressed,
                                    textControllerList[index])
                                : Container(height: 0)
                            //ListTile(enabled: false)
                          ])
                        ]));
                  }));
        }
        /* else if (!SmartMqtt.instance.isNewSettings){// && SmartMqtt.instance.isNewSettings) {
          debugPrint("00001 !$SmartMqtt.instance.isNewSettings");
          //return const CircularProgressIndicator();

        } */
        else if (!snapshot.hasData) {
          // && SmartMqtt.instance.isNewSettings) {
          debugPrint("00000 !snapshot.hasData: !$snapshot.hasData");
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          debugPrint("00002 snapshot.hasError: $snapshot.hasError");
          // return const CircularProgressIndicator();
          return Text(snapshot.error.toString());
        }
        debugPrint(
            "00003 default: snapshot.hasData: $snapshot.hasData, $SmartMqtt.instance.isNewSettings");
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildEditableSettingsTest2(
      String sensorAddress,
      String ? deviceName,
      int index,
      int? u,
      String settingToChange,
      String value,
      TextEditingController controller,
      UserDataSettings item,
      bool savePressed,
      TextEditingController textController) {
    String settingText = "";
    bool isEnabledSave = true;
//if(sensorAddress == "135" || sensorAddress == "26") { debugPrint("container"); return Container();}
    debugPrint("00000000000000000000000000 _buildEditableSettingsTest2 sensorAddress $sensorAddress deviceName: $deviceName, settingToChange: $settingToChange, u: $u");
    if (settingToChange.compareTo(Constants.HI_ALARM_JSON) == 0) {
      settingText = " High alarm:  ";
    }
    if (settingToChange.compareTo(Constants.LO_ALARM_JSON) == 0) {
      settingText = " Low alarm:  ";
    }
    debugPrint("buildEditable...");
    return Stack(
      children: [
        Wrap(children: [
          Container(
              padding:
                  const EdgeInsets.only(top: 15, bottom: 0, left: 0, right: 0),
              //  height: 40,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 4,
              child: Text(settingText,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                      color: Colors.indigo,
                      // letterSpacing: 4,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
          //Container(width: 5),
          SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width / 5,

              child: TextFormField(
                  decoration: GuiUtils.setInputDecoration(value),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  //enableInteractiveSelection: false,
                  showCursor: false,
                  controller: textController,
                  onChanged: (val) {},
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Required value"),
                    MaxLengthValidator(6, errorText: "Value too long")
                  ]))),
          Container(width: 10),
          SizedBox(
           // height: 50,
            width: 100,
            //  margin: const EdgeInsets.only(right: 2),
            //decoration: Utils.buildSaveMqttSettingsButtonDecoration(),
            child: //ElevatedButton(
                //style: Utils.buildSaveMqttSettingsButtonDecoration1(),
                ElevatedButton(
              style: GuiUtils.buildElevatedButtonSettings(),
              onPressed: () {
                // Todo: same value - don't call save
                // Todo: debouncing
                if (!isEnabledSave) {
                  return null;
                }
                EasyDebounce.debounce(
                    'debouncer1', const Duration(milliseconds: 5000), () {
                  saveMqttSettings(deviceName!,
                      sensorAddress, item, textController, settingToChange);
                  debugPrint("executing saveMqttSettings debouncer");
                  isEnabledSave = false;
                });

                setState(() {
                  savePressed = !savePressed;
                });
              },
              child: const Text(
                Constants.SAVE_DEVICE_SETTINGS,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ) //  ?
        ]),
      ],
    );
  }

// test method with dummy parameters
/*  void saveMqttSettingsTest() {
    debugPrint("save test: ");
    MQTTConnectionManager.getInstance();
    if (MQTTAppConnectionState.connected ==
        .currentAppState.getAppConnectionState) {
// 'set:c45bbe821261:101:hi_alarm'
      var testText = "{\"135\":{\"hi_alarm\":111}}";
      widget.manager.publish(testText);
    }
  } */

  SharedPreferences? preferences;

  Future<void> initializePreference() async {
    preferences = await SharedPreferences.getInstance();
  }

  void saveMqttSettings(String deviceAddress, String? sensorName, UserDataSettings settings,
      TextEditingController controller, String settingToChange) {
    String value = controller.text;

    debugPrint(
        "saveMqttSettings: deviceName: ${deviceAddress}, sensorAddress: $sensorName, $controller.text, $sensorName, $settingToChange");
    debugPrint("::: sensorName, paramName, paramValue  $sensorName ");
    //var testText1 = "{\"135\":{\"hi_alarm\":111}}";
    var publishText = "{\"$sensorName\":{\"$settingToChange\":$value}}";
    debugPrint("concatenated text: $publishText");

    /*** ToDo: ce hocemo shraniti isto vrednost kot
        prej, potem ne klikni na gumb */
    //List <UserDataSettings> userSettings = ;
    //if(value.){

    //}

    SmartMqtt.instance.publish(publishText, deviceAddress);

    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {});
    });
    //setState(() {});
    debugPrint(
        "after publish:: saveMqttSettings: $controller.text, $sensorName, $settingToChange");
  }

  void saveInterval(String interval) {
    debugPrint("save interval...");
  }

  void saveFriendlyName(
      String friendlyName, String deviceName, String sensorAddress) async {
    debugPrint("saving friendly name...$friendlyName");

    String? mqttSettings =
        preferences?.getString("parsed_current_mqtt_settings");
    List<UserDataSettings> userDataSettingsList;
    bool isDecode = true;
    if (mqttSettings?.compareTo("[]") != 0) {
      mqttSettings = preferences?.getString("parsed_current_mqtt_settings");
      debugPrint("saving friendly name...mqttSettings $mqttSettings");
      if (mqttSettings!.contains("\\")) {
        isDecode = false;
      }
      userDataSettingsList =
          UserDataSettings.getUserDataSettingsList1(mqttSettings, isDecode);
    } else {
      mqttSettings = preferences?.getString("current_mqtt_settings");
      Map<String, dynamic> jsonMap = json.decode(mqttSettings!);
      debugPrint("get user data from json decode message");

      userDataSettingsList =
          await UserDataSettings.getUserDataSettings(jsonMap);
    }
    debugPrint("get json from preferences $userDataSettingsList");

    UserDataSettings currentSensor =
        getSensorChange(userDataSettingsList, deviceName, sensorAddress);
    currentSensor.friendlyName = friendlyName;
    debugPrint("friendlyName, changed, lise $userDataSettingsList");

    String str = json.encode(userDataSettingsList);
    //preferences?.setString(str, "parsed_current_mqtt_settings");
    preferences?.remove("parsed_current_mqtt_settings");
    preferences?.setString("parsed_current_mqtt_settings", str);
  }

  // vrne trenutni device objekt, ki ga spreminjamo
  UserDataSettings getSensorChange(List<UserDataSettings> userDataSettingsList,
      String sensorName, String deviceName) {
    UserDataSettings settings = UserDataSettings();
    for (UserDataSettings set in userDataSettingsList) {
      if (set.sensorAddress == deviceName && set.deviceName == sensorName)
        return set;
    }
    return settings;
  }
}
