

import 'package:flutter/material.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:mqtt_test/widgets/shared_prefs_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer.dart';
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
    this.sharedPref.setString('token', "test");
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

 // SharedPrefUtils sharedPrefUtils = new SharedPrefUtils();


  print("token: "+sharedPref.get("token").toString());
   return Scaffold(

      body: this.sharedPref.getString("token") == null ? LoginForm() : MQTTView(),
      drawer: NavDrawer(),
      appBar: AppBar(
       title: Text("title"),
     ),
     //appBar: ,
    );
  }
}