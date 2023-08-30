

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/alarm_history.dart';
import 'package:mqtt_test/first_screen1.dart';
import 'package:mqtt_test/test_notifications.dart';
import 'package:mqtt_test/test_notifications1.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'first_screen.dart';
import 'login_form.dart';
import 'mqtt/MQTTManager.dart';
import 'notification_controller.dart';
import 'notification_page.dart';

//void main() => runApp(MyApp());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized ();
  //SharedPreferences sharedPref = await SharedPreferences.getInstance();
  //await NotificationController.initializeLocalNotifications();
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'key1',
            channelName: 'Proto Coders Point',
            channelDescription: "Notification example",
            defaultColor: Color(0XFF9050DD),
            ledColor: Colors.white,
            playSound: true,
            enableLights:true,
            enableVibration: true
        )
      ]
  );
  runApp(MyApp());

  //runApp(MyApp());
}

/*final List<Widget> screens = [
  LoginForm(),
  const AlarmHistory(sharedPreferences: JsFunction.),
  const UserSettings()
]; */

void test() {
  int a = 0;
  print(a);
}

class MyApp extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  MyApp();


  late SharedPreferences prefs = initiateSharedPreferences() as SharedPreferences;
  Future<void> initiateSharedPreferences()
  async {
    prefs = await SharedPreferences.getInstance();
  }


@override
Widget build(BuildContext context) {
  NotificationController.initializeLocalNotifications();
 // SharedPreferences sharedPref =  SharedPreferences.getInstance();
  return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/login': (context) => LoginForm(this.prefs),
          '/user_settings': (context) => UserSettings(),
          '/history': (context) => AlarmHistory(this.prefs),
          '/current_alarms': (context) => MQTTView(this.prefs),
          '/test_notifications1': (context) => TestNotifications1(this.prefs,),
          '/test_notifications': (context) => TestNotifications(),

        },
        navigatorKey: navigatorKey,
        // home: LoginForm(), //

        home: FirstScreen(this.prefs)
    );
  }
}
