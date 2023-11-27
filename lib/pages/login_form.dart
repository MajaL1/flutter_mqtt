import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_test/model/topic_data.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_service.dart';
import '../model/constants.dart';
import '../model/user.dart';

//**  ToDo: implementiraj onLoginSuccess **/
class LoginForm extends StatefulWidget {
  const LoginForm.base({Key? key}) : super(key: key);


  @override
  State<LoginForm> createState() => _LoginFormValidationState();
}

class _LoginFormValidationState extends State<LoginForm> {
  bool loginError = false;
  late bool userIsLoggedIn = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: "test");
  final passwordController = TextEditingController(text: "Test1234");

  @override
  initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    // _initCurrentAppState();
    // ignore: avoid_print
    print("-- loginform initstate");
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> login() async {
    var username = emailController.text;
    var password = passwordController.text;

    debugPrint("u, p $username, $password");

    //check email and password
    if (formkey.currentState!.validate()) {
      // todo: odkomentiraj login

      User? user = await ApiService.login(username, password);
      if (user != null) {
        debugPrint(
            "loginForm, user: $user.username, $user.password, $user.topic");

        List<String> userTopicList = createTopicListFromApi(user);
        SmartMqtt mqtt = SmartMqtt(
            host: Constants.BROKER_IP,
            port: Constants.BROKER_PORT,
            username: user.username,
            mqttPass: user.mqtt_pass,
            topicList: userTopicList);
        mqtt.initializeMQTTClient();
      }
      //*********************************************/
      Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => UserSettings.base()));

      debugPrint("Validated");
    }
    else {
      loginError = true;
    }
  }

  List<String> createTopicListFromApi(User user) {
     List<TopicData> userTopicDataList = user.topic.topicList;
    List<String> userTopicList = [];
    String deviceName = user.topic.sensorName;
    for (TopicData topicData in userTopicDataList) {
      if (topicData.name.contains("settings")) {
        userTopicList.add(deviceName + "/settings");
      }
      if (topicData.name.contains("alarm")) {
        userTopicList.add(deviceName + "/alarm");
      }
    }
    return userTopicList;
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
    bool network = true; //hasNetwork().then((value) => value);
    return DefaultTabController(
      length: 3,
      // child: SingleChildScrollView(
      child: Scaffold(
          backgroundColor: Colors.white,
          //appBar: AppBar(
          // title: const Text(Constants.LOGIN_PAGE),
          //),
          body: FutureBuilder(
              // Todo: v Future preveri, ali povezava deluje, refactor, vrni exception, ce ni povezan
              // future: _initCurrentAppState(),
              builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (!network) {
                return ErrorWidget(
                    Exception('Problem with internet connection'));
              }
              if (snapshot.hasError) {
                return ErrorWidget(Exception(
                    'Error occured when fetching data from database $snapshot.error'));
              } else {
                return SingleChildScrollView(
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
                        const Text(Constants.ENTER_USERNAME_AND_PASS),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: Constants.EMAIL,
                                hintText: Constants.ENTER_VALID_EMAIL),
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
                                labelText: Constants.PASSWORD,
                                hintText: Constants.ENTER_SECURE_PASS),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
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
                              Constants.FORGOT_PASS,
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
                            onPressed: () {  },
                            child: InkWell(
                                child: const Text(Constants.CREATE_ACCOUNT),
                                onTap: () => launchUrl(Constants.REGISTER_URL)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15, bottom: 0),
                          child: loginError == true ? const Text(
                            "Incorrect username or password",
                          style: TextStyle(color: Colors.redAccent),
                          ) : const Text (""),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
          })),
    );
  }
}
