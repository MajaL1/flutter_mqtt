import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor = Colors.blueGrey;
  final Text title;
  final AppBar appBar;
  final List<Widget> widgets;

  /// you can add more fields that meet your needs

  const BaseAppBar({Key? key, required this.title, required this.appBar, required this.widgets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("test"),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.comment),
          tooltip: 'Comment Icon',
          onPressed: () {},
        ), //IconButton
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Setting Icon',
          onPressed: () {},
        ), //IconButton
      ], //<Widget>[]
      backgroundColor: Colors.greenAccent[400],
      elevation: 50.0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu Icon',
        onPressed: () {},
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
  //AppBar

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}