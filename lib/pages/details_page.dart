import 'package:flutter/material.dart';
import '../model/constants.dart';

class DetailsPage extends StatelessWidget {

  const DetailsPage({Key? key}) : super(key: key);

  void showAlarmDetail(index) {
    // Todo: open detail
  }

  @override
  Widget build(BuildContext context) {
    {
      return Scaffold(
          appBar: AppBar(
            title: const Text(Constants.HISTORY),
          ),
          //drawer: NavDrawer(),
          body: Container(
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.blueGrey))),
              child: const ListTile(
                  title: Text("Test"),
                  leading: const FlutterLogo(),
                  subtitle: Row(children: <Widget>[
                    Text("Test1"),
                  ]))));
    }
  }
}
