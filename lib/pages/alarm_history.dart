import 'package:flutter/material.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/drawer.dart';
import '../model/alarm.dart';

class AlarmHistory extends StatelessWidget {
  //var sharedPreferences;

  AlarmHistory();
  // late SharedPreferences sharedPreferences = sharedPreferences;

  void showAlarmDetail(index) {
    // Todo: open detail
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<Alarm>>(
      future: ApiService.getAlarms(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: const Text("History"),
              ),
              body: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.blueGrey))),
                        child: ListTile(
                            title: Text(snapshot.data![index].name),
                            leading: FlutterLogo(),
                            subtitle: Row(
                              children: <Widget>[
                                Text(snapshot.data![index].date!),
                                Text("  -  "),
                                Text(
                                  snapshot.data![index].description,
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            onTap: () {
                              showAlarmDetail(index);
                            }));
                  }));
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}
