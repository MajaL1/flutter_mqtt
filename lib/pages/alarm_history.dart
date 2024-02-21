import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/custom_app_bar.dart';
import '../model/alarm.dart';
import '../model/constants.dart';
import '../util/gui_utils.dart';

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
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 30,
                        width: 150,
                        decoration: GuiUtils.buildHistoryButtonDecoration(),
                        child: ElevatedButton.icon(
                            style: GuiUtils.buildElevatedButtonSettings(),
                            onPressed: () {
                              _clearHistory();
                            },
                            label: const Text(
                              'Clear history',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            icon: const Icon(Icons.clear,
                                color: Colors.white, size: 18)),
                      ),
                      Container(width: 40),
                      Container(
                        height: 30,
                        width: 130,
                        decoration: GuiUtils.buildHistoryButtonDecoration(),
                        child: ElevatedButton.icon(
                            style: GuiUtils.buildElevatedButtonSettings(),
                            onPressed: () {
                              _refreshHistoryList();
                            },
                            label: const Text(
                              'Refresh',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            icon: const Icon(Icons.refresh,
                                color: Colors.white, size: 18)),
                      )
                    ]),
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
                      String deviceName =
                          snapshot.data![index].deviceName.toString();
                      String hiAlarm = snapshot.data![index].hiAlarm.toString();
                      String loAlarm = snapshot.data![index].loAlarm.toString();
                      String v = snapshot.data![index].v.toString();
                      String sensorAddress =
                          snapshot.data![index].sensorAddress.toString();
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

                      if (snapshot.data![index].ts != null) {
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
                              0: FixedColumnWidth(0.5),
                              1: FixedColumnWidth(70.0),
                              2: FixedColumnWidth(80.0),
                              3: FixedColumnWidth(80.0),
                            },
                            children: [
                              isHeader
                                  ? TableRow(children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 1.0,
                                            left: 1,
                                            right: 1,
                                            bottom: 1.0),
                                        child: const Text("#",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16)),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.all(1.0),
                                          child: const Text("device - sensor",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16))),
                                      Container(
                                          padding: const EdgeInsets.all(1.0),
                                          child: const Text("value",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16))),
                                      Container(
                                        padding: const EdgeInsets.all(1.0),
                                        child: const Text("date ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16)),
                                      )
                                    ])
                                  : TableRow(children: [
                                      Container(
                                          padding: const EdgeInsets.only(
                                              top: 1.0,
                                              left: 1,
                                              right: 1,
                                              bottom: 1.0),
                                          child: Text(index as String,
                                              textAlign: TextAlign.center)),
                                      Container(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Text(
                                              "$deviceName-$sensorAddress",
                                              textAlign: TextAlign.center)),
                                      Container(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Text("Value: $v \n$alarmValue",
                                              textAlign: TextAlign.center)),
                                      Container(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Text("$formattedDate ",
                                            textAlign: TextAlign.center),
                                      )
                                    ])
                            ]),
                      );
                    })
              ])));
        } else if (snapshot.hasError) {
          return const Text("No alarm history.");

          // return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  Future<void> _clearHistory() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.remove("alarm_list_mqtt");
    setState(() {
      //snapshot.data![index].on = value;
    });
    // debugPrint("clear history");
  }

  Future<void> _refreshHistoryList() async {
    setState(() {
      //
    });
  }
}
