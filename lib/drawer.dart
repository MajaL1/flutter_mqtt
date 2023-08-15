import 'package:flutter/material.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/alarm_history.dart';
import 'package:mqtt_test/widgets/mqttView.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.50,
      child: Drawer(
        child: Container(
          color: Colors.blue,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('Settings'),
                textColor: Colors.white,
                trailing: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UserSettings())),
              ),
              ListTile(
                title: Text('Alarms'),
                textColor: Colors.white,
                trailing: Icon(
                  Icons.alarm,
                  color: Colors.white,
                ),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MQTTView())),
              ),
              ListTile(
                title: Text('History'),
                textColor: Colors.white,
                trailing: Icon(
                  Icons.history,
                  color: Colors.white,
                ),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AlarmHistory())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
