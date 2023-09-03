import 'package:flutter/material.dart';
import 'package:mqtt_test/model/notif_message.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer.dart';
import 'model/alarm.dart';

class TestNotificationsEditable extends StatefulWidget {
  const TestNotificationsEditable();

  // SharedPreferences sharedPref =  SharedPreferences.getInstance() as SharedPreferences;

  @override
  _TestNotificationsEditableState createState() =>
      _TestNotificationsEditableState();
}

class _TestNotificationsEditableState extends State<TestNotificationsEditable> {
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotifMessage>>(
      future: ApiService.getNotifMess(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: const Text("Scheduled Notifications"),
              ),
              //drawer: NavDrawer(sharedPrefs: ),
              body: ListView.builder(
                  itemCount: snapshot.data!.length,
                  padding: EdgeInsets.only(top: 20),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        contentPadding: EdgeInsets.only(
                            left: 10, right: 10, top: 20, bottom: 20),
                        title: Text(snapshot.data![index].title),
                        leading: ImageIcon(
                          AssetImage("lib/assets/bell.png"),
                          color: Color(0xFF3A5A98),
                        ),
                        subtitle: Row(
                          children: <Widget>[
                            Text(snapshot.data![index].description!),
                            Text("  -  "),
                            Text(
                              snapshot.data![index].on.toString(),
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            Switch(
                              activeColor: Colors.greenAccent,
                              inactiveThumbColor: Colors.redAccent,
                              value: snapshot.data![index].on ? true : false,
                              onChanged: (bool value) {
                                print(
                                    "old value:: ${snapshot.data![index].on}");
                                print("new value:: ${value}");
                                setState(() {
                                  snapshot.data![index].on = value;
                                });
                                changeAlarmEnabled(index, value);
                              },
                            ),
                          ],
                        ),

                        //Text(snapshot.data![index].date!),

                        onTap: () {
                          showAlarmDetail(index);
                        });
                  }));
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  void changeAlarmEnabled(int id, bool value) {
    print("calling changeAlarmEnabled: ${id}, ${value}");
  }

  void showAlarmDetail(int id) {}
}
