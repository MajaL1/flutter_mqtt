import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/alarm.dart';
import '../model/constants.dart';

class AlarmHistory extends StatefulWidget {
  //var sharedPreferences;

  const AlarmHistory({Key? key}) : super(key: key);

  @override
  State<AlarmHistory> createState() => _AlarmHistoryState();
}

class _AlarmHistoryState extends State<AlarmHistory> {
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
              body: SingleChildScrollView(
                  child: Column(children: [
                const Padding(
                  padding: EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 7, bottom: 15.0),
                ),
                Container(
                  height: 30,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                      onPressed: () {
                        clearHistory();
                      },
                      child: const Text(
                        'Clear history',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      )),
                ),
                const Divider(height: 40, color: Colors.black12, thickness: 3),
                ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      String sensorAddress =
                          snapshot.data![index].sensorAddress.toString();
                      String hiAlarm = snapshot.data![index].hiAlarm.toString();
                      String loAlarm = snapshot.data![index].loAlarm.toString();
                      String v = snapshot.data![index].v.toString();
                      String alarmValue = "";

                      if (snapshot.data![index].hiAlarm != 0 &&
                          snapshot.data![index].hiAlarm != null) {
                        alarmValue = "Hi alarm: $hiAlarm";
                      }
                      if (snapshot.data![index].loAlarm != 0 &&
                          snapshot.data![index].loAlarm != null) {
                        alarmValue += " Lo alarm: $loAlarm";
                      }
                      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                          .format(snapshot.data![index].ts!);
                      return Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.blueGrey))),
                        child: Table(
                            border: TableBorder.all(color: Colors.black),
                            columnWidths: const {
                              0: FixedColumnWidth(80.0),
                              1: FixedColumnWidth(80.0),
                              2: FixedColumnWidth(80.0),
                            },
                            children: [
                              TableRow(children: [
                                Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text("SensorAddress: $sensorAddress",
                                        textAlign: TextAlign.center)),
                                Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text("Value: $v",textAlign: TextAlign.center)),
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text("$formattedDate  $alarmValue", textAlign: TextAlign.center),
                                )
                              ])
                            ]),

                        /* ListTile(
                          //style: const ListTileStyle(),
                          contentPadding: const EdgeInsets.all(5.0),
                          leading: const Icon(Icons.notifications,
                              color: Colors.blue, size: 30, grade: 5),
                          title: RichText(
                              text: TextSpan(
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                  text: sensorAddress,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ],
                          )),
                          subtitle: Text('$formattedDate\nv: $v \n$alarmValue'),
                          isThreeLine: true,
                        ),*/
                      );
                    })
              ])));
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  Future<void> clearHistory() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.remove("alarm_list_mqtt");
    setState(() {
      //snapshot.data![index].on = value;
    });

    // debugPrint("clear history");
  }
}
