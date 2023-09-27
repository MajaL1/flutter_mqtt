import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:mqtt_test/pages/test_notifications1.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'model/notification_message.dart';
import 'util/app_preference_util.dart';
import 'pages/first_screen.dart';
import 'pages/login_form.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/standalone.dart' as tz;



FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  await initializeService();
  runApp(
    const NotificationsApp(),
  );
}

// ToDo: zamenjaj klic za awsome service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: false,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'TEST NOTIFICATIONS',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  tzl.initializeTimeZones();
  service.startService();

}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  /******** tole sem probala in prikaze vse razen prvega*******/
  tzl.initializeTimeZones();
  final slovenia = tz.getLocation('Europe/London');
  final localizedDt = tz.TZDateTime.from(DateTime.now(), slovenia);

  List<NotificationMessage> notificationList = await ApiService.getNotifMess();
  for (var i = 0; i < notificationList.length; i++) {
    debugPrint("showing notification: ${notificationList[i].title}. $i");

    await flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        "A Notification From My App ",
        "$notificationList[i].title",
        tz.TZDateTime.now(slovenia).add(const Duration(minutes: 5)),
        //localizedDt,//tz.initializeTimeZones(),//.add(const Duration(days: 3)),
        const NotificationDetails(
            android: AndroidNotificationDetails("1", "11",
            )),
        //androidScheduleMode: AndroidScheduleMode,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }
}


///********* nekaj kode od prej *******************************
// bring to foreground
/*  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      // NotificationController.createNewNotification(),

      if (await service.isForegroundService()) {
        // if you don't using custom notification, uncomment this
       // service.setForegroundNotificationInfo(
         // title: "==Foreground My App Service",
         // content: "==Updated at ${DateTime.now()}, updates every 10 seconds",
        //);
      }
    }

    /// you can see this log in logcat
    print('== background service == Test NOtification FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }
    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  }); */
//******************************************//



class NotificationsApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const NotificationsApp({Key? key}) : super(key: key);

  @override
  State<NotificationsApp> createState() => _NotificationsAppState();
}

class _NotificationsAppState extends State<NotificationsApp> {
  var prefs = 1;

  @override
  void initState() {
    super.initState();
  }

  void sharedData() async {
    SharedPreferences.getInstance().then((prefValue) => setState(() {
          prefValue.setString("test", "test1");
        }));
  }

  @override
  Widget build(BuildContext context) {
    //SharedPreferences.getInstance().then((prefValue) => debugPrint(this));
    String channelKey = "alerts1Main";
    String channelName = "Alerts1Main";
    String channelDescription = "Notification tests as alerts1Main";

   // NotificationController.initializeLocalNotifications(
    //    channelKey, channelDescription, channelName);
    // SharedPreferences prefs =  getPrefs() ;
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/login': (context) => const LoginForm(),
          '/user_settings': (context) => const UserSettings(),
          '/history': (context) => const AlarmHistory(),
          '/current_alarms': (context) => MQTTView(),
          '/test_notifications1': (context) => TestNotifications1(),
          // '/test_notifications': (context) => TestNotifications(),
        },
        // navigatorKey: super.navigatorKey,
        // home: LoginForm(), //

        home: FirstScreen());
  }
}
