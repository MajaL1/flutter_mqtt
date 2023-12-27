import 'package:flutter/material.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/data_page.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer.base({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String username = "";

  @override
  initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefValue) => {
          setState(() {
            username = prefValue.getString('username')!;
            //  _name = prefValue.getString('name')?? "";
            //Text text =  Text(username!);
          })
        });

    debugPrint("-- navDrawer initstate");
  }

  Future getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
  }

  /* Future<dynamic> _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  } */
  /*String  getUserName() {
    _getPrefs();
    String username = "";
    if(prefs.getString("username") != null) {
      username = prefs.getString("username")!;
      return username;
    }
    //username="test2";
    return username;
  } */

  @override
  Widget build(BuildContext context) {
    return Container(
        //color: Colors.white12,
        width: MediaQuery.of(context).size.width * 0.50,
        height: 750,
        child: Drawer(
          backgroundColor: Colors.grey.shade400,
            child: ConstrainedBox(
                //color: Colors.blue,
                constraints: const BoxConstraints(
                    minHeight: 50, minWidth: 150, maxHeight: 100),
                child: ListView(
                  children: [
                    Container(
                        decoration: buildBoxDecoration(),
                        child: ListTile(
                            hoverColor: Colors.blue,
                            tileColor: Colors.indigo,
                            dense: false,
                            leading: const Icon(
                              Icons.person_3_sharp, //person_2_outlined,
                              color: Colors.white,
                            ),
                            contentPadding: const EdgeInsets.only(
                                top: 25, bottom: 35, left: 20, right: 10),
                            visualDensity: VisualDensity(vertical: -4),
                            enabled: false,
                            title: ListTile(
                                //'User1',
                                // getUserName(),
                                title: Text(
                              username,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            )))),
                    const Divider(height: 60),
                      Container(
                        decoration: buildBoxDecoration(),
                        child: ListTile(
                          hoverColor: Colors.blue,
                          tileColor: Colors.blue,
                          selectedColor: Colors.blueAccent,
                          //style: ,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16.0),
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
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const AlarmHistory())),
                        )),
                    const Divider(height: 35),
                    Container(
                        decoration: buildBoxDecoration(),
                        child: ListTile(
                          hoverColor: Colors.blue,
                          tileColor: Colors.blue,
                          dense: false,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16.0),
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
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const UserSettings.base())),
                        )),
                    const Divider(height: 35),
                    Container(
                        decoration: buildBoxDecoration(),
                        child: ListTile(
                            hoverColor: Colors.blue,
                            tileColor: Colors.blue,
                            dense: false,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16.0),
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
                                        const DetailsPage.base())))),
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

  BoxDecoration buildBoxDecoration() {
    return const BoxDecoration(
      // Create a gradient background
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(0, 87, 153, 60),
          Colors.indigoAccent,
          Colors.blueAccent
        ],
      ),
    );
  }
}
