import 'package:flutter/material.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../pages/about_page.dart';
import '../pages/login_form.dart';

//import '../pages/data_page.dart';

class NavDrawer extends StatefulWidget {
  //const NavDrawer.base({Key? key}) : super(key: key);

   const NavDrawer.data({Key? key, required this.username, required this.email}) : super(key: key);

  //MyHomePage({Key key, this.title}) : super(key: key);
  final String username;

  final String email;



  @override
  State<StatefulWidget> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  //String username = "";
  //String email = "";
  late SharedPreferences prefs;

  @override
  initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    SharedPreferences.resetStatic();

    //initial();
    //setState(() {

    //});

    //Navigator.popAndPushNamed(context, '/');
   /* Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
            const AlarmHistory())
    ); */
    debugPrint("-- navDrawer initstate");
  }

 /* void initial() async{
    //prefs = await SharedPreferences.getInstance();
    //prefs.reload();

    prefs = await SharedPreferences.getInstance().then((val){
      //val.reload();
      setState(() {
        //debugPrint("&&&&& username: ${val.getString('username')!}");
        username = val.getString('username')!;
        email = val.getString('email')!;
      });
      return val;
    });
    setState((){});

  }*/

  /*Future<String> getUsername() async {

    String user = await SharedPreferences.getInstance().then((val){
      //val.reload();
      setState(() {
        //debugPrint("&&&&& username: ${val.getString('username')!}");
        username = val.getString('username')!;
        email = val.getString('email')!;
      });
      return username;
    });
    return user;
  } */


  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.black,
        width: MediaQuery.of(context).size.width * 0.50,
        //height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Drawer(
            backgroundColor: Colors.black,
            shadowColor: Colors.black,

            //Color.fromRGBO(0, 87, 153, 60),
            child: ConstrainedBox(
                //color: Colors.blue,
                constraints: const BoxConstraints(
                    minHeight: 50, minWidth: 150, maxHeight: 100),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListView(
                  children: [
                    buildDrawerMainListTile(),
                    //const Divider(height: 20),
                    /*Container(
                        decoration: buildDrawerDecorationListTile(),
                        child: ListTile(
                          hoverColor: Colors.blue,
                          //tileColor: Colors.blue,
                          dense: false,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 16.0),
                          visualDensity: const VisualDensity(vertical: -4),
                          leading: const Icon(
                            Icons.dataset,
                            color: Colors.white60,
                          ),
                          title: const Text(
                            'Data',
                            style: TextStyle(
                              color: Colors.white60,
                              letterSpacing: 1.8,
                            ),
                          ),
                          onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const DataPage.base())),
                        )),*/
                    Container(
                        decoration: buildDrawerDecorationListTile(),
                        child: ListTile(
                          hoverColor: Colors.blue,
                          //tileColor: Colors.blue,
                          //selectedColor: Colors.blueAccent,
                          //style: ,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 16.0),
                          dense: false,
                          visualDensity: const VisualDensity(vertical: -4),
                          leading: const Icon(
                            Icons.history,
                            color: Colors.white60,
                          ),
                          title: const Text(
                            'History',
                            style: TextStyle(
                              color: Colors.white60,
                              letterSpacing: 1.8,
                            ),
                          ),
                          onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AlarmHistory())),
                        )),
                    //const Divider(height: 15),
                    Container(
                        decoration: buildDrawerDecorationListTile(),
                        child: ListTile(
                          hoverColor: Colors.blue,
                          //tileColor: Colors.blue,
                          dense: false,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 16.0),
                          visualDensity: const VisualDensity(vertical: -4),
                          leading: const Icon(
                            Icons.settings,
                            color: Colors.white60,
                          ),
                          title: const Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.white60,
                              letterSpacing: 1.8,
                            ),
                          ),
                          onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                       const UserSettings.base())),
                        ),
                    ),
                    Container(
                      decoration: buildDrawerDecorationListTile(),
                      child: ListTile(
                        hoverColor: Colors.blue,
                        //tileColor: Colors.blue,
                        dense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 16.0),
                        visualDensity: const VisualDensity(vertical: -4),
                        leading: const Icon(
                          Icons.info_outline,
                          color: Colors.white60,
                        ),
                        title: const Text(
                          'About',
                          style: TextStyle(
                            color: Colors.white60,
                            letterSpacing: 1.8,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) =>
                                const AboutPage.base())),
                      ),
                    ),
                    //const Divider(height: 15),
                    Container(
                        decoration: buildDrawerDecorationListTile(),
                        margin: const EdgeInsets.only(top: 4),
                        child: ListTile(
                          hoverColor: Colors.blue,
                          //tileColor: Colors.blue,
                          dense: false,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 16.0),
                          visualDensity: const VisualDensity(vertical: -4),
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.white60,
                          ),
                          title: const Text(
                            'Log out',
                            style: TextStyle(
                              color: Colors.white60,
                              letterSpacing: 1.8,
                            ),
                          ),
                          onTap: () async {
                            await ApiService.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                    LoginForm.base()),
                                    (route) => false);
                          })),
                   /* Container(
                        decoration: buildDrawerDecorationListTile(),
                        child: ListTile(
                            hoverColor: Colors.blue,
                            //tileColor: Colors.blue,
                            dense: false,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 16.0),
                            visualDensity:
                                const VisualDensity(vertical: -4),
                            leading: const Icon(
                              Icons.notifications,
                              color: Colors.white60,
                            ),
                            title: const Text(
                              'Data',
                              style: TextStyle(
                                color: Colors.white60,
                                letterSpacing: 1.8
                              ),
                            ),
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DetailsPage.base())))

                    ),*/
                  ],
                )))));
  }

  Container buildDrawerMainListTile() {
    debugPrint("44444 buildDrawerMainListTile: ${widget.username}, ${widget.email}");
    return Container(
        decoration: buildBoxDecorationMainTile(),
        child: ListTile(
            //hoverColor: Colors.blue,
            //tileColor: Colors.indigo,
            dense: false,
            leading: const Icon(
              Icons.person_3_rounded,
              size: 30,
              //person_2_outlined,
              color: Colors.white70,
            ),
            contentPadding:
                const EdgeInsets.only(top: 55, bottom: 35, left: 10, right: 10),
            visualDensity: const VisualDensity(vertical: -4),
            enabled: false,
            title: Column(children: [
              Container(
                  alignment: Alignment.topLeft,
                  child:  Text(widget.username, textAlign: TextAlign.left,
                            style: const TextStyle(
                                color: Colors.white70, letterSpacing: 2, fontSize: 15),)
              ),

              Container(
                  alignment: Alignment.topLeft,
                  child:  Text(widget.email, textAlign: TextAlign.left,
                        style: const TextStyle(
                            color: Colors.white70, letterSpacing: 0.6, fontSize: 10),)
                  ),
            ])));
  }

  BoxDecoration buildDrawerDecorationListTile() {
    return const BoxDecoration(
        // Create a gradient background
        gradient:  LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
         /* colors: [
            Colors.black,
            Color.fromRGBO(0, 0, 190, 1),
            //Color.fromRGBO(0, 87, 153, 60)
          ], */

          colors: [
            Colors.black,
           // Color.fromRGBO(0, 0, 190, 1),
            Color.fromRGBO(36, 61, 166, 1),

            //Color.fromRGBO(0, 0, 190, 1),
            //Color.fromRGBO(0, 87, 153, 60)
          ],
        ),
        //borderRadius: BorderRadius.circular(18),
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
            Colors.black,

            Color.fromRGBO(16, 30, 66, 1),

            Color.fromRGBO(36, 61, 166, 1),
          ],
        ),
        border: Border(
            bottom: BorderSide(color: Colors.black, width: 5),
            top: BorderSide(color: Colors.black, width: 3)));
  }
}
