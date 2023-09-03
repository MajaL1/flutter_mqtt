import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/api/api_service.dart' as api;
import 'package:mqtt_test/model/notif_message.dart';

import '../model/notif_message.dart';
import '../notification_controller.dart';

///  *********************************************
///     NOTIFICATION PAGE
///  *********************************************
///
class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  //final ReceivedAction receivedAction;

  Future<void> recieveNotifications() async {
    List notifMessageList = await api.ApiService.getNotifMess() as List;

    print('notifMessageList ${notifMessageList}');

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text("notifications page"),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                        onPressed: () {
                          Notify(1); //localnotification method call below
                          // when user top on notification this listener will work and user will be navigated to notification page

                          /*Navigator.of(context).pushNamed(
                            '/test_notifications',
                          );*/
                        },
                        child: Text("Local Notification 1")),
                  Padding(padding: EdgeInsets.all(20)),
                  ElevatedButton(
                      onPressed: () {
                        Notify(2); //localnotification method call below
                        // when user top on notification this listener will work and user will be navigated to notification page

                        /*Navigator.of(context).pushNamed(
                            '/test_notifications',
                          );*/
                      },
                      child: Text("Local Notification 2"))
                  ]
                  )
        )
    );
  }

  void Notify(id) async {
    String timezom = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    /*await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1,
          channelKey: 'key1',
          displayOnForeground: true,
          title: 'This is Notification title',
          body: 'This is Body of Noti',
          bigPicture:
              'https://protocoderspoint.com/wp-content/uploads/2021/05/Monitize-flutter-app-with-google-admob-min-741x486.png',
          notificationLayout: NotificationLayout.BigPicture),

      schedule:
          NotificationInterval(interval: 100, timeZone: timezom, repeats: true),
    );*/



    switch (id) {
      /**  schedule notifications in loop**/
      case 1:
        NotificationController.createNewNotification();
        NotificationController.scheduleNewNotification();

        //NotificationController.executeLongTaskInBackground();
      break;
      case 2: NotificationController.createNewNotification();
       //NotificationController.displayNotificationRationale();
       NotificationController.createNewNotification();
      NotificationController.createNewNotification();
      NotificationController.createNewNotification();
      NotificationController.createNewNotification();
      break;
    }
    //NotificationController.createNewNotification();
    //NotificationController.displayNotificationRationale();
    // NotificationController.scheduleNewNotification();
    NotificationController.initializeLocalNotifications();
  }
}
