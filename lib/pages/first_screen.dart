import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mqtt_test/model/alarm.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_form.dart';

class FirstScreen extends StatefulWidget {
  late FlutterBackgroundService service;

  FirstScreen.base({Key? key}) : super(key: key);

  FirstScreen.base1(FlutterBackgroundService service, {Key? key}) :  super(key: key) {
    service = service;
  }
  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  late bool isLoggedIn;

  @override
  initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      if (value.getBool("isLoggedIn") != null) {
        return value.getBool("isLoggedIn")!;
      }
    });
    debugPrint("-- firstScreen initstate");
  }

  Future<bool?> getLoggedInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setBool("isLoggedIn", false);
    if (prefs.getBool("isLoggedIn") == null) {
      isLoggedIn = false;
    } else {
      isLoggedIn = true;
    }
    return true; // prefs.getBool("isLoggedIn");

    //return isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint("token: $SharedPrefs().token, ${SharedPrefs().token}");
    //debugPrint("isLoggedIn: $isLoggedIn");
    return Scaffold(
        body: FutureBuilder(
            future: getLoggedInState(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Scaffold(
                    body: !isLoggedIn
                        ? const LoginForm.base()
                        : const AlarmHistory());
                //  : UserSettings.base()));
                //body: LoginForm.base());
              }
            }));
  }
}
