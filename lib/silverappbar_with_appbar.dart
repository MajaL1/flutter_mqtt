import 'package:flutter/material.dart';

class AdvancedAppBar extends AppBar{


  AdvancedAppBar({required Key key}) : super(
      key: key,
      title:
      Container(child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: TextButton(
              onPressed: () {
                // here I would like to navigate to another screen
              },
              padding: EdgeInsets.all(0.0),
              child: Image.asset('assets/images/Logo.png')
          )
      )
      ),
      actions: <Widget>[
        PopupMenuButton<PopUpStates>(
          onSelected: (PopUpStates result) {
            switch (result) {
              case PopUpStates.settings: {
                // here I would like to navigate to another screen
              }
              break;
              case PopUpStates.logout: {
                // here I would like to navigate to another screen
              }
              break;
              default:
            }},
          itemBuilder: (BuildContext context) => <PopupMenuEntry<PopUpStates>>[
            const PopupMenuItem<PopUpStates>(
              value: PopUpStates.settings,
              child: Text('Einstellungen'),
            ),
            const PopupMenuItem<PopUpStates>(
              value: PopUpStates.logout,
              child: Text('Ausloggen'),
            ),
          ],
        )
      ],
      automaticallyImplyLeading: false
  );

}