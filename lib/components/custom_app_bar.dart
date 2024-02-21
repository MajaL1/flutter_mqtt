import 'package:flutter/material.dart';

import '../util/gui_utils.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  String title;

  CustomAppBar(this.title, {Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight + 22), super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  final Size preferredSize; // default is 56.0
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        //padding: EdgeInsets.only(bottom:20),
        margin: EdgeInsets.only(top: 22),

        //preferredSize: preferredSize,
        child: AppBar(
            //toolbarHeight: 50,
            flexibleSpace: Container(
              //height: 180,
              //padding: EdgeInsets.only(top:40),

              decoration: GuiUtils.buildAppBarDecoration(),
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
            foregroundColor: Colors.lightBlue,
            title: Container(
                //decoration: Utils.buildAppBarDecoration(),
                child: Text(
              widget.title,
              style: const TextStyle(
                  fontSize: 16, color: Colors.white, letterSpacing: 1),
            ))));
  }
}
