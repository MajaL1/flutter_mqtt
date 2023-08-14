import 'package:flutter/material.dart';
import 'package:mqtt_test/user_settings.dart';
import 'package:mqtt_test/api/api_service.dart';

import 'model/alarm.dart';

class AlarmHistory extends StatelessWidget {
  const AlarmHistory({Key? key}) : super(key: key);

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Alarm history"),
            centerTitle: true
        ),
        body:
        ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            ListTile(title: Text('List 1')),
            ListTile(title: Text('List 2')),
            ListTile(title: Text('List 3')),
          ],
        )
    );
  }*/
  Widget build(BuildContext context) {
    return FutureBuilder<List<Alarm>>(
      future: ApiService.getAlarms(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 75,
                  color: Colors.white,
                  child: Center(
                    child: Text(snapshot.data![index].name),
                  ),
                );
              });
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}