import 'package:flutter/material.dart';
import 'package:mqtt_test/util/app_preference_util.dart';

import 'login_form.dart';

class FirstScreen extends StatefulWidget {
  /*MQTTConnectionManager manager;
  MQTTAppState currentAppState;

  FirstScreen(MQTTAppState appState, MQTTConnectionManager connectionManager,
      {Key? key})
      : currentAppState = appState,
        manager = connectionManager,
        super(key: key);


  get appState {
    return currentAppState;
  }

  get connectionManager {
    return manager;
  } */

  FirstScreen.base();

  var username = SharedPrefs().username;
  var token = SharedPrefs().token;

  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  initState() {
    super.initState();
    debugPrint("-- firstScreen initstate");
  }

  /*_initCurrentAppState() async {
    Timer(
        const Duration(seconds: 2),
        () => {
              setCurrentAppState(widget.currentAppState),
              setManager(widget.manager),
              debugPrint("[[[ currentAppState: $widget.currentAppState ]]]")
            });
    return widget.currentAppState;
  } */

  @override
  Widget build(BuildContext context) {
    debugPrint("token: $SharedPrefs().token, ${SharedPrefs().token == null}");

    return Scaffold(
        //  drawer: NavDrawer(widget.currentAppState, widget.manager),
        body: FutureBuilder(
            //future: _initCurrentAppState(),
            builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return Scaffold(
            // drawer: NavDrawer(widget.currentAppState, widget.manager),
            // TODO: preveri, ali je uporabnik logiran
            // body: !userLoggedIn ?? LoginForm(widget.currentAppState, widget.manager)) : UserSettings(widget.currentAppState, widget.manager);
            body: LoginForm.base());
      }
    }));
  }
}
