import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../components/noti.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class TestNotifications extends StatefulWidget {
  const TestNotifications({Key? key}) : super(key: key);

  @override
  State<TestNotifications> createState() => _TestNotificationsState();
}

class _TestNotificationsState extends State<TestNotifications> {
  void initState() {
    super.initState();
    Noti.initialize(flutterLocalNotificationsPlugin);
  }

  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red);

  bool lockAppSwitchVal = true;
  bool fingerprintSwitchVal = false;
  bool changePassSwitchVal = true;

  TextStyle headingStyleIOS = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: CupertinoColors.inactiveGray,
  );
  TextStyle descStyleIOS = const TextStyle(color: CupertinoColors.inactiveGray);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Some web specific code there
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        //backgroundColor: Colors.blue.withOpacity(0.5),
        title: Text("Test notifications"),
      ),
      body: Container(
        child:
        Row(
          children: [
            Flexible(
                flex: 1,
                child: Container(

                ) // your widget here
            ),
            Flexible(
                flex: 2,
                child: Container(
                  child: ElevatedButton(
                    onPressed: () {
                      Noti.showBigTextNotification(
                          title: "New message title",
                          body: "Your long body",
                          fln: flutterLocalNotificationsPlugin);
                    },
                    child: Text("click"),
                  ),
                ) // another widget or an empty container to allocate the space
            ),
          ],
        )
      ),
    );
  }
}
