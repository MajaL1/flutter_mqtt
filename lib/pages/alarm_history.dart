import 'package:flutter/material.dart';
import 'package:mqtt_test/api/api_service.dart';
import '../components/drawer.dart';
import '../model/alarm.dart';
import '../model/constants.dart';

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
      future: ApiService.getAlarmsHistory(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: const Text(Constants.HISTORY),
              ),
              //drawer: NavDrawer(),
              body: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    String sensorAddress = snapshot.data![index].sensorAddress.toString()!;
                    String hiAlarm = snapshot.data![index].hiAlarm.toString()!;
                    String loAlarm = snapshot.data![index].hiAlarm.toString()!;
                    String ts = snapshot.data![index].ts.toString()!;
                    return Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.blueGrey))),
                        child: ListTile(
                            title: Text(sensorAddress),
                            leading: const FlutterLogo(),
                            subtitle: Row(
                              children: <Widget>[
                                const Text(Constants.HI_ALARM),
                                Text(" $hiAlarm"),
                                const Text("  -  "),
                                const Text(Constants.LO_ALARM),
                                Text(" $loAlarm"),
                                const Text("  -  "),
                                const Text(Constants.TS),
                                Text(" $ts"),
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
