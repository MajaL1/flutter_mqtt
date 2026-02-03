import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  String? connectionStatusText = "";

  CustomAppBar(this.title, {Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight+5),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String username = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _listenConnection();
  }

  void _listenConnection() {
    InternetConnection()
        .onStatusChange
        .listen((status) => setState(() => widget.connectionStatusText =
            status == InternetStatus.connected ? "" : "No internet"));
  }

  void _initPrefs() async {
    final val = await SharedPreferences.getInstance();
    setState(() {
      username = val.getString("username") ?? "";
      email = val.getString("email") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;

    return SafeArea(
      // ensures we don't draw under the iPhone status bar
      top: true,
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleSpacing: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.connectionStatusText?.isNotEmpty ?? false)
                Text(
                  widget.connectionStatusText!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8),
              child: Text(
                "v_2026-02-03",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
