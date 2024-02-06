import 'dart:async';
import 'dart:convert';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:mqtt_test/components/custom_app_bar.dart';
import 'package:mqtt_test/model/user_data_settings.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:mqtt_test/widgets/units.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/drawer.dart';
import '../model/constants.dart';
import '../util/utils.dart';
import '../widgets/sensor_type.dart';
import 'login_form.dart';

class UserSettings extends StatefulWidget {
  const UserSettings.base({Key? key}) : super(key: key);

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

Future<List<UserDataSettings>?> _getUserDataSettings(String data) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String? decodeMessage = const Utf8Decoder().convert(data.codeUnits);

  // Todo, preveri, ali decode message ni null in beri zadnje settinge

  if (preferences.getBool("isLoggedIn") != null) {
    if (preferences.getBool("isLoggedIn") == true) {
      // ali app tece v ozadju
      // if (preferences.getBool("appRunInBackground") != null) {
      // if (preferences.getBool("appRunInBackground") == true) {
      if (decodeMessage.isEmpty) {
        debugPrint("get data from current_mqtt_settings");

        decodeMessage = preferences.getString("current_mqtt_settings");

        //}
        // }
      } else {
        decodeMessage = const Utf8Decoder().convert(data.codeUnits);
      }
      //debugPrint("****************** user settings data $data");
      List<UserDataSettings> userDataSettings = [];
      //debugPrint("user_settings decodeMessage $decodeMessage");
      if (decodeMessage != null) {
        Map<String, dynamic> jsonMap = json.decode(decodeMessage!);
        debugPrint("get data from json decode message");

        userDataSettings = UserDataSettings.getUserDataSettings(jsonMap);
        String? deviceName = preferences.getString("settings_mqtt_device_name");
        userDataSettings[0].deviceName = deviceName;

        return userDataSettings;
      }
    }
  }
  return null;
}

