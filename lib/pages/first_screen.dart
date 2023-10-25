import 'dart:async';
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
   MQTTConnectionManager? manager;

   MQTTAppState? currentAppState;

  FirstScreen(MQTTAppState appState, MQTTConnectionManager manager,
      {Key? key})
      : super(key: key) {
    manager = manager;
    currentAppState = appState;
  }

  FirstScreen.base();

  var username = SharedPrefs().username;
  var token = SharedPrefs().token;

  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  MQTTAppState ? currentAppState;
  MQTTConnectionManager ? manager;

  @override
  initState() {
    super.initState();
    // ignore: avoid_print
    print("-- firstScreen initstate");
    //

    //  initalizeConnection();
  }

  _initUser() async {
    Timer(
        Duration(seconds: 2),
        () => {
              setCurrentAppState(currentAppState),
              debugPrint("[[[ currentAppState: $currentAppState ]]]")
            });
    return currentAppState;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("token: $SharedPrefs().token, ${SharedPrefs().token == null}");

    return Scaffold(
        body: FutureBuilder(
            future: _initUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasError) {
                  return ErrorWidget(Exception(
                      'Error occured when fetching data from database'));
                } else if (!snapshot.hasData) {
                  debugPrint("snapshot:: $snapshot");
                  return const Center(child: Text('Data is empty!'));
                } else {
                  return SharedPrefs().token.isEmpty
                      ? LoginForm(currentAppState!, manager!)
                      : MQTTView(currentAppState!, manager!);
                }
              }
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
