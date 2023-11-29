import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../model/alarm.dart';
import '../model/constants.dart';

class AlarmHistory extends StatelessWidget {
  //var sharedPreferences;

  const AlarmHistory({Key? key}) : super(key: key);

  // late SharedPreferences sharedPreferences = sharedPreferences;

  void showAlarmDetail(index) {
    // Todo: open detail
  }

  List<Alarm> _returnAlarmList(List<Alarm> alarmList) {
    return alarmList;
  }

  _setInputDecoration(val) {
    return InputDecoration(
        labelText: val,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 3.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController testController = TextEditingController();

    return Scaffold(
        body: SingleChildScrollView(
            //alignment: Alignment.bottomCenter,
            child:
            SizedBox(
        child:
            Column(children: [
              const Padding(padding: EdgeInsets.all(30.0)),
              TextFormField(
                  decoration: _setInputDecoration("10"),
                  //decoration: const InputDecoration(labelText: "Context"),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: testController,
                  onChanged: (val) {
                    //text = "abc";
                  },
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Required value"),
                    MaxLengthValidator(6, errorText: "Value too long")
                  ])),
              TextButton(style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green) ),
                onPressed: () {
                  saveMqttSettings();
                  // setState(() {
                  //  savePressed = !savePressed;
                  //});
                  //saveMqttSettingsTest();
                },
                child: const Text(
                  Constants.SAVE_DEVICE_SETTINGS,
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ])
            )
            //return FutureBuilder<List<Alarm>>(
            /*future: ApiService.getAlarmsHistory()
          .then((alarmHistoryList) => _returnAlarmList(alarmHistoryList)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: const Text(Constants.HISTORY),
              ),
              body:

              ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  String sensorAddress = snapshot.data![index].sensorAddress
                      .toString()!;
                  String hiAlarm = snapshot.data![index].hiAlarm.toString()!;
                  String loAlarm = snapshot.data![index].loAlarm.toString()!;
                  String ts = snapshot.data![index].ts.toString()!;
                  return Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.blueGrey))),
                      child: TextFormField(
                        //decoration: _setInputDecoration(value),
                        //decoration: const InputDecoration(labelText: "Context"),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: testController,

                          onChanged: (val) {
                            //text = "abc";
                          },
                          validator: MultiValidator([
                            RequiredValidator(errorText: "Required value"),
                            MaxLengthValidator(6, errorText: "Value too long")
                          ]))

                      /*child: ListTile(
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
                          })*/);
                })
        */

            ));
  }

  void saveMqttSettings() {
    debugPrint("Save..test...");
  }
}
