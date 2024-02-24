import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/model/alarm_interval_setting.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:mqtt_test/widgets/show_alarm_time_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/gui_utils.dart';

class UserGeneralSettings extends StatefulWidget {
  const UserGeneralSettings.base({Key? key}) : super(key: key);

  @override
  State<UserGeneralSettings> createState() => _UserGeneralSettingsState();
}

class _UserGeneralSettingsState extends State<UserGeneralSettings> {
  List<String> alarmIntervalsList = _buildAlarmIntervalsList();
  String ? dropdownValue = "";

  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);

  TextStyle headingStyleIOS = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: CupertinoColors.inactiveGray,
  );
  TextStyle descStyleIOS = const TextStyle(color: CupertinoColors.inactiveGray);

  @override
  void initState() {
    super.initState();

  }

  static List<String> _buildAlarmIntervalsList() {
    List<String> alarmIntervalList = [];

    alarmIntervalList.add(ShowAlarmTimeSettings().minutes10);
    alarmIntervalList.add(ShowAlarmTimeSettings().minutes30);
    alarmIntervalList.add(ShowAlarmTimeSettings().hour);
    alarmIntervalList.add(ShowAlarmTimeSettings().hour6);
    alarmIntervalList.add(ShowAlarmTimeSettings().hour12);
    alarmIntervalList.add(ShowAlarmTimeSettings().all);
    alarmIntervalList.add(ShowAlarmTimeSettings().changeOnly);

    return alarmIntervalList;
  }

  @override
  Widget build(BuildContext context) {
    Utils.getAlarmGeneralIntervalSettings().then((str){
      debugPrint("getting interval initstate ....$str");
      dropdownValue = str;
    });
    return buildUserGeneralSettings();

  }

  SingleChildScrollView buildUserGeneralSettings() {
    return SingleChildScrollView(
      //body: SingleChildScrollView(
      child: Column(children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
        ),
        // const Divider(height: 1, color: Colors.black12, thickness: 5),
        Container(height: 30),
        const Text("General settings ",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        const Divider(height: 14, color: Colors.transparent, thickness: 5),

        const Divider(height: 4, color: Colors.black12, thickness: 5),
        _buildUserGeneralSettings(),
      ]),
      // ),
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

  Widget _buildUserGeneralSettings() {
    debugPrint("-- 0 dropdown value: $dropdownValue");
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 15),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              Container(
                  child: Text(" Show alarm interval:", style: headingStyle)),
              Container(),
              Container(
                  child: DropdownMenu<String>(
                menuStyle: MenuStyle(),
                initialSelection: dropdownValue,
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  debugPrint("-- 1 dropdown value: $dropdownValue");

                  setState(() {
                    dropdownValue = value!;
                  });
                },
                dropdownMenuEntries: alarmIntervalsList
                    .map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              )),
              Row(),
              Container(
                height: 20,
              ),
              Container(
                  height: 50,
                  width: 130,
                  margin: const EdgeInsets.only(right: 10),
                  //decoration: Utils.buildSaveMqttSettingsButtonDecoration(),
                  child: //SmartMqtt.instance.isSaved != true
                      ElevatedButton(
                    style: GuiUtils.buildElevatedButtonSettings(),
                    onPressed: () {
                      saveInterval(dropdownValue!);
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  )),
            ],
          ),
          const Divider(height: 20, color: Colors.transparent, thickness: 2),
        ],
      ),
    );
  }

  SharedPreferences? preferences;

  Future<void> initializePreference() async {
    preferences = await SharedPreferences.getInstance();
  }

  void saveInterval(String interval) {

    /*Utils.getAlarmIntervalSettingsList().then((list){
      if(list != null){
        for (AlarmIntervalSetting setting in list){

        }
      }
    }); */

    debugPrint("setting interval....");
    Utils.setAlarmGeneralIntervalSettings(interval);

    SharedPreferences.getInstance().then((value){
      String ? v = value.getString("alarm_interval_setting");
      debugPrint("v: $v");
      dropdownValue = v;
    });

    Utils.getAlarmGeneralIntervalSettings().then((str){
      debugPrint("getting interval....$str");
    });
    debugPrint("interval saved...");

  }
}
