import 'package:flutter/material.dart';

import 'login_form.dart';

class FirstScreen extends StatefulWidget {

  FirstScreen.base({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  initState() {
    super.initState();
    debugPrint("-- firstScreen initstate");
  }


  @override
  Widget build(BuildContext context) {
    //debugPrint("token: $SharedPrefs().token, ${SharedPrefs().token}");

    return Scaffold(
        body: FutureBuilder(
            //future: _initCurrentAppState(),
            builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return const Scaffold(
            // TODO: preveri, ali je uporabnik logiran
            // body: !userLoggedIn ?? LoginForm(widget.currentAppState, widget.manager)) : UserSettings(widget.currentAppState, widget.manager);
            body: LoginForm.base());
      }
    }));
  }
}
