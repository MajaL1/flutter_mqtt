import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_test/components/custom_app_bar.dart';
import 'package:provider/provider.dart';

import '../model/constants.dart';
import '../model/data.dart';
import '../util/data_smart_mqtt.dart';

class DataPage extends StatefulWidget {
  const DataPage.base({Key? key}) : super(key: key);

  @override
  State<DataPage> createState() => _DataState();
}

class _DataState extends State<DataPage> {
  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);

  TextStyle headingStyleIOS = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: CupertinoColors.inactiveGray,
  );
  TextStyle descStyleIOS = const TextStyle(color: CupertinoColors.inactiveGray);

  @override
  void initState() {
    super.initState();

    debugPrint("data initState");
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("calling build method data.dart");

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: CustomAppBar(Constants.DATA),
      //drawer: const NavDrawer.base(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 15, right: 10),
        scrollDirection: Axis.vertical,
        child: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          _buildDataView(),

          //Divider(height: 1, color: Colors.black12, thickness: 5),
        ]),
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.blue, //Color.fromRGBO(0, 87, 153, 60),
      borderRadius: BorderRadius.circular(9),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 4,
          blurRadius: 5,
          offset: const Offset(0, 2), // changes position of shadow
        ),
      ],
    );
  }

  Future <List<Data>?> _getNewDataList() async {
    List<Data>? data;
    data = await Provider.of<DataSmartMqtt>(context, listen: true).getNewDataList();
    debugPrint("^^^^^ data: % $data");

    if (data != null) {
      return data;
    }
    setState(() {

    });
  }

  Widget _buildDataView() {
    return FutureBuilder<List<Data>?>(
        future: _getNewDataList(),//then((dataList) => _getMqttData(dataList!)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
           // return Utils.showCircularProgressIndicator();
          }
          if (snapshot.hasData) {
            debugPrint("?? shapshot.hasData");
            return Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      Data item = snapshot.data![index]!;
                      String sensorAddress =
                          item.sensorAddress.toString();
                      // int? u = item.u;
                      int? typ = item.typ;
                      int? d = item.d;
                      int? r = item.r;
                      int? w = item.w;
                      int? t = item.t;
                      DateTime? ts = item.ts;
                      int? lb = item.lb;
                      String ? date = DateFormat("yyyy-MM-dd hh:mm:ss").format(ts!);

                      String? deviceName = item.deviceName;
                      //debugPrint("sensorAddress, deviceName: ${sensorAddress}, ${deviceName}");
                      //String unitText = UnitsConstants.getUnits(u);

                      return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.only(
                              top: 30.0, bottom: 1.0, left: 0.0, right: 30.0),
                          child: Wrap(
                            children: [
                              Text("device: $deviceName, sensor: $sensorAddress \n"),
                              Text("typ: $typ, d: $d, r: $r, w: $w, t: $t, lb: $lb \nts: $date"),
                            ]
                      ));
                    }));
          }else {
            return const Text("No data.");
          }
          return const CircularProgressIndicator();
        });
  }
}
