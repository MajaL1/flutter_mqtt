import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/components/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/drawer.dart';
import '../model/constants.dart';

class AboutPage extends StatefulWidget {
  const AboutPage.base({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutState();
}

class _AboutState extends State<AboutPage> {
  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);

  TextStyle headingStyleIOS = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: CupertinoColors.inactiveGray,
  );
  TextStyle descStyleIOS = const TextStyle(color: CupertinoColors.inactiveGray);



  String username = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("aboutpage initState");
    //final prefs =  SharedPreferences.getInstance().reload();

    final prefs = SharedPreferences.getInstance().then((val) {
      val.reload();
      setState(() {
        username = val.getString("username")!;
        email = (val.getString("email") ?? "");
      });
      setState(() {
        //if(val.getString("email") != null) {
        //String ? email = val.getString("email");
        //  email ??= "";
       // }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("calling build method about_page.dart");

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: CustomAppBar(Constants.ABOUT),
      drawer:  NavDrawer.data(username: username, email: email,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 15, right: 10),
        scrollDirection: Axis.vertical,
        child: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          _buildAboutView(),

          //Divider(height: 1, color: Colors.black12, thickness: 5),
        ]),
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.blue, //Color.fromRGBO(0, 87, 153, 60),
      borderRadius: BorderRadius.circular(9),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 4,
          blurRadius: 5,
          offset: const Offset(0, 2), // changes position of shadow
        ),
      ],
    );
  }

  Widget _buildAboutView() {
    return
      Center(child:
          Column(children: [
            const Padding(padding: EdgeInsets.only(top: 30)),
            const Text("ALARM APP", style: TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
            fontSize: 30)),
            const Padding(padding: EdgeInsets.only(top: 30)),

            const Text("v.10.10.0", style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
            const Padding(padding: EdgeInsets.only(top: 50)),
            SizedBox(
          width: 200,
          height: 200,
          child: Image.asset('assets/images/LOGO_NEW_ORIG.png'),

      ),
            const Padding(padding: EdgeInsets.only(top: 50)),
            const Text("www.navis-elektronika.com", style: TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.bold,
              fontSize: 16)),

          ])

      //FlutterLogo(size: 200),
    );
  }
  @override
  void dispose() {
    debugPrint("about_page.dart - dispose");
    super.dispose();
  }
}
