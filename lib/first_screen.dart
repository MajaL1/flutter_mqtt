

import 'package:flutter/material.dart';
import 'package:mqtt_test/app_preference_util.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:mqtt_test/widgets/constants.dart';
import 'login_form.dart';
import 'alarm_history.dart';


class FirstScreen extends StatelessWidget {

  //final  sharedPref;

  //FirstScreen(this.sharedPref);
  FirstScreen();

  Future<void> logout() async {
    // ToDo: Call service
  }
  var username = SharedPrefs().username;
  var token = SharedPrefs().token;


  @override
  Widget build(BuildContext context) {
    //this.sharedPref.setString('token', "test");
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );


  print("token: "+SharedPrefs().token+", "+SharedPrefs().token == null);

   return Scaffold(

      body: SharedPrefs().token.isEmpty ? LoginForm() : MQTTView(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Login'),
        leading: IconButton(
          icon: (SharedPrefs().token
          != null) ? Icon(Icons.arrow_back) : Icon(
            Icons.notifications_none,
            color: Colors.transparent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions:SharedPrefs().token.isNotEmpty ? <Widget>[
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