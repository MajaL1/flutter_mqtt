import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:mqtt_test/model/user_data_settings.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:mqtt_test/widgets/units.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/drawer.dart';
import '../model/constants.dart';
import '../util/utils.dart';
import '../widgets/sensor_type.dart';

class UserSettings extends StatefulWidget {
  const UserSettings.base({Key? key}) : super(key: key);

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

Future<List<UserDataSettings>?> _getUserDataSettings(String data) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
  //debugPrint("****************** user settings data $data");
  List<UserDataSettings> userDataSettings = [];
  //debugPrint("user_settings decodeMessage $decodeMessage");
  if (decodeMessage.isNotEmpty) {
    Map<String, dynamic> jsonMap = json.decode(decodeMessage);

    userDataSettings = UserDataSettings.getUserDataSettings(jsonMap);
    String? deviceName = preferences.getString("settings_mqtt_device_name");
    userDataSettings[0].deviceName = deviceName;

    return userDataSettings;
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
    debugPrint("WidgetsBinding");
    //});
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // widget.manager.disconnect();
      // print("SchedulerBinding");
    });
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
      //padding: const EdgeInsets.all(12),
      //alignment: Alignment.center,
      appBar: AppBar(

          shadowColor: Colors.black,
          title: Container(
        //decoration: buildBoxDecoration(),
        child: const Text(
          Constants.SETTINGS,
          style: TextStyle(fontSize: 16),
        ),
      )),
      drawer: const NavDrawer.base(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding:
            const EdgeInsets.only(left: 40, right: 40, top: 30, bottom: 20),
        child: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 45),
          ),
          const Text("Device settings ",
              style: TextStyle(
                  color: Colors.black,
                  decorationColor: Colors.blueAccent,
                  fontSize: 18)),
          const Divider(height: 40, color: Colors.black12, thickness: 5),
          _buildMqttSettingsView(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
          ),
          const Divider(height: 40, color: Colors.black12, thickness: 5),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          const Text("Personal settings ",
              style: TextStyle(color: Colors.black, fontSize: 18)),
          const Divider(height: 40, color: Colors.black12, thickness: 2),
          _buildUserPersonalSettings(),
        ]),
      ),
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
              onTap: () {
                ApiService.logout();
              }),
          const Divider(height: 40, color: Colors.black12, thickness: 2),
          /*Row(
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
          ), */
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
        debugPrint(
            "00000 snapshot.hasData: $snapshot.hasData, SmartMqtt.instance.isNewSettings: $SmartMqtt.instance.isNewSettings");
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

                String? deviceName = snapshot.data![index].deviceName;
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
                      Container(
                          //padding: EdgeInsets.all(5),
                          child: Row(children: [
                        index == 0
                            ? Container(
                                //padding: EdgeInsets.all(5),

                                child: Row(children: [
                                Container(
                                    padding: EdgeInsets.all(5),
                                    child: Column(children: [
                                      Text(
                                        "Device: ",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      Text(
                                        "$deviceName",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Text("\n"),
                                      Column(
                                          // padding: EdgeInsets.only(bottom: 15),

                                          children: [
                                            Text(
                                                "sensor address: $sensorAddress, units: $u"),
                                            Text("\n"),
                                          ])
                                    ]))
                              ]))
                            : const Text(""),
                      ])),
                      Container(
                          color: Color.fromRGBO(104, 205, 255, 0.1),
                          child: Column(children: [
                            /* const Padding(
                              padding: EdgeInsets.only(top: 15, bottom: 10, left: 5, right: 8),
                            ), */
                            // Column(children: [Text("a1"), Text("a2")]),
                            settingToChange != Constants.U_JSON
                                ? _buildEditableSettingsItem1(
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
              });
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

  ListTile _buildEditableSettingsItem(
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

    String unitText = UnitsConstants.getUnits(u);

    if (settingToChange.compareTo(Constants.HI_ALARM_JSON) == 0) {
      settingText = "High alarm:  ";
    }
    if (settingToChange.compareTo(Constants.LO_ALARM_JSON) == 0) {
      settingText = "Low alarm:  ";
    }
    return ListTile(
      title: index == 0
          ? Text(
              "Sensor address: $sensorAddress, units: $unitText \n",
              maxLines: 2,
            )
          : Container(), //Text("", maxLines: 1),
      contentPadding:
          const EdgeInsets.only(left: 20, right: 10, top: 0, bottom: 0),
      /*leading: Text(
        "Sensor address: $sensorAddress",
      ),*/

      subtitle: Row(
        children: <Widget>[
          Text(
            settingText,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10.0),
          ),
          Container(
              height: 50,
              width: 90,
              child: TextFormField(
                  style: TextStyle(
                      backgroundColor: Colors.white, color: Colors.white),
                  decoration: _setInputDecoration(value),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  enableInteractiveSelection: false,
                  // showCursor: false,
                  controller: textController,
                  onChanged: (val) {},
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Required value"),
                    MaxLengthValidator(6, errorText: "Value too long")
                  ]))),
          const Padding(
            padding: EdgeInsets.only(right: 10.0),
          ),
          Container(
              height: 50,
              width: 70,
              // margin: const EdgeInsets.only(top: 20),
              decoration: Utils.buildBoxDecoration(),
              child: //SmartMqtt.instance.isSaved != true
                  //  ?
                  TextButton(
                onPressed: () {
                  saveMqttSettings(
                      sensorAddress, item, textController, settingToChange);
                  setState(() {
                    savePressed = !savePressed;
                  });
                  //saveMqttSettingsTest();
                },
                child: const Text(
                  Constants.SAVE_DEVICE_SETTINGS,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              )
              /* : IconButton(
                    icon: const Icon(Icons.access_alarm_outlined),
                    onPressed: () {},

                  ),*/
              ),
          /*SmartMqtt.instance.isSaved == true
              ? Text("=saved")
              : Text("=not saved"), */
          //Text("aa")
          /*
          ChangeNotifierProvider.value(
              value: SmartMqtt.instance,
              child: Consumer<SmartMqtt>(builder: (context, singleton, child) {
                return Text(singleton.isSaved.toString());
              })),
              */
        ],
      ),
    );
  }

  Widget _buildEditableSettingsItem1(
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

    String unitText = UnitsConstants.getUnits(u);

    if (settingToChange.compareTo(Constants.HI_ALARM_JSON) == 0) {
      settingText = " High alarm:  ";
    }
    if (settingToChange.compareTo(Constants.LO_ALARM_JSON) == 0) {
      settingText = " Low alarm:  ";
    }
    return Container(
        width: 400,
        child: Table(
          /*  title: index == 0
          ? Text(
        "Sensor address: $sensorAddress, units: $unitText \n",
        maxLines: 2,
      )
          : Container(), //Text("", maxLines: 1),
      contentPadding:
      const EdgeInsets.only(left: 20, right: 10, top: 0, bottom: 0),
      */
          children: [
            index == 0
                ? TableRow(children: [
                    /* Container(
                        width: 300,
                        child: Column(children: [
                          Text("sensor address: $sensorAddress , units: $u")
                        ])), */
                    Container(width: 0),
                    Container(width: 0),
                    Container(
                      width: 0,
                    )
                  ])
                : TableRow(children: [
                    Container(width: 0),
                    Container(width: 0),
                    Container(width: 0)
                  ]),
            TableRow(
                /* decoration: const BoxDecoration(
                    border: Border(
                  top: BorderSide(color: Colors.black),
                  left: BorderSide(color: Colors.black),
                  right: BorderSide(color: Colors.black),
                  bottom: BorderSide(color: Colors.black),
                )), */
                children: [
                  Container(
                      padding: EdgeInsets.only(
                          top: 15, bottom: 0, left: 5, right: 5),
                      width: 300,
                      child: Text(settingText,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                              color: Colors.indigo,
                              // letterSpacing: 4,
                              fontSize: 14,
                              fontWeight: FontWeight.bold))),
                  Container(
                      height: 50,
                      width: 70,
                      padding: EdgeInsets.only(
                          top: 0, bottom: 0, left: 25, right: 25),
                      child: TextFormField(
                          decoration: _setInputDecoration(value),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          enableInteractiveSelection: false,
                          // showCursor: false,
                          controller: textController,
                          onChanged: (val) {},
                          validator: MultiValidator([
                            RequiredValidator(errorText: "Required value"),
                            MaxLengthValidator(6, errorText: "Value too long")
                          ]))),
                  Container(
                      height: 50,
                      width: 20,
                      margin: const EdgeInsets.only(right: 40),
                      decoration: Utils.buildBoxDecoration(),
                      child: //SmartMqtt.instance.isSaved != true
                          //  ?
                          TextButton(
                        onPressed: () {
                          saveMqttSettings(sensorAddress, item, textController,
                              settingToChange);
                          setState(() {
                            savePressed = !savePressed;
                          });
                        },
                        child: const Text(
                          Constants.SAVE_DEVICE_SETTINGS,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      )),
                ]),
          ],
        ));
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
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 3.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ));
  }
}
