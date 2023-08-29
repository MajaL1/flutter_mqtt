import 'package:flutter/material.dart';
import 'package:mqtt_test/model/notif_message.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/api/api_service.dart';

import 'drawer.dart';
import 'model/alarm.dart';

class TestNotifications1 extends StatelessWidget {
  const TestNotifications1({Key? key}) : super(key: key);


  void showNotificationDetail(index) {
    // Todo: open detail
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<NotifMessage>>(
      future: ApiService.getNotifMess(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: const Text("Scheduled Notifications"),
              ),
              drawer: NavDrawer(),
              body: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        title: Text(snapshot.data![index].title),
                        leading: FlutterLogo(),
                        subtitle: Row(
                          children: <Widget>[
                            Text(snapshot.data![index].description!),
                            Text("  -  "),
                            Text(
                              snapshot.data![index].on as String,
                              style: TextStyle(fontWeight: FontWeight.w800),
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

  void showAlarmDetail(int index) {}
}
