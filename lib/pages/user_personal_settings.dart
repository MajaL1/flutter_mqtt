import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:mqtt_test/components/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/drawer.dart';
import '../model/constants.dart';
import 'login_form.dart';

class UserPersonalSettings extends StatefulWidget {
  const UserPersonalSettings.base({Key? key}) : super(key: key);

  @override
  State<UserPersonalSettings> createState() => _UserPersonalSettingsState();
}

class _UserPersonalSettingsState extends State<UserPersonalSettings> {
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
          offset: const Offset(0, 2), // changes position of shadow
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
                  style: TextStyle(fontSize: 14),
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
                  style: TextStyle(fontSize: 14),
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

  SharedPreferences? preferences;

  Future<void> initializePreference() async {
    preferences = await SharedPreferences.getInstance();
  }
}