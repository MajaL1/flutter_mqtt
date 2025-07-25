import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_test/api/api_service.dart';
import 'package:mqtt_test/api/notification_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/custom_app_bar.dart';
import '../components/drawer.dart';
import '../model/alarm.dart';
import '../model/constants.dart';
import '../model/user_data_settings.dart';
import '../util/gui_utils.dart';
import '../widgets/units.dart';

class AlarmHistory extends StatefulWidget {
  //var sharedPreferences;

  const AlarmHistory({Key? key}) : super(key: key);

  @override
  State<AlarmHistory> createState() => _AlarmHistoryState();
}

class _AlarmHistoryState extends State<AlarmHistory> {
  late Timer timer;
  bool refresh = false;

  Future<List<Alarm>> _returnAlarmList(List<Alarm> alarmList) async {
    debugPrint("alarm_history alarmList ${alarmList.length}, ${alarmList.toString()}");
    //alarm history - getRefreshedAlarmList()
    //await Provider.of<NotificationHelper>(context, listen: false).getRefreshedAlarmList().then((val) => {  val} );
    //setState(() {
    //});
    return alarmList;
  }

  String username = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.getInstance().then((val) {
      setState(() {
        username = val.getString("username") ?? val.getString("username")!;
        email = (val.getString("email") ?? "");
      });
      debugPrint("44444 1 user_settings initState username: $username, email: $email");
      val.reload();
      debugPrint("44444 2 user_settings initState username: $username, email: $email ");

      setState(() {});

      debugPrint("alarm_history initState");
      showLocalTestNotification();
    });
  }

  void showLocalTestNotification() {
    Alarm alarm = Alarm(
        sensorAddress: "test1233",
        typ: 2,
        v: 1,
        hiAlarm: 10,
        loAlarm: 2,
        ts: DateTime.timestamp(),
        lb: 1,
        bv: 3,
        r: 1,
        l: 3,
        b: 2,
        t: 3);
    NotificationHelper.instance.sendMessage(alarm); 
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Alarm>>(
      future: ApiService.getAlarmsHistory()
          .then((alarmHistoryList) => _returnAlarmList(alarmHistoryList))
          //.then((alarmHistoryList) => getRefreshedAlarmList(alarmHistoryList)),
          //.then((alarmHistoryList) =>
          .then((alarmHistoryList) => _pairAlarmListWithSettings(alarmHistoryList)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              backgroundColor: const Color.fromRGBO(225, 225, 225, 1),
              extendBody: true,
              resizeToAvoidBottomInset: true,
              appBar: CustomAppBar(Constants.HISTORY),
              drawer: NavDrawer.data(username: username, email: email),
              body: SingleChildScrollView(
                  child: Container(
                      color: Colors.white,
                      constraints: const BoxConstraints(maxWidth: 1000, minHeight: 1000),
                      child: Column(children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 7, bottom: 15.0),
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
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) => AlertDialog(
                                          title: const Text('Clear history'),
                                          content: const Text(
                                            'Are you sure you want to clear history?',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, 'Cancel'),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _clearHistory();
                                                Navigator.pop(context, 'OK');
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    label: const Text(
                                      'Clear history',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    icon: const Icon(Icons.clear, color: Colors.white, size: 18)),
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
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    icon: const Icon(Icons.refresh, color: Colors.white, size: 18)),
                              )
                            ]),
                        const Divider(height: 40, color: Colors.transparent, thickness: 0),
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
                              String deviceName = snapshot.data![index].deviceName.toString();
                              String friendlyName = snapshot.data![index].friendlyName.toString();
                              String hiAlarm = snapshot.data![index].hiAlarm.toString();
                              String loAlarm = snapshot.data![index].loAlarm.toString();
                              String v = snapshot.data![index].v.toString();
                              int? u = snapshot.data![index].u;
                              String sensorAddress = snapshot.data![index].sensorAddress.toString();
                              String alarmValue = "";
                              String units = UnitsConstants.getUnits(u);

                              if (friendlyName.isEmpty) {
                                deviceName = "$deviceName \n$sensorAddress";
                              } else {
                                deviceName = friendlyName;
                              }

                              //     DateTime ts = snapshot.data![index].ts!;

                              if (snapshot.data![index].hiAlarm != 0 && snapshot.data![index].hiAlarm != null) {
                                alarmValue = "Hi alarm: $hiAlarm";
                              }
                              if (snapshot.data![index].loAlarm != 0 && snapshot.data![index].loAlarm != null) {
                                alarmValue += " Lo alarm: $loAlarm";
                              }
                              String formattedDate = "";

                              if (snapshot.data![index].ts != null) {
                                formattedDate = DateFormat('yyyy-MM-dd – HH:mm').format(snapshot.data![index].ts!);
                              }
                              //    DateTime.fromMillisecondsSinceEpoch(snapshot.data![index].ts! * 1000);
                              return Container(
                                //color: Colors.white,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(bottom: BorderSide(color: Colors.blueGrey, width: 0.0))),
                                child: Table(
                                    border: const TableBorder(
                                        horizontalInside:
                                            BorderSide(width: 0.0, color: Colors.blue, style: BorderStyle.solid)),
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
                                                padding:
                                                    const EdgeInsets.only(top: 1.0, left: 1, right: 1, bottom: 1.0),
                                                child: const Text("",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        color: Color.fromRGBO(32, 52, 86, 0.6),
                                                        fontSize: 15)),
                                              ),
                                              Container(
                                                  padding: const EdgeInsets.all(1.0),
                                                  child: const Text("Sensor",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(32, 52, 86, 0.8),
                                                          fontWeight: FontWeight.w800,
                                                          fontSize: 15))),
                                              Container(
                                                  padding: const EdgeInsets.all(1.0),
                                                  child: const Text("Alarm",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(32, 52, 86, 0.8),
                                                          fontWeight: FontWeight.w800,
                                                          fontSize: 15))),
                                              Container(
                                                padding: const EdgeInsets.all(1.0),
                                                child: const Text("Date ",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(32, 52, 86, 0.8),
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 15)),
                                              )
                                            ])
                                          : TableRow(children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.only(top: 1.0, left: 1, right: 1, bottom: 1.0),
                                                  child: Text(
                                                    index.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(color: Color.fromRGBO(55, 55, 58, 0.9)),
                                                  )),
                                              Container(
                                                  padding: const EdgeInsets.all(1.0),
                                                  child: Text(deviceName,
                                                      style: const TextStyle(color: Color.fromRGBO(55, 55, 58, 0.9)),
                                                      textAlign: TextAlign.center)),
                                              Container(
                                                  padding: const EdgeInsets.all(1.0),
                                                  child: Text("Value: $v \n$alarmValue $units",
                                                      style: const TextStyle(color: Color.fromRGBO(55, 55, 58, 0.9)),
                                                      textAlign: TextAlign.center)),
                                              Container(
                                                padding: const EdgeInsets.all(1.0),
                                                child: Text("$formattedDate ",
                                                    style: const TextStyle(color: Color.fromRGBO(55, 55, 58, 0.9)),
                                                    textAlign: TextAlign.center),
                                              )
                                            ])
                                    ]),
                              );
                            })
                      ]))));
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Text("No alarm history. ${snapshot.error}");

          // return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  // pridobi novo listo alarmov, iz preferenc
  Future<List<Alarm>> getRefreshedAlarmList(List<Alarm> alarmHistoryList) async {
    debugPrint("alarm history - getRefreshedAlarmList::");
    //List refreshedAlarms = [];
    List<Alarm> alarmList = [];

    alarmList = await Provider.of<NotificationHelper>(context, listen: false).getRefreshedAlarmList();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    if (preferences.containsKey("alarm_list_mqtt")) {
      String alarmListData = preferences.get("alarm_list_mqtt") as String;
      if (alarmListData.isNotEmpty) {
        List alarmMessageJson = json.decode(alarmListData);
        alarmList = Alarm.getAlarmListFromPreferences(alarmMessageJson);
        debugPrint("1alarm history - alarmList: $alarmList");
      }
      //debugPrint("alarmList-:: $alarmList");
    }
    /* if (refreshedAlarms != null) {
      return refreshedAlarms;
    }
    return refreshedAlarms; */
    debugPrint("2alarm history - alarmList: $alarmList");

    return alarmList;
  }

  // nastavi friendly name v listi history alarmov
  Future<List<Alarm>> _pairAlarmListWithSettings(List<Alarm> alarmList) async {
    timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      SharedPreferences.getInstance().then((value) {
        value.reload();
        //debugPrint("historyChanged, ${value.getBool('historyChanged')} ");
        if (value.getBool("historyChanged") == true) {
          debugPrint("2historyChanged, ${value.getBool('historyChanged')}");
          setState(() {
            refresh = true;
          });
          value.setBool("historyChanged", false);
        }
      });
    });
    await SharedPreferences.getInstance().then((value) {
      if (value.getString("parsed_current_mqtt_settings") != null) {
        List<UserDataSettings> parsedMqttSettingsList = [];

        String? parsedMqttSettings = value.getString("parsed_current_mqtt_settings");
        //debugPrint("alarm_history.... parsedMqttSettings: $parsedMqttSettings");
        List jsonMap1 = json.decode(parsedMqttSettings!);
        parsedMqttSettingsList = jsonMap1.map((val) => UserDataSettings.fromJson(val)).toList();

        for (UserDataSettings setting in parsedMqttSettingsList) {
          String? deviceName = setting.deviceName;
          String? sensorAddress = setting.sensorAddress;
          String? friendlyName = setting.friendlyName;

          for (Alarm alarm in alarmList) {
            if (alarm.sensorAddress == sensorAddress && alarm.deviceName == deviceName) {
              if (friendlyName != null && friendlyName.isNotEmpty) {
                alarm.friendlyName = friendlyName;
                //debugPrint(
                //  "alarm_history found friendly name... ${alarm.sensorAddress}, ${alarm.deviceName}");
              }
            }
          }
        }
        //debugPrint("alarm_history parsedMqttSettings parsedMqttSettingsList.size, ${parsedMqttSettingsList.length}, ${parsedMqttSettingsList.toString()}");
      }
    });
    return alarmList;
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

  @override
  void dispose() {
    debugPrint("alarm-history.dart - dispose");

    timer.cancel();
    super.dispose();
  }
}
