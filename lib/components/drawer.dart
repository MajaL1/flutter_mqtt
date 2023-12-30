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
  String email = "";

  @override
  initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefValue) => {
          setState(() {
            username = prefValue.getString('username')!;
            email = prefValue.getString('email')!;
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
        color: Colors.black,
        width: MediaQuery.of(context).size.width * 0.50,
        height: 850,
        child: Drawer(
            backgroundColor: Colors.black,
            //Color.fromRGBO(0, 87, 153, 60),
            child: ConstrainedBox(
                //color: Colors.blue,
                constraints: const BoxConstraints(
                    minHeight: 50, minWidth: 150, maxHeight: 100),
                child: ListView(
                  children: [
                    buildDrawerMainListTile(),
                    const Divider(height: 20),
                    Container(
                        decoration: buildDrawerDecorationListTile(),
                        child: ListTile(
                          hoverColor: Colors.blue,
                          tileColor: Colors.blue,
                          selectedColor: Colors.blueAccent,
                          //style: ,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 16.0),
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
                    //const Divider(height: 15),
                    Container(
                        decoration: buildDrawerDecorationListTile(),
                        child: ListTile(
                          hoverColor: Colors.blue,
                          tileColor: Colors.blue,
                          dense: false,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 16.0),
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
                    //const Divider(height: 15),
                    Container(
                        decoration: buildDrawerDecorationListTile(),
                        child: ListTile(
                            hoverColor: Colors.blue,
                            tileColor: Colors.blue,
                            dense: false,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 16.0),
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
                    // const Divider(height: 5),
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

  Container buildDrawerMainListTile() {
    return Container(
        decoration: buildBoxDecorationMainTile(),
        child: ListTile(
            hoverColor: Colors.blue,
            tileColor: Colors.indigo,
            dense: false,
            leading: const Icon(
              Icons.person_3_rounded,
              size: 30,
              //person_2_outlined,
              color: Colors.white,
            ),
            contentPadding:
                const EdgeInsets.only(top: 55, bottom: 35, left: 20, right: 10),
            visualDensity: VisualDensity(vertical: -4),
            enabled: false,
            title: Column(children: [
              Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "$username",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Colors.white, wordSpacing: 1, fontSize: 18),
                  )),
              /*Container(
                  child: Text(
               "\n"),
              ), */
              Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                "$email",
                textAlign: TextAlign.left,
                style: const TextStyle(
                    color: Colors.white, wordSpacing: 1, fontSize: 12),
              )),
            ])));
  }

  BoxDecoration buildDrawerDecorationListTile() {
    return const BoxDecoration(
        // Create a gradient background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(16, 30, 66, 1),
            Color.fromRGBO(36, 61, 166, 1),
          ],
        ),
        border: Border(bottom: BorderSide(color: Colors.black, width: 3)));
  }

  BoxDecoration buildBoxDecorationMainTile() {
    return const BoxDecoration(
        // Create a gradient background
        gradient: LinearGradient(
          //center: Alignment(0, 0),
          //radius: 2,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            //Colors.black,
            Color.fromRGBO(16, 30, 66, 1),

            Color.fromRGBO(36, 61, 166, 1),
          ],
        ),
        border: Border(
            bottom: BorderSide(color: Colors.black, width: 5),
            top: BorderSide(color: Colors.black, width: 3)));
  }
}
