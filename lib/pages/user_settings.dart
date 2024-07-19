import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/components/custom_app_bar.dart';
import 'package:mqtt_test/pages/user_general_settings.dart';
import 'package:mqtt_test/pages/user_mqtt_settings.dart';
import 'package:mqtt_test/pages/user_personal_settings.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/drawer.dart';
import '../model/constants.dart';

class UserSettings extends StatefulWidget {
  const UserSettings.base({Key? key}) : super(key: key);

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);

  //final debouncer = Debouncer();
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
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("calling build method user_settings.dart");

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: CustomAppBar(Constants.SETTINGS),
      drawer: const NavDrawer.base(),
      body: const SingleChildScrollView(
        padding: EdgeInsets.only(left: 15, right: 10, top: 10),
       // scrollDirection: Axis.vertical,
      //  resizeToAvoidBottomInset: true,

        child: Column(children: <Widget>[
          // Padding(padding: EdgeInsets.symmetric(vertical: 15)),
          UserGeneralSettings.base(),
          //Divider(height: 4, color: Colors.black12, thickness: 5),
          Padding(padding: EdgeInsets.symmetric(vertical: 15)),

          UserMqttSettings.base(),
          //Divider(height: 4, color: Colors.black12, thickness: 5),

          //Divider(height: 1, color: Colors.black12, thickness: 5),
          Padding(padding: EdgeInsets.symmetric(vertical: 15)),

          UserPersonalSettings.base(),
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
          offset: const Offset(0, 2), // changes position of shadow
        ),
      ],
    );
  }

  SharedPreferences? preferences;

  Future<void> initializePreference() async {
    preferences = await SharedPreferences.getInstance();
  }

  void saveInterval() {
    debugPrint("save interval...");
  }
}
