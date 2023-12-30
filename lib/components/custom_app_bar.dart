import 'package:flutter/material.dart';

import '../util/utils.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  String title;

  CustomAppBar(this.title)
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  final Size preferredSize; // default is 56.0
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        flexibleSpace: Container(
          decoration: Utils.buildAppBarDecoration(),
          //color: Colors.black,
          /*child: Column(
            children: [
              Text('One'),
              Text('Two'),
              Text('Three'),
              Text('Four'),
            ],
          ),*/
        ),
        shadowColor: Colors.black,
        title: Container(
            //decoration: Utils.buildAppBarDecoration(),
            child: Text(
          widget.title,
          style: const TextStyle(fontSize: 16),
        )));
  }
}
