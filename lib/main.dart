import 'package:flutter/material.dart';
import 'package:mqtt_test/alarm_history.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:mqtt_test/mqtt/state/MQTTAppState.dart';
import 'package:provider/provider.dart';
//import 'package:provider/provider.dart';

import 'LoginForm.dart';
import 'base_appbar.dart';
import 'mqtt/MQTTManager.dart';

void main() => runApp(MyApp());

final List<Widget> screens = const [
  LoginForm(),
  AlarmHistory(),
  UserSettings()
];
void test() {
  int a = 0;
  print(a);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /*final MQTTManager manager = MQTTManager(host:'test.mosquitto.org',topic:'flutter/amp/cool',identifier:'ios');
    manager.initializeMQTTClient(); */

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<MQTTAppState>(
              create: (context) => Provider.of<MQTTAppState>(context)),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          /** tukaj bomo zamenjali s home: LoginForm
           * v HomePage bomo poklicali MQTTVIEW **/
          /* home: ChangeNotifierProvider<MQTTAppState>(
          create: (_) => MQTTAppState(),
          child: MQTTView(),
        */
          // home: //LoginForm(), //
          home: Scaffold(
           /* appBar: BaseAppBar(
              title: Text('test'),
              appBar: AppBar(),
              widgets: <Widget>[Icon(Icons.more_vert)],
            ),*/
            appBar: AppBar(
              title: const Text('Test'),

            ),
            /** tukaj bomo dinamicno gradili body **/
            body: LoginForm(),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children:  <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Drawer Header',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text('Current alarms'),
                      onTap: () {}
                  ),
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('History'),
                    onTap: () {}
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

/*
Padding(
        padding: const EdgeInsets.all(100.0),
        child: Center(
          child:Column(
            children: <Widget>[
              Center(
                child: RaisedButton(
                  child: Text("Connect"),
                  onPressed: manager.connect ,
                ),
              )
            ],
          ) ,
        ),
      )
 */
