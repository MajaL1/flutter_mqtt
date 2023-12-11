import 'package:flutter/material.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_form.dart';

class FirstScreen extends StatefulWidget {
  FirstScreen.base({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  bool? isLoggedIn; //SmartMqtt.instance.userIsLoggedIn;

  Future<bool?> getLoggedInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setBool("isLoggedIn", false);
    var isLoggedIn;
    if (prefs.getBool("isLoggedIn") == null) {
      return false;
    }
    return prefs.getBool("isLoggedIn");

    return isLoggedIn;
  }

  @override
  initState() {
    super.initState();
    debugPrint("-- firstScreen initstate");
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint("token: $SharedPrefs().token, ${SharedPrefs().token}");
    debugPrint("isLoggedIn: $isLoggedIn");
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
                    body: (snapshot.data == true
                        ? LoginForm.base()
                        : UserSettings.base()));
                //body: LoginForm.base());
              }
            }));
  }
}
