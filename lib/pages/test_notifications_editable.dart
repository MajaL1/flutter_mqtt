import 'package:flutter/material.dart';
import 'package:mqtt_test/components/alarm_list_item.dart';
import 'package:mqtt_test/model/notification_message.dart';
import 'package:mqtt_test/api/api_service.dart';

class TestNotificationsEditable extends StatefulWidget {
  const TestNotificationsEditable({Key? key}) : super(key: key);

  // SharedPreferences sharedPref =  SharedPreferences.getInstance() as SharedPreferences;

  @override
  State<TestNotificationsEditable> createState() =>
      _TestNotificationsEditableState();
}

class _TestNotificationsEditableState extends State<TestNotificationsEditable> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotificationMessage>>(
      future: ApiService.getNotificationMessage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: const Text("Scheduled Notifications"),
              ),
              //drawer: NavDrawer(sharedPrefs: ),
              body: ListView.builder(
                  itemCount: snapshot.data!.length,
                  padding: const EdgeInsets.only(top: 20),
                  itemBuilder: (BuildContext context, int index) {
                    return AlarmListItem(
                      snapshot: snapshot,
                      index: index,
                    );
                  }));
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
