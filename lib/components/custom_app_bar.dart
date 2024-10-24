import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
//import 'package:mqtt_test/pages/login_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/gui_utils.dart';
import '../util/utils.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  String title;
  late String? connectionStatusText = "";


  CustomAppBar(this.title, {Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight + 22),
        super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  final Size preferredSize; // default is 56.0
}

class _CustomAppBarState extends State<CustomAppBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String username = "";
  String email = "";

  @override
  initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    InternetStatus? _connectionStatus;
    late StreamSubscription<InternetStatus> _subscription;
    _subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        _connectionStatus = status;
        widget.connectionStatusText =
        status == InternetStatus.connected ? "" : "No internet connection";
      });
    });
    SharedPreferences.getInstance().then((val) {
      setState(() {
      username = val.getString("username")!;
      email = (val.getString("email") ?? "")!;
      });
      val.reload();

      debugPrint(
          "44444 1 custom_appbar initState username: $username, email: $email");

    });
    debugPrint("-- custom_appbar initstate");
  }

  @override
  Widget build(BuildContext context) {

 // String ? connectionText = LoginForm.base().connectionStatusText;

    return Container(
        //padding: EdgeInsets.only(bottom:20),
        margin: EdgeInsets.only(top: 22),

        //preferredSize: preferredSize,
        child: AppBar(
            //toolbarHeight: 50,
            leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      SharedPreferences.resetStatic();
                      SharedPreferences.getInstance().then((val){
                        //val.reload();
                        setState(() {
                          //debugPrint("&&&&& username: ${val.getString('username')!}");
                          username = val.getString('username')!;
                          if(val.getString("email") != null) {
                            email = val.getString('email')!;
                          }
                        });
                        return val;
                      });
                      setState(() {

                      });
                      Scaffold.of(context).openDrawer();
                    },
                  );
                }
            ),

            flexibleSpace: Container(
              //height: 180,
              //padding: EdgeInsets.only(top:40),

              decoration: GuiUtils.buildAppBarDecoration(),
            ),
            shadowColor: Colors.black,
            foregroundColor: Colors.lightBlue,
            title: Container(
                //decoration: //Utils.buildAppBarDecoration(),
                child: Row( children: [
                Text(
                widget.connectionStatusText != null
                  ? widget.connectionStatusText!
                  : "",
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14),
                ),
               // Text("${widget.title}",
               //     style: const TextStyle(
               //   fontSize: 16, color: Colors.white, letterSpacing: 1)),
                  Text("  $username $email",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white, letterSpacing: 1)),
                  const Text("            v_2024-16-10",
                        style: TextStyle(
                            fontSize: 8, color: Colors.white )
            )]))
    ));
  }
}
