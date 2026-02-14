import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mqtt_test/api/notification_helper.dart';
import 'package:mqtt_test/main.dart';
import 'package:mqtt_test/model/user.dart';
//import 'package:mqtt_test/model/alarm.dart';
import 'package:mqtt_test/model/user_topic.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_service.dart';
import '../model/constants.dart';

import '../util/background_mqtt.dart';
import '../util/gui_utils.dart';
import '../util/utils.dart';

class LoginForm extends StatefulWidget {
  LoginForm.base({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormValidationState();
  late String? connectionStatusText = "";

// final VoidCallback _onPressed;
}
/*
@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
 void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, inputData) async {
    Workmanager().registerPeriodicTask(
      "simplePeriodicTask",
      "simplePeriodicTask1",
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: Duration(seconds: 5), //duration before showing the notification
      constraints: Constraints(networkType: NetworkType.connected),
      frequency: Duration(seconds: 10),
      //inputData: {'optional': true}
    );
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("workmanagerStarted", true);
    print("simplePeriodicTask was executed1, inputData: $inputData");
    return Future.value(true);
  });
} */

class _LoginFormValidationState extends State<LoginForm> {
  //InternetStatus? _connectionStatus;
  //late StreamSubscription<InternetStatus> _subscription;
  bool isLoading = false;
  bool loginError = false;
  bool licenseError = false;

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  String emailText = "test3";
  String passwordText = "Test@1234";

  //String emailText = "test1";
  //String passwordText = "Test@1234";

  String usernameVal = '';
  String passwordVal = '';

  /*final emailController = TextEditingController(
    text: "test",
  );
  final passwordController = TextEditingController(text: "Test1234");

*/
  /*final emailController = TextEditingController(text: "test3");
  final passwordController =
      TextEditingController(text: "OTA1YzRhZDNlZjAxMjU4Zg=="); */
  final emailController = TextEditingController(text: "");
  final passwordController = TextEditingController(text: "");

  //bool run =  SharedPreferences


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F7FA),
                  Color(0xFFE4ECF7),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: formkey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          if (widget.connectionStatusText != null &&
                              widget.connectionStatusText!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                widget.connectionStatusText!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                          /// LOGO
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: SizedBox(
                              width: 110,
                              height: 110,
                              child: Image.asset(
                                'assets/images/LOGO_NEW_ORIG.png',
                              ),
                            ),
                          ),

                          /// CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: buildLoginBoxDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  Constants.LOGIN_TO_NAVIS,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A1F44),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                /// USERNAME
                                TextFormField(
                                  initialValue: emailText,
                                  decoration: GuiUtils
                                      .buildInputUsernameLoginDecoration(),
                                  onChanged: (value) {
                                    setState(() {
                                      usernameVal = value;
                                    });
                                  },
                                  validator: MultiValidator([
                                    RequiredValidator(errorText: "Required")
                                  ]),
                                ),
                                const SizedBox(height: 16),

                                /// PASSWORD
                                TextFormField(
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  initialValue: passwordText,
                                  decoration:
                                  buildInputUsernamePasswordDecoration(),
                                  onChanged: (value) {
                                    setState(() {
                                      passwordVal = value;
                                    });
                                  },
                                  validator: MultiValidator([
                                    RequiredValidator(errorText: "* Required"),
                                  ]),
                                ),

                                const SizedBox(height: 24),

                                /// LOGIN BUTTON
                                SizedBox(
                                  height: 50,
                                  child: !isLoading
                                      ? ElevatedButton(
                                    style: GuiUtils
                                        .buildElevatedButtonLogin(),
                                    onPressed: () async {
                                      if (usernameVal.isEmpty) {
                                        usernameVal = emailText;
                                      }
                                      if (passwordVal.isEmpty) {
                                        passwordVal = passwordText;
                                      }

                                      notificationPermissionGranted()
                                          .then((val) async {
                                        bool isError = await login(
                                            usernameVal, passwordVal);
                                        if (isError) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      });

                                      if (!mounted) return;
                                      setState(() {
                                        isLoading = true;
                                      });
                                    },
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        letterSpacing: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                      : const Center(
                                    child:
                                    CircularProgressIndicator(),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                /// ERRORS
                                if (loginError)
                                  const Text(
                                    "Login error",
                                    textAlign: TextAlign.center,
                                    style:
                                    TextStyle(color: Colors.redAccent),
                                  ),

                                if (licenseError)
                                  const Text(
                                    "License expired",
                                    textAlign: TextAlign.center,
                                    style:
                                    TextStyle(color: Colors.redAccent),
                                  ),

                                if (!loginError && !licenseError)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      "or",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),

                                /// REGISTER
                                TextButton(
                                  onPressed: () {},
                                  child: InkWell(
                                    child: const Text(
                                      Constants.CREATE_ACCOUNT,
                                      style: TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onTap: () =>
                                        launchUrl(Constants.REGISTER_URL),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
              width: 0.75, color: Color.fromRGBO(108, 165, 222, 60)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: Color.fromRGBO(108, 165, 222, 60), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        //labelText: Constants.PASSWORD,
        labelStyle: const TextStyle(letterSpacing: 1.8),
        hintText: Constants.ENTER_SECURE_PASS,
        hintStyle: const TextStyle(fontSize: 12));
  }


  BoxDecoration buildLoginBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

/*
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
*/
  @pragma(
      'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+

  @override
  void dispose() {
    //_subscription.cancel();
    super.dispose();
  }

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

  @override
  initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    /*_subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        //_connectionStatus = status;
        widget.connectionStatusText =
            status == InternetStatus.connected ? "" : "No internet connection";
      });
    }); */
    debugPrint("-- loginform initstate");
  }

  Future<bool> login(String username, String password) async {
    //debugPrint("u, p $username, $password");

    //check email and password
    if (formkey.currentState!.validate()) {
      // test - odkomentiraj, ce ni connectiona
      // await Navigator.pushReplacement(
      //   context, MaterialPageRoute(builder: (_) => UserSettings.base()));

      try {
        User? user = await ApiService.login(username, password);
        if(user!.licenceExpired){
         licenseError = true;
         //debugPrint("====licenceError:: $licenseError");
          return true;
        }
        else {
          debugPrint(
            "loginForm, user: $user.username, ${user.email}, $user.password, $user.topic");
        }
        List<String> userTopicList = Utils.createTopicListFromApi(user);
        await SharedPreferences.getInstance().then((value) async {
          value.setString("username", username);
          value.setString("pass", password);
          // value.setStringList("user_topics", userTopicList);
          value.setString("username", user.username);

          await value.setString("email", user.email);

          value.setString("mqtt_username", user.username);
          value.setString("mqtt_pass", user.mqtt_pass);

          debugPrint("--- user.userTopicList: ${user.userTopicList}");

          String userTopicListPref = jsonEncode(userTopicList);
          List<UserTopic> userTopicListRw = user.userTopicList;
          String userTopicListRwStr = jsonEncode(userTopicListRw);

          value.setString("user_topic_list", userTopicListPref);
          value.setString("user_topic_list_rw", userTopicListRwStr);

          value.reload();
        });
// TODO: IOS

        //if(Platform.isAndroid){
          if(await serviceAndroid.isRunning()){
            print("---- login isRunning");
            debugPrint("---- login isRunning");
          }
          else {
            debugPrint("---- login notRunning");
            print("---- notRunning");
            await BackgroundMqtt(flutterLocalNotificationsPlugin).initializeService(
                serviceAndroid);
          }
        //}
        /*else if(Platform.isIOS) {
          if(await serviceIOS.isServiceRunning()){
            print("---- login isRunning");
            debugPrint("---- login isRunning");
          }
          else {
            debugPrint("---- login notRunning");
            print("---- notRunning");
            await BackgroundMqtt(flutterLocalNotificationsPlugin).initializeService(
                serviceIOS);
          }
        }*/

        //await smartMqtt.initializeMQTTClient();
        // inicializiraj servis za posiljanje sporocil
        await NotificationHelper.initializeService();
        await SharedPreferences.getInstance().then((value) {
          value.setBool("isLoggedIn", true);
        });

        loginError = false;
        licenseError = false;

        // await service.startService();
        /* await Workmanager().initialize(
            callbackDispatcher, // The top level function, aka callbackDispatcher
            isInDebugMode:
            true, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
          );
        Workmanager().registerPeriodicTask("simplePeriodicTask", "simplePeriodicTask1", inputData: {"isConnected": true}
        , existingWorkPolicy: ExistingWorkPolicy.append);
*/
        //FlutterBackgroundService().startService();
        await Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AlarmHistory()));

        debugPrint("Validated");

      } catch (e) {
        debugPrint("e: $e");
        setState(() {
          loginError = true;
        });
      }
    } else {
      return false;
    }
    debugPrint("loginError: $loginError");
    return loginError;
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

  static Future<bool> notificationPermissionGranted() async {
    bool isGranted = true;
    if(Platform.isAndroid){
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
    ].request();
    statuses.forEach((key, permission) {
      if (permission.isDenied) {
        isGranted = false;
      }
    });
    return isGranted;
    }
    return true;
  }
}
