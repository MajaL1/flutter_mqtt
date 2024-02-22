import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:mqtt_test/components/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/drawer.dart';
import '../model/constants.dart';
import 'login_form.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings.base({Key? key}) : super(key: key);

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
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

  @override
  Widget build(BuildContext context) {
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
        child: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
          ),
          const Divider(height: 1, color: Colors.black12, thickness: 5),
          Container(height: 30),
          const Text("General settings ",
              style: TextStyle(color: Colors.black, fontSize: 18)),
          const Divider(height: 40, color: Colors.black12, thickness: 2),
          _buildGeneralSettings(),
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

  Widget _buildGeneralSettings() {
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
              Text("  general settings", style: headingStyle),
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

        ],
      ),
    );
  }

  SharedPreferences? preferences;

  Future<void> initializePreference() async {
    preferences = await SharedPreferences.getInstance();
  }
}
