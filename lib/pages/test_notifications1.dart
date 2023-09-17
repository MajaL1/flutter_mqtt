import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_test/components/noti.dart';
import 'package:mqtt_test/model/notif_message.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestNotifications1 extends StatelessWidget {
 // const Noti.showBigTextNotification(title: "AA", body: "aa", fln: FlutterLocalNotificationsPlugin)
 // SharedPreferences sharedPref =  SharedPreferences.getInstance() as SharedPreferences;



  void showNotificationDetail(index) {
    // Todo: open detail
  }

  void scheduleNotifications() {
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
              //drawer: NavDrawer(sharedPrefs: ),
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
                              snapshot.data![index].on.toString(),
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
