import 'package:flutter/material.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:mqtt_test/pages/user_settings.dart';

import '../pages/data_page.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer.base({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  initState() {
    super.initState();
    debugPrint("-- navDrawer initstate");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        width: MediaQuery.of(context).size.width * 0.55,
        child: Drawer(
            child: ConstrainedBox(
                //color: Colors.blue,
                constraints: const BoxConstraints(
                    minHeight: 50, minWidth: 150, maxHeight: 100),
                child: ListView(
                  children: [
                    const ListTile(
                      hoverColor: Colors.blue,
                      tileColor: Colors.indigo,
                      dense: false,
                      leading: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                      ),
                      contentPadding: EdgeInsets.only(
                          top: 25, bottom: 25, left: 20, right: 10),
                      visualDensity: VisualDensity(vertical: -4),
                      enabled: false,
                      title: Text(
                        'User1',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Divider(height: 40),
                    /*ListTile(
                                hoverColor: Colors.blue,
                                tileColor: Colors.blue,
                                dense: false,
                                visualDensity:
                                    const VisualDensity(vertical: -4),
                                leading: const Icon(
                                  Icons.notifications_active_outlined,
                                  color: Colors.white,
                                ),
                               title: const Text(
                                  '//Test alarms',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        //builder: (context) => TestNotifications1())),
                                        builder: (context) =>
                                            const TestNotificationsEditable())),
                              ), */
                    const Divider(height: 10),
                    ListTile(
                      hoverColor: Colors.blue,
                      tileColor: Colors.blue,
                      dense: false,
                      visualDensity: const VisualDensity(vertical: -4),
                      leading: const Icon(
                        Icons.history,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'History',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AlarmHistory())),
                    ),
                    const Divider(height: 10),
                    ListTile(
                      hoverColor: Colors.blue,
                      tileColor: Colors.blue,
                      dense: false,
                      visualDensity: const VisualDensity(vertical: -4),
                      leading: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const UserSettings.base())),
                    ),
                    const Divider(height: 10),
                    const Divider(height: 10),
                    ListTile(
                        hoverColor: Colors.blue,
                        tileColor: Colors.blue,
                        dense: false,
                        visualDensity: const VisualDensity(vertical: -4),
                        leading: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                        title: const Text(
                          'Data',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DetailsPage.base()))),
                    const Divider(height: 5),
                    /*ListTile(
                      hoverColor: Colors.blue,
                      tileColor: Colors.blue,
                      dense: false,
                      visualDensity: const VisualDensity(vertical: -4),
                      leading: const Icon(
                        Icons.alarm,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Alarms',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                          // MaterialPageRoute(
                          //     builder: (context) => const MQTTView.base())),
                          MaterialPageRoute(
                              builder: (context) => const AlarmsPage.base())),
                    ),*/
                    //const Divider(height: 10),
                    //const Divider(height: 40),
                    /* ListTile(
                                hoverColor: Colors.blue,
                                tileColor: Colors.grey,
                                dense: false,
                                visualDensity:
                                    const VisualDensity(vertical: -4),
                                leading: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {},
                              ),*/
                  ],
                ))));
  }
}
