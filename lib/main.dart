import 'dart:js';
import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:mqtt_test/alarm_history.dart';
import 'package:mqtt_test/first_screen.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:mqtt_test/mqtt/state/MQTTAppState.dart';
import 'package:provider/provider.dart';
//import 'package:provider/provider.dart';

import 'LoginForm.dart';
import 'base_appbar.dart';
import 'mqtt/MQTTManager.dart';

void main() => runApp(MyApp());

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

        home: FirstScreen()
    );
  }
}
