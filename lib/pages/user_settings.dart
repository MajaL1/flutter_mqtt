import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mqtt_test/model/user_data_settings.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/drawer.dart';
import '../model/constants.dart';
import '../widgets/sensor_type.dart';

class UserSettings extends StatefulWidget {
  const UserSettings.base({Key? key}) : super(key: key);

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

Future<List<UserDataSettings>> _getUserDataSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? data = preferences.get("settings_mqtt").toString();
  String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
  debugPrint("****************** user settings data $data");
  List<UserDataSettings> userDataSettings = [];

  // checks old user settings
  preferences.setString("settings_mqtt_old", data);
  bool? isSaved = preferences.getBool("is_mqtt_setting_saved");

  isSaved ??= false;

  Map<String, dynamic> jsonMap = json.decode(decodeMessage);
  preferences.getBool("is_mqtt_setting_saved");

  // ce smo kliknili save, potem preberi staro vrednost liste
  if (isSaved) {
    String? oldData = preferences.get("settings_mqtt_old").toString();
    String decodeMessage = const Utf8Decoder().convert(oldData.codeUnits);
    Map<String, dynamic> oldJsonMap = json.decode(decodeMessage);

    List<UserDataSettings> oldUserDataSettings =
        UserDataSettings.getUserDataSettings(oldJsonMap);

    // preberi nove user data settinge
    List<UserDataSettings> newUserDataSettings =
        UserDataSettings.getUserDataSettings(jsonMap);

    userDataSettings =
        _mergeNewUserSettingsWithOld(oldUserDataSettings, newUserDataSettings);

    preferences.setBool("is_mqtt_setting_saved", false);
  } else {
    userDataSettings = UserDataSettings.getUserDataSettings(jsonMap);
  }
  // vrne Listo UserSettingsov iz mqtt 'sensorId/settings'

  String? deviceName = preferences.getString("settings_mqtt_device_name");
  userDataSettings[0].deviceName = deviceName;

  return userDataSettings;
  // debugPrint("UserSettings from JSON: $userSettings");
}

List<UserDataSettings> _mergeNewUserSettingsWithOld(
    List<UserDataSettings> oldSettings, List<UserDataSettings> newSettings) {
  //List<UserDataSettings> mergedUserDataSettings = [];

  for (UserDataSettings newSetting in newSettings) {
    if (newSetting.hiAlarm != null) {
      for (UserDataSettings oldSetting in oldSettings) {
        if (newSetting.hiAlarm != null &&
            newSetting.hiAlarm != oldSetting.hiAlarm) {
          oldSetting.hiAlarm = newSetting.hiAlarm;
        }
        if (newSetting.loAlarm != null &&
            newSetting.loAlarm != oldSetting.loAlarm) {
          oldSetting.loAlarm = newSetting.loAlarm;
        }
      }
    }
  }
  return oldSettings;
}

List<TextEditingController> _createControllerForEditSettings(
    List<UserDataSettings> editableSettingsList) {
  List<TextEditingController> editableSettingsControllerList = [];
  for (UserDataSettings editableSetting in editableSettingsList) {
    //todo: preverjanje, katere tocne editable vrednosti moramo dodati
    String textController = "";
    if(editableSetting.editableSetting == "hi_alarm") {
      editableSettingsControllerList.add(
          TextEditingController(text: editableSetting.hiAlarm.toString()));
      }
    else if(editableSetting.editableSetting == "lo_alarm") {
      editableSettingsControllerList.add(
          TextEditingController(text: editableSetting.loAlarm.toString()));
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
        sensorAddress: setting.sensorAddress,
        hiAlarm: setting.hiAlarm,
        u: setting.u,
        editableSetting: Constants.HI_ALARM_JSON));

    // ce ni nobeden od tipov WS ali WSD -> lo alarm  prikazi samo za WS ali WSD
    if (!(sensorType == SensorTypeConstants.WS ||
        sensorType == SensorTypeConstants.WSD)) {
      dataSettingsListNew.add(UserDataSettings(
          sensorAddress: setting.sensorAddress,
          loAlarm: setting.loAlarm,
          u: setting.u,
          editableSetting: Constants.LO_ALARM_JSON));
      debugPrint("SensorType = WS");
    }

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
    debugPrint("[[[[isSaved ${SmartMqtt.instance.isSaved.toString()}]]]]");
    return Scaffold(
      //padding: const EdgeInsets.all(12),
      //alignment: Alignment.center,
      appBar: AppBar(
        title: const Text(Constants.SETTINGS),
      ),
      drawer: const NavDrawer.base(),
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
          List<UserDataSettings>? editableSettingsList = snapshot.data;
          List<TextEditingController> textControllerList = _createControllerForEditSettings(editableSettingsList!);
          debugPrint("START print editableSettingsList: ");
          for (UserDataSettings userDataSettings in editableSettingsList) {
            debugPrint("// editableSetting: ${userDataSettings.deviceName}, ${userDataSettings.editableSetting}, ${userDataSettings.hiAlarm}, ${userDataSettings.hiAlarm}, ${userDataSettings.t}, $userDataSettings.typ, $userDataSettings.u");
          }
          debugPrint("END print editableSettingsList ");

          debugPrint("START Generating editableControllerList: ");
          for (TextEditingController controller in textControllerList) {
            debugPrint("// texEditingController.text: ${controller.value}");
          }
          debugPrint("END Generating editableControllerList ");

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
                          : Container(height: 0) //ListTile(enabled: false)
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
late String text;
    TextEditingController testController = TextEditingController();
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
                  //decoration: const InputDecoration(labelText: "Context"),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly

                  ],
                  controller: testController,

                  onChanged: (val) {
                    text = val;
                    /*setState(() {
                      testController.text = val;
                    }); */
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
          Container(
              child: ChangeNotifierProvider.value(
                  value: SmartMqtt.instance,
                  child:
                      Consumer<SmartMqtt>(builder: (context, singleton, child) {
                    return Text(singleton.isSaved.toString());
                  }))),
        ],
      ),
    );
  }

// test method with dummy parameters
/*  void saveMqttSettingsTest() {
    debugPrint("save test: ");
    // ToDo: MqttConnectionManager.getCurrentAppState
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
    var testText1 = "{\"135\":{\"hi_alarm\":111}}";
    var publishText = "{\"$sensorName\":{\"$settingToChange\":$value}}";
    debugPrint("concatenated text: $publishText");

    SmartMqtt.instance.publish(publishText);

    /*  initializePreference().whenComplete(() {
        // setState(() {});
        preferences?.setBool("is_mqtt_setting_saved", true);
      }); */

    setState(() {});
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
