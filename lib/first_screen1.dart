import 'package:flutter/material.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_test/noti.dart';
import 'drawer.dart';
import 'login_form.dart';

/** unused **/
class FirstScreen1 extends StatelessWidget {
  late final SharedPreferences sharedPref;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
//
  Future<void> logout() async {
    // ToDo: Call service
  }

  @override
  Widget build(BuildContext context) {
    //this.sharedPref.setString('token', "test");
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

    final SharedPreferences sharedPref = SharedPreferences.getInstance() as SharedPreferences;

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
