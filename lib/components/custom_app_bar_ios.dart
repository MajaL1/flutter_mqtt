import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

//import 'package:mqtt_test/pages/login_form.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CustomAppBarIos extends StatefulWidget implements PreferredSizeWidget {
  late String? connectionStatusText = "";

  CustomAppBarIos({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight + 22),
        super(key: key);

  @override
  State<CustomAppBarIos> createState() => _CustomAppBarState();

  @override
  final Size preferredSize; // default is 56.0
}

class _CustomAppBarState extends State<CustomAppBarIos> {
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

  
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return const <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('77'),
            )
          ];
        },
        body: const Center(
          child: Material(child: Text('Home Page')),
        ),
      ),
    );
  }
}
