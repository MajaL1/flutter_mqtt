import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:mqtt_test/model/user_data_settings.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:mqtt_test/widgets/units.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/constants.dart';
import '../util/gui_utils.dart';
import '../util/smart_mqtt_connect.dart';
import '../util/smart_mqtt_obj.dart';
import '../util/utils.dart';
import '../widgets/sensor_type.dart';

class UserMqttSettings extends StatefulWidget {
  const UserMqttSettings.base({Key? key}) : super(key: key);

  @override
  State<UserMqttSettings> createState() => _UserMqttSettingsState();
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
        ts: setting.ts,
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

  @override
  Widget build(BuildContext context) {
    debugPrint("calling build method user_settings.dart");

    return SingleChildScrollView(
        child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(

        color: Colors.white,
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
          //_buildIntervalSpinBox(context),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          const Divider(height: 1, color: Colors.black12, thickness: 5),
          Container(height: 30),
        ]),
      ),
    ));
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

  Widget _buildFriendlyNameView(friendlyName, deviceName, sensorAddress) {
    TextEditingController controllerFriendlyName =
        TextEditingController(text: friendlyName);
    bool isEnabledSave = false;

    ValueNotifier<bool> notifier = ValueNotifier(isEnabledSave);

    return Row(children: [
      const Text(
        "Friendly name:  ",
        style: TextStyle(
          fontSize: 14, //color: Color.fromRGBO(0, 0, 190, 1)//.shade900,
          fontWeight: FontWeight.bold,
        ),
      ),
      Wrap(children: [
        SizedBox(
            width: 150,
            height: 40,
            child: TextFormField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(00, 20, 20, 80),
                  fontSize: 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  isEnabledSave = false;
                  notifier.value = isEnabledSave;
                  return '';
                }
                if (value.length > 20) {
                  notifier.value = isEnabledSave;
                  isEnabledSave = false;
                  return '';
                }
                return null;
              },
              onChanged: (val) {
                if (val == "") {
                  isEnabledSave = false;
                  notifier.value = isEnabledSave;
                } else if (val == friendlyName && val.isNotEmpty) {
                  isEnabledSave = false;
                  notifier.value = isEnabledSave;
                } else {
                  isEnabledSave = true;
                  notifier.value = isEnabledSave;
                }
              },
              decoration: GuiUtils.setInputDecorationFriendlyName(),
              controller: controllerFriendlyName,
            )),
        Container(
          width: 10,
        ),
        ValueListenableBuilder(
            valueListenable: notifier,
            builder: (BuildContext context, bool val, Widget? child) =>
                IconButton(
                  //style: isEnabledSave
                  //   ? GuiUtils.buildElevatedButtonSettings()
                  //   : null,
                  onPressed: !notifier.value
                      ? null
                      : () {
                          saveFriendlyName(controllerFriendlyName.text,
                              deviceName!, sensorAddress);
                          isEnabledSave = false;

                          notifier.value = false;
                        },
                  icon: isEnabledSave
                      ? const Icon(
                          Icons.check,
                          size: 35,
                        )
                      : Icon(null),
                ))
      ])
    ]);
  }

  Future<List<UserDataSettings>> _checkAndPairOldSettingsWithNew(
      String newUserSettings) async {
    String? parsedCurrentMqttSettings =
        await SharedPreferences.getInstance().then((val) {
      return val.getString("parsed_current_mqtt_settings");
    });
    List<UserDataSettings> userDataSettings = [];

    // 1. ce so newUserSettings null, vrni "parsed_current_mqtt_settings"
    // to se zgodi, ko drugic, tretjic odpremo aplikacijo
    if (newUserSettings == null || newUserSettings.isEmpty) {
      List jsonMap1 = json.decode(parsedCurrentMqttSettings!);
      userDataSettings =
          jsonMap1.map((val) => UserDataSettings.fromJson(val)).toList();
      return userDataSettings;
    } else {
      // preveri, al je vsebina newUserSettings in parsedCurrentMqttSettings enaka!
      // ce je vsebina enaka, vrni dekodirane parsedCurrentMqttSettings
      if (parsedCurrentMqttSettings != null) {
        var jsonMap =
            json.decode(parsedCurrentMqttSettings!); //jsonMap.runtimeType

        List settings =
            jsonMap.map((val) => UserDataSettings.fromJson(val)).toList();
        List<UserDataSettings> parsedUserDataSettingsList =
            settings.cast<UserDataSettings>();

        debugPrint(
            "===  parsedUserDataSettingsList: $parsedUserDataSettingsList");

        // ce trenutni settingi niso prazni in ce novi settingi niso prazni
        if (newUserSettings != null) {
          List<UserDataSettings> newUserDataSettings =
              UserDataSettings.getUserDataSettingsList(newUserSettings);

          // primerjamo stare in nove settingse, dodamo friendly name na nove
          List<UserDataSettings> diffSettings = Utils.diffOldAndNewSettings(
              newUserDataSettings, parsedUserDataSettingsList);
          return diffSettings;
        }
        userDataSettings =
            UserDataSettings.getUserDataSettingsList(newUserSettings);
        SharedPreferences.getInstance().then((value) {
          var json1 = json.encode(
              List<dynamic>.from(userDataSettings.map((x) => x.toJson())));

          value.setString("parsed_current_mqtt_settings", json1);
        });
        // }
      } else {
        // ce vsebina ni enaka, vzemi  newUserSettings,
        // naredi objekt UserDataSettings in klici pairOldSettingsWithNew(zaradi friendly name)
        // ne rabimo klicati pairOldSettingsWithNew, to naredimo v
        userDataSettings =
            UserDataSettings.getUserDataSettingsList(newUserSettings);
        SharedPreferences.getInstance().then((value) {
          String str = json.encode(userDataSettings);
          var json0 = json.encode(
              List<dynamic>.from(userDataSettings.map((x) => x.toJson())));

          value.setString("parsed_current_mqtt_settings", json0);
        });
      }

      return userDataSettings;
    }
  }

  Future<String> _getNewUserSettingsList() async {
    String settings = "";
    settings = await Provider.of<SmartMqttConnect>(context, listen: true)
        .getNewUserSettingsList();
    if (settings != null) {
      return settings;
    }
    return "";
  }

  //(sensorAddress, snapshot.data!, index)
  bool getPreviousSettingToChange(
      String sensorAddress, var snapshot, int index) {
    if (index < 1) {
      return false;
    } else if (snapshot![index].sensorAddress ==
        snapshot![index - 1].sensorAddress) {
      debugPrint("getPreviousSettingToChange: true");
      return true;
    } else {
      return false;
    }
  }

  Widget _buildMqttSettingsView() {
    return FutureBuilder<List<UserDataSettings>>(
      future: //Provider.of<SmartMqtt>(context, listen: true)
          //.getNewUserSettingsList()
          _getNewUserSettingsList()
              //.then((dataSettingsList) => _getUserDataSettings(dataSettingsList))
              .then((dataSettingsList) =>
                  _checkAndPairOldSettingsWithNew(dataSettingsList))
              .then((dataSettingsList) =>
                  _parseUserDataSettingsToList(dataSettingsList!)),
      builder: (context, snapshot) {
        debugPrint(
            "00000 snapshot.connectionState: ${snapshot.connectionState}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Utils.showCircularProgressIndicator();
        }
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
              color: Colors.white,

              //color: Colors.lightBlueAccent,
              //alignment: Alignment.center,
              //decoration: BoxDecoration(border: Border(
              //  bottom: const BorderSide(color: Colors.black12, width: 8.5),
              //),),
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
                    bool previousSettingToChange = getPreviousSettingToChange(
                        sensorAddress, snapshot.data!, index);
                    String? value = "";
                    String? friendlyName = item.friendlyName;

                    if (item.editableSetting == Constants.HI_ALARM_JSON) {
                      value = item.hiAlarm.toString();
                    } else if (item.editableSetting ==
                        Constants.LO_ALARM_JSON) {
                      value = item.loAlarm.toString();
                    }

                    String unitText = UnitsConstants.getUnits(u);
                    TextEditingController controller = TextEditingController();

                    ///debugPrint("000000000000000 build SingleChildScroollView: sensorAddress: $sensorAddress deviceName: $deviceName ");
                    //if(sensorAddress == "135" || sensorAddress == "26") { debugPrint("container"); return Container();}

                    return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.only(
                            top: 30.0, bottom: 1.0, left: 0.0, right: 30.0),
                        child: Container(
                            color: Colors.white,
                            //color: Colors.blueAccent.shade100.withAlpha(5),
                            //decoration: GuiUtils.buildBoxDecorationSettings(),
                            child: Wrap(children: [
                              !previousSettingToChange
                                  ? Container(
                                      color: Colors.white70,
                                      padding: const EdgeInsets.only(
                                          left: 15, bottom: 5),
                                      alignment: Alignment.center,
                                      // This is ugly hack: previousSettingToChange
                                      child: settingToChange != "u"
                                          ? Wrap(children: [
                                              //!previousSettingToChange ?
                                              // index % 2 == 0
                                              //        ?
                                              Container(
                                                  // color: Colors.red,
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                  child: Wrap(children: [
                                                    Container(
                                                        // color:  const Color.fromRGBO(108, 165, 22, 60),
                                                        // padding: EdgeInsets.all(5),
                                                        child: Wrap(children: [
                                                      const Divider(
                                                        height: 45,
                                                        color: Colors.grey,
                                                      ),
                                                      const Text(
                                                        "Device:  ",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Roboto Regular",
                                                          fontSize: 16,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                      Text(
                                                        "$deviceName",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 16,
                                                          letterSpacing: 0.3,
                                                          //217,334, 243
                                                          backgroundColor:
                                                              Color.fromRGBO(
                                                                  226,
                                                                  239,
                                                                  250,
                                                                  95),
                                                        ),
                                                      ),
                                                      Row(children: [
                                                        const SizedBox(
                                                            child: Text(
                                                                "Sensor address:  ",
                                                                style: TextStyle(
                                                                    letterSpacing:
                                                                        0.3,
                                                                    fontSize:
                                                                        16))),
                                                        SizedBox(
                                                            child: Text(
                                                                sensorAddress,
                                                                style:
                                                                    const TextStyle(
                                                                  letterSpacing:
                                                                      0.3,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  backgroundColor:
                                                                      Color.fromRGBO(
                                                                          226,
                                                                          239,
                                                                          250,
                                                                          95),
                                                                )))
                                                      ]),
                                                      Row(children: [
                                                        const SizedBox(
                                                            child: Text(
                                                          "units:  ",
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        )),
                                                        SizedBox(
                                                            child: Text(
                                                          unitText,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 16,
                                                            letterSpacing: 0.3,
                                                          ),
                                                        ))
                                                      ]),
                                                      _buildFriendlyNameView(
                                                          friendlyName,
                                                          deviceName,
                                                          sensorAddress),
                                                    ]))
                                                  ]))
                                              //:  Text(""),
                                            ])
                                          : Text(""))
                                  : Text(""),
                              Container(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Wrap(children: [
                                    settingToChange != Constants.U_JSON
                                        ? _buildEditableSettingsTest2(
                                            sensorAddress,
                                            deviceName,
                                            index,
                                            settingToChange,
                                            value,
                                            controller,
                                            item,
                                            unitText,
                                            //savePressed,
                                            textControllerList[index])
                                        : Container(height: 0)
                                  ]))
                            ])));
                  }));
        }
        /* else if (!SmartMqtt.instance.isNewSettings){// && SmartMqtt.instance.isNewSettings) {
          debugPrint("00001 !$SmartMqtt.instance.isNewSettings");
          //return const CircularProgressIndicator();

        } */
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildEditableSettingsTest2(
      String sensorAddress,
      String? deviceName,
      int index,
      //int? u,
      String settingToChange,
      String value,
      TextEditingController controller,
      UserDataSettings item,
      String unitText,

      //bool savePressed,
      TextEditingController textController) {
    String settingText = "";
    bool isEnabledSave = false;
//if(sensorAddress == "135" || sensorAddress == "26") { debugPrint("container"); return Container();}
    // debugPrint(
    //    "00000000000000000000000000 _buildEditableSettingsTest2 sensorAddress $sensorAddress deviceName: $deviceName, settingToChange: $settingToChange");
    if (settingToChange.compareTo(Constants.HI_ALARM_JSON) == 0) {
      settingText = "High alarm ($unitText): ";
    }
    if (settingToChange.compareTo(Constants.LO_ALARM_JSON) == 0) {
      settingText = "Low alarm ($unitText): ";
    }

    ValueNotifier<bool> notifier = ValueNotifier(isEnabledSave);
    return Wrap(
      children: [
        Row(children: [
          SizedBox(
              // padding:
              // const EdgeInsets.only(top: 0, bottom: 20, left: 0, right: 0),
              //  height: 40,
              //alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 3,
              child: Text(
                settingText,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(00, 20, 20, 80),
                    fontSize: 14),
              )),
          //Container(alignment: Alignment.center, child: Text(unitText)),
          //Container(width: 5),
          SizedBox(
              //height: 50,
              width: MediaQuery.of(context).size.width / 5,
              child: TextFormField(
                  decoration: GuiUtils.setInputDecorationFriendlyName(),
                  // decoration: GuiUtils.setInputDecoration(value),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  //enableInteractiveSelection: false,
                  showCursor: false,
                  controller: textController,
                  //autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      isEnabledSave = false;
                      notifier.value = isEnabledSave;
                      return '';
                    }
                    if (value.length > 4) {
                      isEnabledSave = false;
                      notifier.value = isEnabledSave;
                      // notifier.notifyListeners();
                      return '';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    //debugPrint(
                    //    "on changed, textController.text: ${textController.text}, val: ${val}");
                    if (val == "") {
                      isEnabledSave = false;
                      notifier.value = isEnabledSave;
                    } else if (val == value) {
                      isEnabledSave = false;
                      notifier.value = isEnabledSave;
                    } else if (val.length > 4) {
                      isEnabledSave = false;
                      notifier.value = isEnabledSave;
                      //notifier.notifyListeners();
                    } else {
                      isEnabledSave = true;
                      notifier.value = isEnabledSave;
                    }
                    debugPrint("on changed, isEnabledSave: ${isEnabledSave}");
                  })),

          SizedBox(
            // height: 50,
            width: 100,
            child: Row(children: [
              //  _notifier.value ?
              ValueListenableBuilder(
                valueListenable: notifier,
                builder: (BuildContext context, bool val, Widget? child) {
                  return IconButton(
                      //style: isEnabledSave
                      //? GuiUtils.buildElevatedButtonSettings()
                      //: null,
                      icon: isEnabledSave
                          ? const Icon(
                              Icons.check,
                              size: 35,
                            )
                          : Icon(null),
                      onPressed: !notifier.value
                          ? null
                          : () {
                              saveMqttSettings(deviceName!, sensorAddress, item,
                                  textController, settingToChange);
                              isEnabledSave = false;
                              notifier.value = false;
                            });
                },
              ),
            ]),
          ),
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

  Future<SharedPreferences?> initializePreference() async {
    preferences = await SharedPreferences.getInstance();
    return preferences;
  }

  void saveMqttSettings(
      String deviceAddress,
      String? sensorName,
      UserDataSettings settings,
      TextEditingController controller,
      String settingToChange) {
    String value = controller.text;

    //debugPrint(
    //   "saveMqttSettings: deviceName: ${deviceAddress}, sensorName: $sensorName, ${controller.text}, $sensorName, $settingToChange");
    //var testText1 = "{\"135\":{\"hi_alarm\":111}}";
    var publishText = "{\"$sensorName\":{\"$settingToChange\":$value}}";
    //debugPrint("concatenated text: $publishText");

    SmartMqtt.instance.publish(publishText, "$deviceAddress/settings");

    /*Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {});
    }); */
    debugPrint(
        "after publish:: saveMqttSettings: $controller.text, $sensorName, $settingToChange");
  }

  void saveInterval(String interval) {
    debugPrint("save interval...$interval");
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
      //debugPrint("saving friendly name...mqttSettings oldSettings: $mqttSettings");
      if (mqttSettings!.contains("\\")) {
        isDecode = false;
      }
      //Map<String, dynamic> jsonMap = json.decode(mqttSettings!);
      //userDataSettingsList = UserDataSettings.getUserDataSettings(jsonMap);
      List jsonMap1 = json.decode(mqttSettings!);
      userDataSettingsList =
          jsonMap1.map((val) => UserDataSettings.fromJson(val)).toList();
    } else {
      mqttSettings = preferences?.getString("current_mqtt_settings");
      Map<String, dynamic> jsonMap = json.decode(mqttSettings!);
      // debugPrint("get user data from json decode message");

      userDataSettingsList =
          await UserDataSettings.getUserDataSettings(jsonMap);
    }
    //debugPrint("get json from preferences $userDataSettingsList");

    UserDataSettings currentSensor =
        getSensorChange(userDataSettingsList, deviceName, sensorAddress);
    currentSensor.friendlyName = friendlyName;
    debugPrint("friendlyName, changed, lise $userDataSettingsList");

    var json0 = json.encode(
        List<dynamic>.from(userDataSettingsList.map((x) => x.toJson())));

    preferences?.remove("parsed_current_mqtt_settings");
    preferences?.setString("parsed_current_mqtt_settings", json0);
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
