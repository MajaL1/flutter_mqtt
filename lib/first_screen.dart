

import 'package:flutter/material.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:mqtt_test/widgets/shared_prefs_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_form.dart';
import 'alarm_history.dart';


class FirstScreen extends StatelessWidget {

  final SharedPreferences sharedPref;

  FirstScreen(this.sharedPref);

  @override
  Widget build(BuildContext context) {
    this.sharedPref.setString('token', Null as String);
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

 // SharedPrefUtils sharedPrefUtils = new SharedPrefUtils();

  print("token: "+sharedPref.toString());
   return Scaffold(

      body: this.sharedPref.getString("token") == null ? LoginForm() : MQTTView(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          TextButton(
            style: style,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmHistory())
                //Navigator.pushNamed(context, "/");
              );
            },
            child: const Text('History'),
          ),
          TextButton(
            style: style,
            onPressed: () {
              print("Clicked");
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserSettings())
              );
             // Navigator.pushNamed(context, '/settings');
            },
            child: const Text('Settings'),
          ),
          TextButton(
            style: style,
            onPressed: () {
              print("Clicked");
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MQTTView())
              );
            },
            child: const Text('Alarms'),
          ),
        ],
      ),
     //appBar: ,
    );
  }
}