import 'package:flutter/material.dart';
import 'package:mqtt_test/mqtt/MQTTConnectionManager.dart';
import 'package:mqtt_test/util/app_preference_util.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/widgets/mqttView.dart';
import '../model/user.dart';
import '../util/mqtt_connect_util.dart';
import 'login_form.dart';
import 'alarm_history.dart';

class FirstScreen extends StatefulWidget {
  //final  sharedPref;
  MQTTConnectionManager? manager;

 /* FirstScreen(MQTTConnectionManager manager, {Key? key}) : super(key: key) {
    this.manager;
  } */

  var username = SharedPrefs().username;
  var token = SharedPrefs().token;

  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    //this.sharedPref.setString('token', "test");
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

    debugPrint("token: $SharedPrefs().token, ${SharedPrefs().token == null}");

    return Scaffold(
      body: SharedPrefs().token.isEmpty ? LoginForm() : MQTTView(),
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Login'),
          leading: IconButton(
            icon: (SharedPrefs().token != null)
                ? const Icon(Icons.arrow_back)
                : const Icon(
                    Icons.notifications_none,
                    color: Colors.transparent,
                  ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: SharedPrefs().token.isNotEmpty
              ? <Widget>[
                  TextButton(
                    style: style,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AlarmHistory())
                          //Navigator.pushNamed(context, "/");
                          );
                    },
                    child: const Text('History'),
                  ),
                  TextButton(
                    style: style,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserSettings()));
                      // Navigator.pushNamed(context, '/settings');
                    },
                    child: const Text('Settings'),
                  ),
                  TextButton(
                    style: style,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MQTTView()));
                    },
                    child: const Text('Alarms'),
                  ),
                  TextButton(
                    style: style,
                    onPressed: () {
                      debugPrint("Clicked");
                    },
                    child: const Text('Logout'),
                  ),
                ]
              : null),
      //appBar: ,
    );
  }

  // ***************** connect to broker ****************
  /* User user =  MqttConnectUtil.readUserData();
    MqttConnectUtil.getBrokerAddressList(user);
    MqttConnectUtil.initalizeUserPrefs(user);
    List<String> brokerAddressList =
    MqttConnectUtil.getBrokerAddressList(user);
    connectToBroker(brokerAddressList); */
  // *****************************************************

  void connectToBroker(List<String> brokerAddressList) {}
}
