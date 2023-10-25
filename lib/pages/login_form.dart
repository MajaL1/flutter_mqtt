import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mqtt_test/mqtt/state/MQTTAppState.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/drawer.dart';
import '../mqtt/MQTTConnectionManager.dart';

//**  ToDo: implementiraj onLoginSuccess **/
class LoginForm extends StatefulWidget {
  //var sharedPreferences;

 late MQTTConnectionManager? manager;
   late MQTTAppState? currentAppState;

  LoginForm(MQTTAppState currentAppState, MQTTConnectionManager manager, {Key? key}) : super(key: key){
    manager = manager;
    currentAppState = currentAppState;
    }
    LoginForm.base();



 /* LoginForm(MQTTConnectionManager manager, {Key? key}) : super(key: key){
    this.manager;
  } */

  @override
  State<LoginForm> createState() => _LoginFormValidationState();
}

class _LoginFormValidationState extends State<LoginForm> {
  late bool userIsLoggedIn = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  late MQTTAppState currentAppState;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late MQTTConnectionManager manager;

  getLoggedInState() async {
    /*await Helper.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value!;
      });
    }); */
  }

  Future<FutureBuilder> login() async {
    var username = emailController.text;
    var password = passwordController.text;

    debugPrint("u, p $username, $password");

    //check email and password
    if (formkey.currentState!.validate()) {
      // todo: odkomentiraj login
      // User? user = await ApiService.login(username, password);
      currentAppState = currentAppState;
      MaterialPageRoute(
          builder: (BuildContext context) =>
              FutureBuilder<String>(
                //future: propositionManager.getData(object.id),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  MQTTView(currentAppState, manager)));
                      debugPrint("Validated");
                    }
                    else {
                      LoginForm(currentAppState, manager);
                      debugPrint("Not Validated");
                    }
                  }
              )
      );
    }
  }

  Future<void> connectToBroker(List<String> brokerAddressList) async {
    for (var brokerAddress in brokerAddressList) {
      // ali vsebuje alarme
      if (brokerAddress.contains('/alarm')) {
      } else if (brokerAddress.contains('/settings')) {
      } else if (brokerAddress.contains('/data')) {}
      debugPrint("brokerAddress: $brokerAddress");
    }
    if (MQTTAppConnectionState.disconnected ==
        currentAppState.getAppConnectionState) {
      await _configureAndConnect();
    }
  }

  // Connectr to brokers
  Future<void> _configureAndConnect() async {
    //final MQTTAppState appState = Provider.of<MQTTAppState>(context);

    // TODO: Use UUID
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    MQTTConnectionManager manager = MQTTConnectionManager(
        host: 'test.navis-livedata.com', //_hostTextController.text,
        topic: 'c45bbe821261/settings'
            '', //_topicTextController.text,
        identifier: osPrefix,
        state: currentAppState);
    manager.initializeMQTTClient();
    await manager.connect();

    if (MQTTAppConnectionState.connected ==
        currentAppState.getAppConnectionState) {
      String t = await currentAppState.getHistoryText;

      debugPrint("****************** $t");
    }

    // pridobivanje najprej settingov, samo za topic (naprave) -dodaj v objekt UserSettings
    if (MQTTAppConnectionState.connected ==
        currentAppState.getAppConnectionState) {
      //MQTTConnectionManager._publishMessage(topic, text);
      String t = await currentAppState.getHistoryText;

      print("****************** $t");
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.get("settings_mqtt").toString();
    String decodeMessage = const Utf8Decoder().convert(data.codeUnits);
    print("****************** data $data");
    Map<String, dynamic> jsonMap = json.decode(decodeMessage);

    // vrne Listo UserSettingsov iz mqtt 'sensorId/alarm'
    // List<UserDataSettings> userSettings = UserDataSettings().getUserDataSettings(jsonMap);

    // debugPrint("UserSettings from JSON: $userSettings");

    // napolnimo nov objekt UserSettings
    // pridobivanje sporocil
    //ce je povezava connected, potem iniciramo zahtevo za pridobivanje alarmov
    //if(MQTTAppConnectionState.connected == true){
    //this.publish('topic');
    //}
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return "* Required";
    } else if (value.length < 6) {
      return "Password should be atleast 6 characters";
    } else if (value.length > 15) {
      return "Password should not be greater than 15 characters";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: const Text("Login Page"),
              ),
              body: SingleChildScrollView(
                child: Form(
                  //autovalidate: true, //check for validation while typing
                  key: formkey,
                  child: Column(
                    children: <Widget>[
                      const Padding(
                          padding: EdgeInsets.only(top: 60.0),
                          child: Center(
                            child: SizedBox(
                              width: 200,
                              height: 30,
                              // child: //Image.asset('asset/images/flutter-logo.png')),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                              hintText:
                                  'Enter valid email id as abc@gmail.com'),
                          controller: emailController,
                          /*validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                      EmailValidator(errorText: "Enter valid email id"),
                    ])*/
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15, bottom: 0),
                        child: TextFormField(
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                              hintText: 'Enter secure password'),
                          controller: passwordController,
                          /* validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                      MinLengthValidator(6,
                          errorText: "Password should be atleast 6 characters"),
                      MaxLengthValidator(15,
                          errorText:
                          "Password should not be greater than 15 characters")
                    ])*/
                          //validatePassword,        //Function to check validation
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15, bottom: 0),
                      ),
                      Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () {
                            login();
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15, bottom: 0),
                        child: TextButton(
                          onPressed: () {
                            // login();
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                                color: Colors.indigoAccent,
                                decoration: TextDecoration.underline,
                                fontSize: 15),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15, bottom: 0),
                        child: TextButton(
                          onPressed: () {
                            // login();
                          },
                          child: const Text(
                            'Create account',
                            style: TextStyle(
                                color: Colors.indigoAccent,
                                decoration: TextDecoration.underline,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
