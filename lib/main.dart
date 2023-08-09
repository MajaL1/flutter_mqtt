import 'dart:js';
import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:mqtt_test/alarm_history.dart';
import 'package:mqtt_test/first_screen.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'login_form.dart';
import 'base_appbar.dart';
import 'mqtt/MQTTManager.dart';

//void main() => runApp(MyApp());

Future<void> main() async {

  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPref));
  //runApp(MyApp(home: token == null ? LoginForm() : MQTTView()));
 // MaterialPageRoute(builder: (context) => AlarmHistory());

  //runApp(MyApp());
}

final List<Widget> screens = [
  LoginForm(),
  const AlarmHistory(),
  const UserSettings()
];

void test() {
  int a = 0;
  print(a);
}

class MyApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();
  final SharedPreferences sharedPref;

  MyApp(this.sharedPref);

  @override
  Widget build(BuildContext context) {

    /*final MQTTManager manager = MQTTManager(host:'test.mosquitto.org',topic:'flutter/amp/cool',identifier:'ios');
    manager.initializeMQTTClient(); */

    /* return MultiProvider(
        providers: [
          ChangeNotifierProvider<MQTTAppState>(
              create: (context) => Provider.of<MQTTAppState>(context)),
        ], */
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/login': (context) => LoginForm(),
          '/user_settings': (context) => UserSettings(),
          '/history': (context) => AlarmHistory(),
          '/current_alarms': (context) => MQTTView(),

        },
        navigatorKey: navigatorKey,
        // home: LoginForm(), //

        home: FirstScreen(sharedPref)
    );
  }
}
