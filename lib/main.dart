import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/alarm_history.dart';
import 'package:mqtt_test/first_screen1.dart';
import 'package:mqtt_test/test_notifications.dart';
import 'package:mqtt_test/test_notifications1.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preference_util.dart';
import 'first_screen.dart';
import 'login_form.dart';
import 'mqtt/MQTTManager.dart';
import 'notification_controller.dart';
import 'notification_page.dart';

//void main() => runApp(MyApp());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  runApp(
    MyApp(),
  );
  
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



class MyApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  MyApp();

  //get prefs => SharedPreferences.getInstance();

  @override
  _MyAppState createState() => _MyAppState();
}
  class _MyAppState extends State<MyApp> {
   var prefs =1;
    @override
    void initState() {
      super.initState();
    }
   void sharedData() async {
      SharedPreferences.getInstance().then((prefValue) =>
          setState(() {
             prefValue.setString("test", "test1");
          })
      );
   }



  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((prefValue) =>
        print(this)
    );
    NotificationController.initializeLocalNotifications();
    // SharedPreferences prefs =  getPrefs() ;
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
          '/test_notifications1': (context) => TestNotifications1(),
         // '/test_notifications': (context) => TestNotifications(),

        },
       // navigatorKey: super.navigatorKey,
        // home: LoginForm(), //

        home: FirstScreen()

    );
  }

  }



