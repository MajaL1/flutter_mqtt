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
import '../components/drawer.dart';
import '../model/user.dart';
import '../mqtt/state/MQTTAppState.dart';
import '../util/mqtt_connect_util.dart';
import 'login_form.dart';
import 'alarm_history.dart';

class FirstScreen extends StatefulWidget {
  //final  sharedPref;
  late MQTTConnectionManager manager;

  late MQTTAppState currentAppState;

  FirstScreen(MQTTAppState appState, MQTTConnectionManager connectionManager,
      {Key? key})
      : super(key: key) {
    currentAppState = appState;
    manager = connectionManager;
  }

  FirstScreen.base();

  var username = SharedPrefs().username;
  var token = SharedPrefs().token;

  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  //late MQTTAppState currentAppState;
  //late MQTTConnectionManager manager;

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
              setCurrentAppState(widget.currentAppState),
              setManager(widget.manager),
              debugPrint("[[[ currentAppState: $widget.currentAppState ]]]")
            });
    return widget.currentAppState;
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
                      'Error occured when fetching data from database $snapshot.error'));
                } else if (!snapshot.hasData) {
                  debugPrint("snapshot:: $snapshot");
                  // return LoginForm(widget.currentAppState, widget.manager);
                  return LoginForm.base();
                } else {
                  return /* SharedPrefs().token.isEmpty
                      ? LoginForm(widget.currentAppState, widget.manager)
                      : MQTTView(widget.currentAppState, widget.manager); */
                      Scaffold(
                          drawer:
                              NavDrawer(widget.currentAppState, widget.manager),
                          body: LoginForm.base());
                }
              }
            }));
  }

  Future<void> setCurrentAppState(appState) async {
    widget.currentAppState = appState;
  }

  Future<void> setManager(manager) async {
    widget.manager = manager;
  }
}
