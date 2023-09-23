import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:mqtt_test/mqtt/MQTTManager.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';
import '../model/user_topic.dart';

/**  ToDo: implementiraj onLoginSuccess **/
class LoginForm extends StatefulWidget {
  //var sharedPreferences;

  LoginForm();

  @override
  _LoginFormValidationState createState() => _LoginFormValidationState();
}

class _LoginFormValidationState extends State<LoginForm> {
  late bool userIsLoggedIn = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  getLoggedInState() async {
    /*await Helper.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value!;
      });
    }); */
  }

  Future<void> login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var username = emailController.text;
    var password = passwordController.text;

    print("u, p " + username + ", " + password);

    //check email and password
    if (formkey.currentState!.validate()) {
      print("preferences ${sharedPreferences.toString()}");
      // todo: odkomentiraj login
      // User? user = await ApiService.login(username, password);
      User user = await ApiService.getUserData();

      if (user != null) {
        SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
        sharedPreferences.setString("username", user.username);
        sharedPreferences.setString("email", user.email ?? "");

        // todo: inicializiraj Mqtt service za settingse

        if (user.topic != null) {

          List <String> brokerAddressList = [];
          var topicForUser = user.topic.topicList;
          print("user.topic.id : ${user.topic.id}");
          String deviceName = user.topic.id;
          print("deviceName : ${deviceName}");

          print("topicForUser : ${topicForUser}, list of ");
          for (var topic in topicForUser) {
            String topicName = topic.name;
            print("==== name:  ${topic.name}");
            print("==== rw:  ${topic.rw}");
            if(topic != null){
              brokerAddressList.add(deviceName+"/"+topicName);
            }
          }
         connectToBroker(brokerAddressList);
      }
    }

    Navigator.push(
        context,
        /**MaterialPageRoute(builder: (_) => HomePage())); */
        MaterialPageRoute(builder: (_) => MQTTView()));
    print("Validated");
  }

  else {
  LoginForm();
  print("Not Validated");
  }
}

void connectToBroker(List<String> brokerAddressList) {
    for(var brokerAddress in brokerAddressList) {
      print("brokerAddress: ${brokerAddress}");
     /* MQTTManager manager = MQTTManager(
          host: brokerAddress,
          topic: brokerAddress,
          identifier: osPrefix,
          state: currentAppState);
      manager.initializeMQTTClient();
      manager.connect();*/
    }

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
          title: Text("Login Page"),
        ),
        body: SingleChildScrollView(
          child: Form(
            //autovalidate: true, //check for validation while typing
            key: formkey,
            child: Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 30,
                        // child: //Image.asset('asset/images/flutter-logo.png')),
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter valid email id as abc@gmail.com'),
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
                    decoration: InputDecoration(
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
                Padding(
                  padding: const EdgeInsets.only(
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
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child: Container(
                    child: TextButton(
                      onPressed: () {
                        // login();
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                            color: Colors.indigoAccent,
                            decoration: TextDecoration.underline,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
}}
