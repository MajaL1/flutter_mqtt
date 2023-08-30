

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

  Future<void> logout() async {
    // ToDo: Call service
  }

  @override
  Widget build(BuildContext context) {
    //this.sharedPref.setString('token', "test");
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

 // SharedPrefUtils sharedPrefUtils = new SharedPrefUtils();


  print("token: "+sharedPref.get("token").toString());
   return Scaffold(

      body: this.sharedPref.getString("token") == null ? LoginForm(sharedPref,) : MQTTView(sharedPref),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Login'),
        leading: IconButton(
          icon: (this.sharedPref.getString("token")
          != null) ? Icon(Icons.arrow_back) : Icon(
            Icons.notifications_none,
            color: Colors.transparent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions:this.sharedPref.getString("token") != null ? <Widget>[
          TextButton(
            style: style,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmHistory(sharedPref,))
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
                  MaterialPageRoute(builder: (context) => MQTTView(sharedPref))
              );
            },
            child: const Text('Alarms'),
          ),
          TextButton(
            style: style,
            onPressed: () {
              print("Clicked");
            },
            child: const Text('Logout'),
          ),
        ]: null
        ,
      ),
     //appBar: ,
    );
  }
}