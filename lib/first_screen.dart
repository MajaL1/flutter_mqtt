import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/alarm_history.dart';
import 'package:mqtt_test/user_settings.dart';

import 'LoginForm.dart';

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

   return Scaffold(
      body: LoginForm(),
      appBar: AppBar(
        actions: <Widget>[
          TextButton(
            style: style,
            onPressed: () {
              MaterialPageRoute(builder: (context) => AlarmHistory());
              // Navigator.pushNamed(context, "/user_history");
            },
            child: const Text('History'),
          ),
          TextButton(
            style: style,
            onPressed: () {
              //ScaffoldMessenger.of(context).showSnackBar(
              //  const SnackBar(content: Text('This is a snackbar')));
              /*Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return UserSettings();
                    }
                  ));*/
              print("Clicked");
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserSettings())
                //Navigator.pushNamed(context, "/");
              );
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}