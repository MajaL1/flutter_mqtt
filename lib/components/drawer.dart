import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_test/pages/test_notifications_editable.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:mqtt_test/widgets/mqttView.dart';

import '../mqtt/MQTTConnectionManager.dart';
import '../mqtt/state/MQTTAppState.dart';

class NavDrawer extends StatefulWidget {
  MQTTConnectionManager manager;
  MQTTAppState currentAppState;

  NavDrawer(MQTTAppState appState, MQTTConnectionManager connectionManager,
      {Key? key})
      : currentAppState = appState,
        manager = connectionManager,
        super(key: key);

  get appState {
    return currentAppState;
  }

  get connectionManager {
    return manager;
  }

  @override
  State<StatefulWidget> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  initState() {
    super.initState();
    debugPrint("-- navDrawer initstate");
  }

  _initCurrentAppState() async {
    Timer(
        const Duration(seconds: 2),
        () => {
              setCurrentAppState(widget.currentAppState),
              setManager(widget.manager),
              debugPrint("[[[ currentAppState: $widget.currentAppState ]]]")
            });
    return widget.currentAppState;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        width: MediaQuery.of(context).size.width * 0.55,
        child: FutureBuilder(
            future: _initCurrentAppState(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasError) {
                  return ErrorWidget(Exception(
                      'Error occured when fetching data from database $snapshot.error'));
                } else if (!snapshot.hasData) {
                  return ErrorWidget(Exception(
                      'Error occured when fetching data from database $snapshot.error'));
                } else {// (snapshot.hasData) {
                  debugPrint(
                      "first screen: snapshot:: $snapshot, $widget.currentAppState. ${widget.manager}");

                  return Drawer(
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
                                  'Welcome, User1',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Divider(height: 40),
                              ListTile(
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
                                  '//Scheduled alarms',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        //builder: (context) => TestNotifications1())),
                                        builder: (context) =>
                                            const TestNotificationsEditable())),
                              ),
                              const Divider(height: 10),
                              ListTile(
                                hoverColor: Colors.blue,
                                tileColor: Colors.blue,
                                dense: false,
                                visualDensity:
                                    const VisualDensity(vertical: -4),
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
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AlarmHistory())),
                              ),
                              const Divider(height: 10),
                              ListTile(
                                hoverColor: Colors.blue,
                                tileColor: Colors.blue,
                                dense: false,
                                visualDensity:
                                    const VisualDensity(vertical: -4),
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
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => UserSettings(
                                            widget.appState,
                                            widget.connectionManager))),
                              ),
                              const Divider(height: 10),
                              const Divider(height: 10),
                              const ListTile(
                                hoverColor: Colors.blue,
                                tileColor: Colors.blue,
                                dense: false,
                                visualDensity: VisualDensity(vertical: -4),
                                leading: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'Test - Notifications',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                /*onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NotificationPage())), */
                              ),
                              const Divider(height: 10),
                              ListTile(
                                hoverColor: Colors.blue,
                                tileColor: Colors.blue,
                                dense: false,
                                visualDensity:
                                    const VisualDensity(vertical: -4),
                                leading: const Icon(
                                  Icons.alarm,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  'Test MQTT',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => const MQTTView.base())),
                              ),
                              const Divider(height: 10),
                              const Divider(height: 40),
                              ListTile(
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
                              ),
                            ],
                          )));
                }
              }
            }));
  }

  Future<void> setCurrentAppState(appState) async {
    widget.currentAppState = appState;
  }

  Future<void> setManager(manager) async {
    widget.manager = manager;
  }
}
