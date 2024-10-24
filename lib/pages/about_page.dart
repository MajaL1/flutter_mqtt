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
      });
      setState(() {
        if(val.getString("email") != null) {
          email = val.getString("email")! ?? "";
        }
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
          _buildDataView(),

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

  Widget _buildDataView() {
    return SizedBox(
      width: 70,
      height: 70,
      child: Image.asset('assets/images/LOGO_NEW_ORIG.png'),

      //FlutterLogo(size: 200),
    );
  }
  @override
  void dispose() {
    debugPrint("about_page.dart - dispose");
    super.dispose();
  }
}
