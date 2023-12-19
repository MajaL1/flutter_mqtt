import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_test/api/notification_helper.dart';
import 'package:mqtt_test/model/topic_data.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_service.dart';
import '../model/constants.dart';
import '../model/user.dart';
import '../util/utils.dart';

//**  ToDo: implementiraj onLoginSuccess **/
class LoginForm extends StatefulWidget {
  const LoginForm.base({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormValidationState();
}

class _LoginFormValidationState extends State<LoginForm> {
  bool loginError = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: "test");
  final passwordController = TextEditingController(text: "Test1234");

  //final emailController = TextEditingController(text: "test3");
  //final passwordController = TextEditingController(text: "OTA1YzRhZDNlZjAxMjU4Zg==");

  @override
  initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    print("-- loginform initstate");

    //bool isNetwork = checkNetwork().;
  }

  Future<bool> checkNetwork() async {
    Future<bool> network = hasNetwork();
    return network;
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

    //debugPrint("u, p $username, $password");

    //check email and password
    if (formkey.currentState!.validate()) {
      // todo: odkomentiraj login
      /** todo: dodaj v secure storage username, password
          in usertopiclist. potem ne bomo potrebovali spodnjih vrstic
          ampak samo tole: await NotificationHelper.initializeService(); **/

      try {
        User? user = await ApiService.login(username, password);
        if (user != null) {
          debugPrint(
              "loginForm, user: $user.username, $user.password, $user.topic");

          List<String> userTopicList = Utils.createTopicListFromApi(user);

          SmartMqtt mqtt = SmartMqtt(
              host: Constants.BROKER_IP,
              port: Constants.BROKER_PORT,
              username: user.username,
              mqttPass: user.mqtt_pass,
              topicList: userTopicList);

          /** saving user data in shared prefs **/
          await SharedPreferences.getInstance().then((value) {
            //value.setString("username", username);
            //value.setString("pass", password);

            value.setString("mqtt_username", user.username);
            value.setString("mqtt_pass", user.mqtt_pass);

            String userTopicListPref = jsonEncode(userTopicList);
            value.setString("user_topic_list", userTopicListPref);
          });

          await mqtt.initializeMQTTClient();
          // inicializiraj servis za posiljanje sporocil
          await NotificationHelper.initializeService();
          await SharedPreferences.getInstance().then((value) {
            value.setBool("isLoggedIn", true);
          });
          //*********************************************/
          await Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => UserSettings.base()));

          debugPrint("Validated");
        } else {
          setState(() {
            loginError = true;
          });
        }
      } catch (e) {
        setState(() {
          loginError = true;
        });
      }
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

  bool _returnHasNetwork(bool val) {
    return val;
  }

  @override
  Widget build(BuildContext context) {
    bool network = true;
    return DefaultTabController(
      length: 3,
      // child: SingleChildScrollView(
      child: WillPopScope(
          onWillPop: () async => false,
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
                    return Container(
                        child: const Text('Problem with internet connection'));
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
                                padding:
                                    EdgeInsets.only(top: 120.0, bottom: 20),
                                child: Center(
                                  child: SizedBox(
                                    width: 120,
                                    height: 50,
                                    child: FlutterLogo(size: 200),
                                  ),
                                )),
                            const Text(
                              Constants.LOGIN_TO_NAVIS,
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 87, 153, 100),
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Roboto',
                                  fontSize: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 65.0, right: 65.0, top: 35, bottom: 30),
                              child: TextFormField(
                                style: const TextStyle(fontFamily: 'Roboto'),
                                decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2, color: Color.fromRGBO(108, 165, 222, 60)), //<-- SEE HERE
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: Colors.indigo, width: 1.5),
                                    ),
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
                                  left: 65.0, right: 65.0, top: 15, bottom: 30),
                              child: TextFormField(
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                style: const TextStyle(fontFamily: 'Roboto'),
                                decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2, color:  Color.fromRGBO(108, 165, 222, 60)), //<-- SEE HERE
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: Colors.indigo, width: 8.5),
                                    ),
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
                              width: 180,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(0, 87, 153, 60),
                                  borderRadius: BorderRadius.circular(9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.25),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: () {
                                  login();
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontFamily: 'Roboto'),
                                ),
                              ),
                            ),
                            /* Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15, bottom: 0),
                          child: TextButton(
                            onPressed: () {
                              // forgotPass();
                            },
                            child: const Text(
                              Constants.FORGOT_PASS,
                              style: TextStyle(
                                  color: Colors.indigoAccent,
                                  decoration: TextDecoration.underline,
                                  fontSize: 15),
                            ),
                          ),
                        ),*/
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 15, bottom: 0),
                              child: TextButton(
                                onPressed: () {},
                                child: InkWell(
                                    child: const Text(Constants.CREATE_ACCOUNT),
                                    onTap: () =>
                                        launchUrl(Constants.REGISTER_URL)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 15, bottom: 0),
                              child: loginError == true
                                  ? const Text(
                                      "Login error",
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontFamily: 'Roboto'),
                                    )
                                  : const Text(""),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
              }))),
    );
  }
}
