import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_form.dart';

class UserPersonalSettings extends StatefulWidget {
  const UserPersonalSettings.base({Key? key}) : super(key: key);

  @override
  State<UserPersonalSettings> createState() => _UserPersonalSettingsState();
}

class _UserPersonalSettingsState extends State<UserPersonalSettings> {
  late SharedPreferences prefs;
  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);
  int countTest = 0;
  bool lockAppSwitchVal = true;
  bool fingerprintSwitchVal = false;
  bool changePassSwitchVal = true;
  bool serviceStopped = false;

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

  void initial() async {
    //prefs = await SharedPreferences.getInstance();
    //prefs.reload();

    prefs = await SharedPreferences.getInstance().then((val) {
      val.reload();
      setState(() {
        //debugPrint("&&&&& username: ${val.getString('username')!}");
        serviceStopped = val.getBool('serviceStopped')!;
      });
      return val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildUserPersonalSettings();
  }

  Container buildUserPersonalSettings() {
    return Container(
        child: Container(
      color: Colors.white,
      child: Column(children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
        ),
        Container(height: 20),
        const Text("Personal settings ",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Container(height: 20),
        //const Divider(height: 1, color: Colors.black12, thickness: 5),
        _buildUserPersonalSettings(),
      ]),
      // ),
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

  Widget _buildUserPersonalSettings() {
    return Container(
     // padding: const EdgeInsets.only(left: 12, right: 12, bottom: 2, top: 20),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.symmetric(horizontal:15, vertical: 15,)),

              Text("  Account", style: headingStyle),
            ],
          ), */
          const Divider(height: 20, color: Colors.black12, thickness: 2),
          ListTile(
            leading: const Icon(Icons.stop_circle, color: Colors.black87),
            title: serviceStopped
                ? const Text('Start service')
                : const Text('Stop service'),
//style: TextStyle(
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14)),
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: !serviceStopped
                    ? const Text('Stop service')
                    : const Text('Start service'),
                content: !serviceStopped
                    ? const Text(
                        'Are you sure you want to stop service? \n\n No alarms will be displayed.',
                        style: TextStyle(fontSize: 14),
                      )
                    : const Text(
                        'Are you sure you want to start service?',
                        style: TextStyle(fontSize: 14),
                      ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Cancel');
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context, 'OK');
                      if (serviceStopped) {
                        final result = await ApiService.startService();
                        if (result) {
                          setState(() {
                            serviceStopped = !serviceStopped;
                          });
                          debugPrint("will start service");
                        } else {
                          debugPrint("will start service ERROR");
                        }
                      } else {
                        try {
                          await ApiService.stopService();

                          setState(() {
                            serviceStopped = !serviceStopped;
                          });
                          debugPrint("will stop service");
                        } catch (e) {
                          debugPrint("Error stop service...");
                        }
                      }
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
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
                              builder: (context) => LoginForm.base()),
                          (route) => false);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),

          //ListTile(
          //  title: Text('Start service ${serviceStopped}'),
          //),

          const Divider(height: 40, color: Colors.black12, thickness: 2),
        ],
      ),
    );
  }

  SharedPreferences? preferences;

  Future<void> initializePreference() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    debugPrint("user-personal-settings.dart - dispose");
    super.dispose();
  }
}
