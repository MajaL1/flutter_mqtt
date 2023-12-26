import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/alarm.dart';
import '../model/constants.dart';
import '../util/utils.dart';

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
                title: const Text(Constants.HISTORY,style: TextStyle(fontSize: 16)),
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
                  decoration: Utils.buildBoxDecoration(),                  child: TextButton(
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
                      bool isHeader = index == 0;
                      //     DateTime ts = snapshot.data![index].ts!;

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
                      //    DateTime.fromMillisecondsSinceEpoch(snapshot.data![index].ts! * 1000);
                      return Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.blueGrey))),
                        child: Table(
                            border: TableBorder.all(
                                color: Colors.lightBlue.shade50),
                            columnWidths: const {
                              0: FixedColumnWidth(15.0),
                              1: FixedColumnWidth(70.0),
                              2: FixedColumnWidth(80.0),
                              3: FixedColumnWidth(80.0),
                            },
                            children: [
                              isHeader
                                  ? TableRow(children: [
                                      Container(
                                        padding: const EdgeInsets.all(5.0),
                                        child: const Text("#",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800)),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.all(5.0),
                                          child: const Text("Sensor address",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      Container(
                                          padding: const EdgeInsets.all(5.0),
                                          child: const Text("Values",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      Container(
                                        padding: const EdgeInsets.all(5.0),
                                        child: const Text("Date ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800)),
                                      )
                                    ])
                                  : TableRow(children: [
                                      Container(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text("${index + 1}",
                                              textAlign: TextAlign.center)),
                                      Container(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text("$sensorAddress",
                                              textAlign: TextAlign.center)),
                                      Container(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text("Value: $v \n$alarmValue",
                                              textAlign: TextAlign.center)),
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text("$formattedDate ",
                                            textAlign: TextAlign.center),
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
          return Text("No alarm history.");

          // return Text(snapshot.error.toString());
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
