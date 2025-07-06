import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

//import 'package:mqtt_test/pages/login_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/gui_utils.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String username = "";
  String email = "";

  @override
  initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    InternetStatus? connectionStatus;
    late StreamSubscription<InternetStatus> subscription;
    subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        connectionStatus = status;
        widget.connectionStatusText =
            status == InternetStatus.connected ? "" : "No internet connection";
      });
    });
    SharedPreferences.getInstance().then((val) {
      setState(() {
        username = val.getString("username")!;
        email = "";//val.getString("email")!;
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
        margin: Platform.isAndroid ? EdgeInsets.only(top: 22) : EdgeInsets.only(top: 45),
        //preferredSize: preferredSize,
        child: AppBar(
            //toolbarHeight: 50,
            leading: Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  //SharedPreferences.resetStatic();
                  SharedPreferences.getInstance().then((val) {
                    //val.reload();
                    setState(() {
                      //debugPrint("&&&&& username: ${val.getString('username')!}");
                      username = val.getString('username')!;
                      if (val.getString("email") != null) {
                        email = val.getString('email')!;
                      }
                    });
                    return val;
                  });
                  setState(() {});
                  Scaffold.of(context).openDrawer();
                },
              );
            }),
            flexibleSpace: Container(
              //height: 180,
              //padding: EdgeInsets.only(top:40),

              decoration: //Platform.isAndroid ? 
              GuiUtils.buildAppBarDecorationAndroid() //: GuiUtils.buildAppBarDecorationIOS(),
            ),
            shadowColor: Colors.black,
            foregroundColor: Colors.lightBlue,
            title: Container(
                //decoration: //Utils.buildAppBarDecoration(),
                child: Table(
                    columnWidths: const {
                  0: FixedColumnWidth(150.0),
                 // 1: FixedColumnWidth(100.0),
                },
                    children: [
                  TableRow(children: [
                    Column(children: [
                      Text(
                        widget.connectionStatusText != null
                            ? widget.connectionStatusText!
                            : "    ",
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 10),
                      )
                    ]),
                    const Column(),
                  ]),
               
                  TableRow(children: [
                    // Text("${widget.title}",
                    //     style: const TextStyle(
                    //   fontSize: 16, color: Colors.white, letterSpacing: 1)),
                    Column(children: [
                      Text(widget.title,
                      style: const TextStyle(fontSize: 16, color: Colors.white, letterSpacing: 1)),
                      //Text("  $username $email",
                      //    style: const TextStyle(
                      //        fontSize: 15,
                      //        color: Colors.white,
                      //        letterSpacing: 1)),
                    ]),
                    const Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("            v_2025-06-02",
                              style:
                                  TextStyle(fontSize: 9, color: Colors.white))
                        ])
                  ]), const TableRow(children: [
                  Column(), Column()]),
                  TableRow(children: [
                    Column(children: [
                      Text("    ",)
                    ]),
                    const Column(),
                  ]),
                ]))));
  }
}