List<TextEditingController> _createControllerForEditSettings(
    List<UserDataSettings> editableSettingsList) {
  List<TextEditingController> editableSettingsControllerList = [];
  for (UserDataSettings editableSetting in editableSettingsList) {
    //todo: preverjanje, katere tocne editable vrednosti moramo dodati
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
  List<UserDataSettings> dataSettingsListNew = [];
  for (UserDataSettings setting in dataSettingsList) {
    // Todo: ce ne prikazujemo tipov za veter
    // tipa WS in WSD imata samo hi_alarm

    String sensorType = SensorTypeConstants.getSensorType(setting.typ);

    // Hi alarm prikazi za vse senzorje
    dataSettingsListNew.add(UserDataSettings(
        deviceName: setting.deviceName,
        sensorAddress: setting.sensorAddress,
        hiAlarm: setting.hiAlarm,
        u: setting.u,
        editableSetting: Constants.HI_ALARM_JSON));

    // ce ni nobeden od tipov WS ali WSD -> lo alarm  prikazi samo za WS ali WSD
    if (!(sensorType == SensorTypeConstants.WS ||
        sensorType == SensorTypeConstants.WSD)) {
      dataSettingsListNew.add(UserDataSettings(
          deviceName: setting.deviceName,
          sensorAddress: setting.sensorAddress,
          loAlarm: setting.loAlarm,
          u: setting.u,
          editableSetting: Constants.LO_ALARM_JSON));
      debugPrint("SensorType = WS");
    }

    dataSettingsListNew.add(UserDataSettings(
        deviceName: setting.deviceName,
        sensorAddress: setting.sensorAddress,
        u: setting.u,
        editableSetting: Constants.U_JSON));
  }
  return dataSettingsListNew;
}

class _UserSettingsState extends State<UserSettings> {
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

    // SchedulerBinding.instance.addPostFrameCallback((_) {
    // widget.manager.disconnect();
    // print("SchedulerBinding");
    //});
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

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      //padding: const EdgeInsets.all(12),
      //alignment: Alignment.center,
      /*appBar: AppBar(
          shadowColor: Colors.black,
          title: Container(
            //decoration: buildBoxDecoration(),
            child: const Text(
              Constants.SETTINGS,
              style: TextStyle(fontSize: 16),
            ),
          )), */
      appBar: CustomAppBar(Constants.SETTINGS),
      drawer: const NavDrawer.base(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 10),
        child: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
          ),
          const Text("Device settings ",
              style: TextStyle(
                  color: Colors.black,
                  decorationColor: Colors.blueAccent,
                  fontSize: 18)),
          const Divider(height: 4, color: Colors.black12, thickness: 5),
          _buildMqttSettingsView(),
          /* const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
          ), */
          _buildIntervalSpinBox(context),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          const Divider(height: 1, color: Colors.black12, thickness: 5),
          Container(height: 30),
          const Text("Personal settings ",
              style: TextStyle(color: Colors.black, fontSize: 18)),
          const Divider(height: 40, color: Colors.black12, thickness: 2),
          _buildUserPersonalSettings(),
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
          Container(
            width: 30,
            height: 5,
          ),
          Container(
              width: 150,
              height: 50,
              child: SpinBox(
                iconSize: 18,
                value: 10,
                max: 60,
                min: 5,
                readOnly: true,
                decoration: Utils.buildAlarmIntervalDecoration(),
                onChanged: (val) {
                  value = val as int;
                  debugPrint(val as String?);
                },
              )),
          Container(
            width: 20,
            height: 5,
          ),
          Container(
              height: 50,
              width: MediaQuery.of(context).size.width / 5,
              margin: const EdgeInsets.only(right: 10),
               //decoration: Utils.buildSaveMqttSettingsButtonDecoration(),
              child: //SmartMqtt.instance.isSaved != true
                  ElevatedButton(
                    style: Utils.buildElevatedButtonSettings(),
                onPressed: () {
                  saveInterval();
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
          offset: Offset(0, 2), // changes position of shadow
        ),
      ],
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
              Text("  Account", style: headingStyle),
            ],
          ),
          /* const ListTile(
            leading: Icon(Icons.phone),
            title: Text("Phone Number"),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.mail),
            title: Text("Email"),
          ), */
          const Divider(height: 40, color: Colors.black12, thickness: 2),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.black87),
            title: const Text("Log out",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text(
                  'Are you sure you want to log out?',
                  style: const TextStyle(fontSize: 14),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigator.pop(context, 'OK');
                      ApiService.logout();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LoginForm.base()),
                          (route) => false);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 40, color: Colors.black12, thickness: 2),
          ListTile(
            leading: const Icon(Icons.stop_circle, color: Colors.black87),
            title: const Text("Stop service",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Stop service'),
                content: const Text(
                  'Are you sure you want to stop service? \n\n No alarms will be displayed.',
                  style: const TextStyle(fontSize: 14),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'OK');
                      ApiService.stopService();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 40, color: Colors.black12, thickness: 2),
        ],
      ),
    );
  }

  Future<String> _getNewUserSettingsList() async {
    return await Provider.of<SmartMqtt>(context, listen: true)
        .getNewUserSettingsList();
  }

  Widget _buildMqttSettingsView() {
    return FutureBuilder<List<UserDataSettings>>(
      future: //Provider.of<SmartMqtt>(context, listen: true)
          //.getNewUserSettingsList()
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
                    if (item.editableSetting == Constants.HI_ALARM_JSON) {
                      value = item.hiAlarm.toString();
                    } else if (item.editableSetting ==
                        Constants.LO_ALARM_JSON) {
                      value = item.loAlarm.toString();
                    }

                    String unitText = UnitsConstants.getUnits(u);

                    bool savePressed = false;
                    TextEditingController controller = TextEditingController();
                    return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.only(
                            top: 30.0, bottom: 1.0, left: 0.0, right: 30.0),
                        child: Column(children: [
                          Container(
                              //color: Colors.tealAccent,
                              alignment: Alignment.center,
                              decoration: index == 0
                                  ? Utils.buildBoxDecorationSettings()
                                  : null,
                              padding: EdgeInsets.only(bottom: 5),
                              //padding: EdgeInsets.all(5),
                              child: Wrap(children: [
                                index == 0
                                    ? Container(
                                        // color: Colors.red,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(15),
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
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                            Row(children: [Text("\n")]),
                                            SizedBox(
                                                child: Text("Sensor address:  ",
                                                    style: const TextStyle(
                                                      letterSpacing: 0.8,
                                                    ))),
                                            SizedBox(
                                                child: Text("$sensorAddress",
                                                    style: const TextStyle(
                                                      letterSpacing: 0.8,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ))),
                                            Row(children: [Text("\n")]),
                                            const SizedBox(
                                                child: Text(
                                              "units:  ",
                                              style: TextStyle(),
                                            )),
                                            SizedBox(
                                                child: Text(
                                              "$unitText",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                letterSpacing: 0.8,
                                              ),
                                            ))
                                          ]))
                                        ]))
                                    : const Text(""),
                              ])),
                          Container(height: 40),
                          Container(
                              // color: Color.fromRGBO(104, 205, 255, 0.1),
                              child: Column(children: [
                            /* const Padding(
                              padding: EdgeInsets.only(top: 15, bottom: 10, left: 5, right: 8),
                            ), */
                            // Column(children: [Text("a1"), Text("a2")]),
                            settingToChange != Constants.U_JSON
                                ? _buildEditableSettingsTest2(
                                    sensorAddress,
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
                          ]))
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

    if (settingToChange.compareTo(Constants.HI_ALARM_JSON) == 0) {
      settingText = " High alarm:  ";
    }
    if (settingToChange.compareTo(Constants.LO_ALARM_JSON) == 0) {
      settingText = " Low alarm:  ";
    }
    return Wrap(
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold))),
          //Container(width: 5),
          SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width / 5,

              //padding: EdgeInsets.only(
              //  top: 0, bottom: 0, left: 25, right: 25),
              child: TextFormField(
                  decoration: _setInputDecoration(value),
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
          Container(
            height: 50,
            width: 100,
            //  margin: const EdgeInsets.only(right: 2),
            //decoration: Utils.buildSaveMqttSettingsButtonDecoration(),
            child: //ElevatedButton(
                //style: Utils.buildSaveMqttSettingsButtonDecoration1(),
                ElevatedButton(
                  style: Utils.buildElevatedButtonSettings(),    onPressed: () {
                // Todo: same value - don't call save
                // Todo: debouncing
                if (!isEnabledSave) {
                  return null;
                }
                EasyDebounce.debounce(
                    'debouncer1', const Duration(milliseconds: 5000), () {
                  saveMqttSettings(
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
                style: TextStyle(color: Colors.white, fontSize: 14),
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

  void saveMqttSettings(String? sensorName, UserDataSettings settings,
      TextEditingController controller, String settingToChange) {
    String value = controller.text;

    debugPrint(
        "saveMqttSettings: $controller.text, $sensorName, $settingToChange");
    debugPrint("::: sensorName, paramName, paramValue  $sensorName ");
    //var testText1 = "{\"135\":{\"hi_alarm\":111}}";
    var publishText = "{\"$sensorName\":{\"$settingToChange\":$value}}";
    debugPrint("concatenated text: $publishText");

    /*** ToDo: ce hocemo shraniti isto vrednost kot
        prej, potem ne klikni na gumb */
    //List <UserDataSettings> userSettings = ;
    //if(value.){

    //}

    SmartMqtt.instance.publish(publishText);

    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {});
    });
    //setState(() {});
    debugPrint(
        "after publish:: saveMqttSettings: $controller.text, $sensorName, $settingToChange");
  }

  _setInputDecoration(val) {
    return InputDecoration(
        labelText: val,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(14)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ));
  }

  void saveInterval() {
    debugPrint("save interval...");
  }
}
