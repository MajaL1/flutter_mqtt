import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/gui_utils.dart';
import '../widgets/show_alarm_time_settings.dart';

class UserGeneralSettings extends StatefulWidget {
  const UserGeneralSettings.base({Key? key}) : super(key: key);

  @override
  State<UserGeneralSettings> createState() => _UserGeneralSettingsState();
}

class _UserGeneralSettingsState extends State<UserGeneralSettings> {
  List<String> alarmIntervalsList = Utils.buildAlarmIntervalsList();
  String? dropdownValue = "";

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
    Utils.getAlarmGeneralIntervalSettings().then((str) {
      setState(() {
        dropdownValue = str;
        Utils.setAlarmGeneralIntervalSettings(dropdownValue!);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            //alignment: WrapAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              Row(children: [
                Container(
                    child: Text("Alarm interval:",
                        style: const TextStyle(fontSize: 14)))
              ]),
              Row(children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                    decoration: GuiUtils.buildBoxDecorationInterval(),
                    child: _buildDropdownMenu()),
                Container(
                    height: 50,
                    //width: 130,
                    margin: const EdgeInsets.only(left: 10),
                    //decoration: Utils.buildSaveMqttSettingsButtonDecoration(),
                    child: //SmartMqtt.instance.isSaved != true
                        ElevatedButton(
                      style: GuiUtils.buildElevatedButtonSettings(),
                      onPressed: () {
                        String? val = dropdownValue ?? alarmIntervalsList.first;
                        saveInterval(val);
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    )),
              ]),
            ],
          ),
          const Divider(height: 20, color: Colors.transparent, thickness: 2),
        ],
      ),
    );
  }

  DropdownMenu<String> _buildDropdownMenu() {
    return DropdownMenu<String>(
      menuStyle: MenuStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.all(0)),
          visualDensity: const VisualDensity(vertical: 2, horizontal: 3)),
      //menuHeight: 30,
      textStyle: const TextStyle(color: Color.fromRGBO(20, 20, 120, 1)),
      initialSelection: (dropdownValue != null && dropdownValue!.isNotEmpty)
          ? dropdownValue
          : ShowAlarmTimeSettings.minutes10,
      onSelected: (String? value) {
        // This is called when the user selects an item.
        debugPrint("-- 1 dropdown value: $dropdownValue");

        setState(() {
          dropdownValue = value!;
        });
      },

      dropdownMenuEntries:
          alarmIntervalsList.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(
            value: value,
            label: value,
            style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.only(left: 13)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.white54),
                overlayColor: MaterialStateProperty.all<Color>(Colors.blue),
                surfaceTintColor:
                    MaterialStateProperty.all<Color>(Colors.green),
                shadowColor: MaterialStateProperty.all<Color>(Colors.black)));
      }).toList(),
    );
  }

  /* Widget _buildDropdownButtonField1(alarmIntervalList) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(30.0),
            ),
          ),
          filled: true,
          // hintStyle: TextStyle(color: Colors.grey[800]),
          //hintText: "Name",
          fillColor: Colors.blue[200]),
      value: dropdownValue,
      onChanged: (value) {
        setState(() {
          dropdownValue = value as String?;
        });
      },
      items: [],
    );

  } */

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

    debugPrint("saving interval settings.... $interval");
    /***
     * TODO: ce skenslas aplikacijo, ne dobi alarmInterval!!!
     * ko jo na novo odpres, interval ni shranjen!!
     *
     * units -> not set
     * ***/
    /*SharedPreferences.getInstance().then((value) {
      String? v = value.getString("alarm_interval_setting");
      debugPrint("v: $v");
      dropdownValue = v;
    }); */
    dropdownValue = interval;
    debugPrint(
        "dropdown value from smartMqtt ${SmartMqtt.instance.alarmInterval}");
    Utils.getAlarmGeneralIntervalSettings().then((str) {
      Utils.setAlarmGeneralIntervalSettings(interval);
      debugPrint("getting interval....$str");
    });
    debugPrint("interval saved...");
  }
}
