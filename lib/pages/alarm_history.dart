import 'package:flutter/material.dart';
import 'package:mqtt_test/api/api_service.dart';
import '../components/drawer.dart';
import '../model/alarm.dart';

class AlarmHistory extends StatelessWidget {
  //var sharedPreferences;

  const AlarmHistory({Key? key}) : super(key: key);

  // late SharedPreferences sharedPreferences = sharedPreferences;

  void showAlarmDetail(index) {
    // Todo: open detail
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Alarm>>(
      future: ApiService.getAlarms(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: const Text("History"),
              ),
              drawer: NavDrawer.base(),
              body: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.blueGrey))),
                        child: ListTile(
                            title: Text(snapshot.data![index].name),
                            leading: const FlutterLogo(),
                            subtitle: Row(
                              children: <Widget>[
                                Text(snapshot.data![index].date!),
                                const Text("  -  "),
                                Text(
                                  snapshot.data![index].description,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
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
