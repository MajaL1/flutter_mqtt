import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
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
  InternetStatus? _connectionStatus;
  String? connectionStatusText;
  late StreamSubscription<InternetStatus> _subscription;

  bool loginError = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final emailController = TextEditingController(
    text: "test",
  );
  final passwordController = TextEditingController(text: "Test1234");

  //final emailController = TextEditingController(text: "test3");
  //final passwordController = TextEditingController(text: "OTA1YzRhZDNlZjAxMjU4Zg==");

  @override
  initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        _connectionStatus = status;
        connectionStatusText =
            status == InternetStatus.connected ? "" : "No internet connection";
      });
    });
    print("-- loginform initstate");
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> login() async {
    var username = emailController.text;
    var password = passwordController.text;

    //debugPrint("u, p $username, $password");

    //check email and password
    if (formkey.currentState!.validate()) {
      /** todo: dodaj v secure storage username, password
          in usertopiclist. potem ne bomo potrebovali spodnjih vrstic
          ampak samo tole: await NotificationHelper.initializeService(); **/

      // test - odkomentiraj, ce ni connectiona
      // await Navigator.pushReplacement(
      //   context, MaterialPageRoute(builder: (_) => UserSettings.base()));

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

            value.setString("username", user.username);

            if (user.email != null) {
              value.setString("email", user.email!);
            }

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
                  if (snapshot.hasError) {
                    return ErrorWidget(Exception(
                        'Error occured when fetching data from database $snapshot.error'));
                  } else {
                    return SingleChildScrollView(
                        child: Form(
                            //autovalidate: true, //check for validation while typing
                            key: formkey,
                            child: Container(
                                color: Colors.white54,
                                child: Column(children: <Widget>[
                                  Container(
                                      padding: const EdgeInsets.only(
                                          top: 25.0, bottom: 0),
                                      child: Text(
                                        connectionStatusText != null
                                            ? connectionStatusText!
                                            : "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                      )),
                                  const Padding(
                                      padding: EdgeInsets.only(
                                          top: 100.0, bottom: 40),
                                      child: Center(
                                        child: SizedBox(
                                          width: 120,
                                          height: 50,
                                          child: FlutterLogo(size: 200),
                                        ),
                                      )),
                                  Container(
                                    width: 350,
                                    // color: Color.fromRGBO(24, 125, 255, 0.05),
                                    decoration: buildLoginBoxDecoration(),
                                    child: Column(
                                      children: [
                                        Text(""),
                                        Text(""),
                                        const Text(
                                          Constants.LOGIN_TO_NAVIS,
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(0, 0, 102, 1),
                                              wordSpacing: 2.9,
                                              fontWeight: FontWeight.w900,
                                              fontStyle: FontStyle.normal,
                                              fontFamily: 'Ariel',
                                              fontSize: 16),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 65.0,
                                              right: 65.0,
                                              top: 35,
                                              bottom: 30),
                                          child: TextFormField(
                                            style: const TextStyle(
                                                fontFamily: 'Roboto',
                                                color: Color.fromRGBO(
                                                    00, 20, 20, 80),
                                                fontSize: 16),
                                            decoration:
                                                buildInputUsernameLoginDecoration(),
                                            controller: emailController,

                                            /*   validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                      EmailValidator(errorText: "Enter valid username),
                    ]) */
                                          ),
                                        ),
                                        Container(
                                          height: 60,
                                          width: 220,
                                          child: TextFormField(
                                              obscureText: true,
                                              enableSuggestions: false,
                                              autocorrect: false,
                                              style: const TextStyle(
                                                  fontFamily: 'Roboto',
                                                  color: Color.fromRGBO(
                                                      00, 20, 20, 80),
                                                  fontSize: 16),
                                              decoration:
                                                  buildInputUsernamePasswordDecoration(),
                                              controller: passwordController,
                                              validator: MultiValidator([
                                                RequiredValidator(
                                                    errorText: "* Required"),
                                                MinLengthValidator(6,
                                                    errorText:
                                                        "Password should be at least 6 characters"),
                                              ])
                                              //validatePassword,        //Function to check validation
                                              ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              left: 15.0,
                                              right: 15.0,
                                              top: 15,
                                              bottom: 10),
                                        ),
                                        Container(
                                          height: 50,
                                          width: 120,
                                          decoration: Utils
                                              .buildLoginButtonBoxDecoration(),
                                          child: TextButton(
                                            onPressed: () {
                                              login();
                                            },
                                            child: const Text(
                                              'Login',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontFamily: 'Roboto',
                                              letterSpacing: 1.5),
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
                                              left: 15.0,
                                              right: 15.0,
                                              top: 35,
                                              bottom: 0),
                                          child: TextButton(
                                            onPressed: () {},
                                            child: InkWell(
                                                child: const Text(
                                                  Constants.CREATE_ACCOUNT,
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        0, 0, 220, 1),
                                                  ),
                                                ),
                                                onTap: () => launchUrl(
                                                    Constants.REGISTER_URL)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0,
                                              right: 15.0,
                                              top: 15,
                                              bottom: 20),
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
                                ]))));
                  }
                }
              }))),
    );
  }

  InputDecoration buildInputUsernamePasswordDecoration() {
    return InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12, width: 8.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              width: 0.5, color: Color.fromRGBO(108, 165, 222, 60)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Color.fromRGBO(108, 165, 222, 60), width: 2),
        ),
        labelText: Constants.PASSWORD,
        labelStyle: const TextStyle(letterSpacing: 1.8),
        hintText: Constants.ENTER_SECURE_PASS,
        hintStyle: const TextStyle(fontSize: 12));
  }

  InputDecoration buildInputUsernameLoginDecoration() {
    return InputDecoration(
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.blueAccent,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              width: 0.5, color: Color.fromRGBO(108, 165, 222, 60)),
          borderRadius: BorderRadius.circular(16), //
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Color.fromRGBO(108, 165, 222, 60), width: 2.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(color: Colors.black12, width: 0.5),
        ),
        labelText: Constants.USER,
        labelStyle: const TextStyle(letterSpacing: 1.8),
        hintText: Constants.ENTER_VALID_USER,
        hintStyle: const TextStyle(fontSize: 12));
  }

  BoxDecoration buildLoginBoxDecoration() {
    return const BoxDecoration(
      //color: Colors.,
      color: Color.fromRGBO(24, 125, 255, 0.10),
      border: Border(
          bottom:
              BorderSide(color: Color.fromRGBO(0, 87, 153, 0.2), width: 0.5),
          top: BorderSide(color: Color.fromRGBO(0, 87, 153, 0.2), width: 0.5),
          left: BorderSide(color: Color.fromRGBO(0, 87, 153, 0.2), width: 0.5),
          right:
              BorderSide(color: Color.fromRGBO(0, 87, 153, 0.2), width: 0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurStyle: BlurStyle.outer,
          spreadRadius: 2,
          blurRadius: 4,
          // offset: Offset(
          //   2, 2), // changes position of shadow
        ),
      ],
    );
  }
}
