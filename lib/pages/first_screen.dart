import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mqtt_test/mqtt/MQTTConnectionManager.dart';
import 'package:mqtt_test/util/app_preference_util.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import '../mqtt/state/MQTTAppState.dart';
import '../util/mqtt_connect_util.dart';
import 'login_form.dart';
import 'alarm_history.dart';

class FirstScreen extends StatefulWidget {
  //final  sharedPref;
  late MQTTConnectionManager? manager;

  late MQTTAppState? currentAppState;

  FirstScreen(MQTTAppState currentAppState, MQTTConnectionManager manager,
      {Key? key})
      : super(key: key) {
    manager = manager;
    currentAppState = currentAppState;
  }

  FirstScreen.base();

  var username = SharedPrefs().username;
  var token = SharedPrefs().token;

  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  late MQTTAppState currentAppState;
  late MQTTConnectionManager manager;

  @override
  initState() {
    super.initState();
    // ignore: avoid_print
    print("-- firstScreen initstate");
    //

    //  initalizeConnection();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("token: $SharedPrefs().token, ${SharedPrefs().token == null}");

    return Scaffold(body: FutureBuilder(
        //future: _initUser(),
        builder: (context, snapshot) {
      //if (currentAppState != null) {
      return SharedPrefs().token.isEmpty
          ? LoginForm(currentAppState, manager)
          : MQTTView(currentAppState, manager);
      // }
    }));
/*return ChangeNotifierProvider<MQTTAppState>(
        create: (_) => MQTTAppState(),
        //child: FirstScreen.base(),
        builder: (context, child)  {
         // final MQTTAppState appState =  Provider.of<MQTTAppState>(context);
          //setCurrentAppState(appState);
          manager = MQTTConnectionManager(
              host: 'test.navis-livedata.com', //_hostTextController.text,
              topic: 'c45bbe821261/settings'
                  '', //_topicTextController.text,
              identifier: "Android",
              state: currentAppState);
          return SharedPrefs().token.isEmpty ? LoginForm(currentAppState, manager) : MQTTView(currentAppState, manager);
        }); */
  }

  Future<void> setCurrentAppState(appState) async {
    currentAppState = appState;
  }
}
