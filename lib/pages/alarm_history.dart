import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/custom_app_bar.dart';
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
            backgroundColor: const Color.fromRGBO(220, 220, 220, 1),
              appBar: CustomAppBar(Constants.HISTORY),
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
                  decoration: Utils.buildHistoryButtonDecoration(),
                  child: TextButton(
                      onPressed: () {
                        clearHistory();
                      },
                      child: Container(
                          child: const Text(
                            'Clear history',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ))),
                ),
                const Divider(height: 40, color: Colors.black12, thickness: 3),
                ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isHeader = index == 0;
                      /*if(index>=1){
                        index--;
                      } */
                      String sensorAddress =
                          snapshot.data![index].sensorAddress.toString();
                      String hiAlarm = snapshot.data![index].hiAlarm.toString();
                      String loAlarm = snapshot.data![index].loAlarm.toString();
                      String v = snapshot.data![index].v.toString();
                      String alarmValue = "";

                      //     DateTime ts = snapshot.data![index].ts!;

                      if (snapshot.data![index].hiAlarm != 0 &&
                          snapshot.data![index].hiAlarm != null) {
                        alarmValue = "Hi alarm: $hiAlarm";
                      }
                      if (snapshot.data![index].loAlarm != 0 &&
                          snapshot.data![index].loAlarm != null) {
                        alarmValue += " Lo alarm: $loAlarm";
                      }
                      String formattedDate = "";

                      if(snapshot.data![index].ts != null){
                        formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                            .format(snapshot.data![index].ts!);

                      }
                      //    DateTime.fromMillisecondsSinceEpoch(snapshot.data![index].ts! * 1000);
                      return Container(
                        //color: Colors.white,
                        decoration: const BoxDecoration(

                          color: Colors.white,
                            border: Border(
                                bottom: BorderSide(color: Colors.blueGrey))),
                        child: Table(
                            border: TableBorder.all(
                                color: Colors.lightBlue.shade50),
                            columnWidths: const {
                              0: FixedColumnWidth(2.0),
                              1: FixedColumnWidth(70.0),
                              2: FixedColumnWidth(80.0),
                              3: FixedColumnWidth(80.0),
                            },
                            children: [
                              isHeader
                                  ? TableRow(children: [
                                      Container(
                                        padding: const EdgeInsets.only(top:5.0, left: 3, right: 3, bottom: 10.0),
                                        child: const Text("#",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800, fontSize: 12)),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.all(5.0),
                                          child: const Text("Sensor address",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w800, fontSize: 12))),
                                      Container(
                                          padding: const EdgeInsets.all(5.0),
                                          child: const Text("Values",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w800, fontSize: 12))),
                                      Container(
                                        padding: const EdgeInsets.all(5.0),
                                        child: const Text("Date ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800, fontSize: 12)),
                                      )
                                    ])
                                  : TableRow(children: [
                                      Container(
                                          padding: const EdgeInsets.only(top:5.0, left: 3, right: 3, bottom: 10.0),
                                          child: Text("${index}",
                                              textAlign: TextAlign.center)),
                                      Container(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text("$sensorAddress",
                                              textAlign: TextAlign.center)),
                                      Container(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text("Value: $v \n$alarmValue",
                                              textAlign: TextAlign.center)),
                                      Container(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text("$formattedDate ",
                                            textAlign: TextAlign.center),
                                      )
                                    ])
                            ]),
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
