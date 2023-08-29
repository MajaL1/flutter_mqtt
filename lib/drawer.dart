import 'package:flutter/material.dart';
import 'package:mqtt_test/notification_page.dart';
import 'package:mqtt_test/test_notifications.dart';
import 'package:mqtt_test/test_notifications1.dart';
//import 'package:mqtt_test/test_notifications1.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/alarm_history.dart';
import 'package:mqtt_test/widgets/mqttView.dart';

import 'notification_controller.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: MediaQuery.of(context).size.width * 0.30,
      child: Drawer(
          child: ConstrainedBox(
              //color: Colors.blue,
              constraints:
                  BoxConstraints(minHeight: 50, minWidth: 150, maxHeight: 100),
              child: ListView(
                children: [
                  ListTile(
                    hoverColor: Colors.blue,
                    tileColor: Colors.indigo,
                    dense: false,
                    visualDensity: VisualDensity(vertical: -4),
                    enabled: false,
                    title: Text(
                      'Welcome User1',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),

                  ),
                  Divider(height: 40),
                  ListTile(
                    hoverColor: Colors.blue,

                    tileColor: Colors.blue,
                    dense: false,
                    visualDensity: VisualDensity(vertical: -4),
                    leading: const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Test notifications',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TestNotifications())),
                  )
                  ,
                  Divider(height: 10),
                  ListTile(
                    hoverColor: Colors.blue,

                    tileColor: Colors.blue,
                    dense: false,
                    visualDensity: VisualDensity(vertical: -4),
                    leading: const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Test notifications 1',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TestNotifications1())),
                  )
                  ,
                  ListTile(
                    hoverColor: Colors.blue,

                    tileColor: Colors.blue,
                    dense: false,
                    visualDensity: VisualDensity(vertical: -4),
                    leading: const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Notification page',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => NotificationPage())),   )
                  ,
                  Divider(height: 10),
                  ListTile(
                    hoverColor: Colors.blue,
                    tileColor: Colors.blue,
                    dense: false,
                    visualDensity: VisualDensity(vertical: -4),
                    leading: Icon(
                      Icons.alarm,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Alarms',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MQTTView())),
                  ),
                  Divider(height: 10),
                  ListTile(
                    hoverColor: Colors.blue,
                    tileColor: Colors.blue,
                    dense: false,
                    visualDensity: VisualDensity(vertical: -4),
                    leading: Icon(
                      Icons.history,
                      color: Colors.white,
                    ),
                    title: Text(
                      'History',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AlarmHistory())),
                  ),
                  Divider(height: 10),
                  ListTile(
                    hoverColor: Colors.blue,
                    tileColor: Colors.blue,
                    dense: false,
                    visualDensity: VisualDensity(vertical: -4),
                    leading: Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => UserSettings())),
                  ),
                  Divider(height: 30),
                  ListTile(
                    hoverColor: Colors.blue,
                    tileColor: Colors.cyan,
                    dense: false,
                    visualDensity: VisualDensity(vertical: -4),
                    leading: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {},
                  ),
                 /*
                  Flexible(
                    flex: 4,
                    child: ListTile(
                      hoverColor: Colors.blue,
                      dense: true,
                      visualDensity: VisualDensity(vertical: -4),
                      leading: Icon(
                        Icons.history,
                        color: Colors.white,
                      ),
                      title: Text(
                        'History',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AlarmHistory())),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: ListTile(
                      hoverColor: Colors.blue,
                      dense: true,
                      visualDensity: VisualDensity(vertical: -4),
                      leading: Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {},
                    ),
                  )*/
                ],
              ))),
    );
  }
}
