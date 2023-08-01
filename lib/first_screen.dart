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
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmHistory())
                //Navigator.pushNamed(context, "/");
              );
            },
            child: const Text('History'),
          ),
          TextButton(
            style: style,
            onPressed: () {
              print("Clicked");
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserSettings())
              );
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}