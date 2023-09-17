import 'package:flutter/material.dart';
import 'package:mqtt_test/pages/notification_page.dart';
import 'package:mqtt_test/pages/test_notifications_editable.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:mqtt_test/test_backround_process.dart';
import 'package:mqtt_test/widgets/mqttView.dart';

class NavDrawer extends StatelessWidget {
  //var sharedPreferences;

  // NavDrawer(sharedPrefs);
  NavDrawer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: MediaQuery.of(context).size.width * 0.55,
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
                    leading: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.only(
                        top: 25, bottom: 25, left: 20, right: 10),
                    visualDensity: VisualDensity(vertical: -4),
                    enabled: false,
                    title: Text(
                      'Welcome, User1',
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
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Scheduled alarms',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        //builder: (context) => TestNotifications1())),
                        builder: (context) => TestNotificationsEditable())),
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
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AlarmHistory())),
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
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserSettings())),
                  ),
                  Divider(height: 10),
                  Divider(height: 10),
                  ListTile(
                    hoverColor: Colors.blue,
                    tileColor: Colors.blue,
                    dense: false,
                    visualDensity: VisualDensity(vertical: -4),
                    leading: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Test - Notifications',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NotificationPage())),
                  ),
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
                      'Test MQTT',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MQTTView())),
                  ),
                  Divider(height: 10),
                  Divider(height: 40),
                  ListTile(
                    hoverColor: Colors.blue,
                    tileColor: Colors.grey,
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
                ],
              ))),
    );
  }
}
