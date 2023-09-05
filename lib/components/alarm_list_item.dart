import 'package:flutter/material.dart';

class AlarmListItem extends StatefulWidget {
  const AlarmListItem({Key? key, this.snapshot, required this.index})
      : super(key: key);

  final snapshot;
  final int index;

  @override
  _AlarmListItemState createState() => _AlarmListItemState();
}

class _AlarmListItemState extends State<AlarmListItem> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    int index = widget.index;
    var snapshot = widget.snapshot;
    return Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blueGrey))),
        child: ListTile(
            contentPadding:
                EdgeInsets.only(left: 20, right: 10, top: 20, bottom: 20),
            title: Text(snapshot.data![index].title),
            leading: ImageIcon(
              AssetImage("assets/bell.png"),
              color: Color(0xFF3A5A98),
            ),
            subtitle: Row(
              children: <Widget>[
                Text(snapshot.data![index].description!),
                Text("  -  "),
                Text(
                  snapshot.data![index].on.toString(),
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Switch(
                  activeColor: Colors.greenAccent,
                  inactiveThumbColor: Colors.redAccent,
                  value: snapshot.data![index].on ? true : false,
                  onChanged: (bool value) {
                    print("old value:: ${snapshot.data![index].on}");
                    print("new value:: ${value}");
                    setState(() {
                      snapshot.data![index].on = value;
                    });
                    changeAlarmEnabled(index, value);
                  },
                ),
              ],
            ),
            //Text(snapshot.data![index].date!),
            onTap: () {
              showAlarmDetail(index);
            }));
  }

  void changeAlarmEnabled(int id, bool value) {
    print("calling changeAlarmEnabled: ${id}, ${value}");
  }

  void showAlarmDetail(int id) {}
}
