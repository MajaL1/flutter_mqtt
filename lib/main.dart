import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/alarm_history.dart';
import 'package:mqtt_test/first_screen1.dart';
import 'package:mqtt_test/test_notifications.dart';
import 'package:mqtt_test/test_notifications1.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'login_form.dart';
import 'mqtt/MQTTManager.dart';
import 'notification_controller.dart';
import 'notification_page.dart';

//void main() => runApp(MyApp());

Future<void> main() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  await NotificationController.initializeLocalNotifications();
  runApp(MyApp(sharedPref));

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

class MyApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final SharedPreferences sharedPref;


  MyApp(this.sharedPref);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _AppState extends State<MyApp> {
  // This widget is the root of your application.

   String routeHome = '/',
      routeNotification = '/notification-page';

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    super.initState();
  }



@override
Widget build(BuildContext context) {

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
        '/test_notifications': (context) => TestNotifications(),
        '/test_notifications1': (context) =>
            TestNotifications1(title: 'test notifications 1',),
        '/notifications_page': (context) =>
            NotificationPage(
              receivedAction: NotificationController.initialAction!,),
      },
      navigatorKey: navigatorKey,
      // home: LoginForm(), //

      home: FirstScreen(sharedPref)
  );
}


}
