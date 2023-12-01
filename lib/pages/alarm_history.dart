import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_test/api/api_service.dart';

import '../model/alarm.dart';
import '../model/constants.dart';

class AlarmHistory extends StatelessWidget {
  //var sharedPreferences;

  const AlarmHistory({Key? key}) : super(key: key);

  void showAlarmDetail(index) {
    // Todo: open detail
  }

  List<Alarm> _returnAlarmList(List<Alarm> alarmList) {
    return alarmList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Alarm>>(
      future: ApiService.getAlarmsHistory()
          .then((alarmHistoryList) => _returnAlarmList(alarmHistoryList)),
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
                    String sensorAddress =
                        snapshot.data![index].sensorAddress.toString()!;
                    String hiAlarm = snapshot.data![index].hiAlarm.toString()!;
                    String loAlarm = snapshot.data![index].loAlarm.toString()!;
                    String? ts = snapshot.data![index].ts?.toLocal().toString();

                    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                        .format(snapshot.data![index].ts!);
                    return Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.blueGrey))),
                      child: ListTile(
                        //style: const ListTileStyle(),
                        contentPadding: EdgeInsets.all(10.0),
                        leading:
                            const Icon(Icons.notifications, color: Colors.blue, size: 30, grade: 5),
                        title: RichText(
                            text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                                text: "$sensorAddress \n",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        )),
                        subtitle: Text(
                            '$formattedDate \nhi alarm: $hiAlarm \nlo alarm: $loAlarm'),
                        isThreeLine: true,
                      ),
                    );
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
