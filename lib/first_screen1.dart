import 'package:flutter/material.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_test/noti.dart';
import 'drawer.dart';
import 'login_form.dart';


class FirstScreen extends StatelessWidget {
  final SharedPreferences sharedPref;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
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

    print("token1: " + sharedPref.get("token").toString());
    return Scaffold(
      body:
          this.sharedPref.getString("token") == null ? LoginForm() : MQTTView(),
      drawer: NavDrawer(),
      appBar: this.sharedPref.getString("token") != null ? AppBar(
        title: Text("Login"))
           : null
      //appBar: ,
    );
  }
}
