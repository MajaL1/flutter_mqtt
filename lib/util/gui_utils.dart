import 'package:flutter/material.dart';

import '../model/constants.dart';

class GuiUtils {
  static InputDecoration buildAlarmIntervalDecoration() {
    return InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.black12, width: 8.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              width: 1.5, color: Color.fromRGBO(108, 165, 222, 60)),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
              color: Color.fromRGBO(108, 165, 222, 60), width: 2),
        ),
        labelStyle: const TextStyle(letterSpacing: 0.8),
        hintStyle: const TextStyle(fontSize: 12));
  }

  static BoxDecoration buildBoxDecorationSettings() {
    return BoxDecoration(
      color: Colors.white70, //Color.fromRGBO(0, 87, 153, 60),
      borderRadius: BorderRadius.circular(9),
      boxShadow: const [
        BoxShadow(
          color: Colors.white10,
          spreadRadius: 4,
          blurRadius: 5,
          offset: Offset(0, 2), // changes position of shadow
        ),
      ]

    );
  }

  static BoxDecoration buildButtonDecoration() {
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
      gradient: const RadialGradient(
        center: Alignment(0, 0),
        radius: 2,
        colors: [
          Colors.blue,
          Colors.blueAccent,
          Color.fromRGBO(0, 87, 153, 60)
        ],
      ),
    );
  }

  static BoxDecoration buildBoxDecorationInterval() {
    return BoxDecoration(
// color: Colors.blue, //Color.fromRGBO(0, 87, 153, 60),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 4,
            blurRadius: 8,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
        color: const Color.fromRGBO(222, 242, 255, 1),
        border:
            const Border(bottom: BorderSide(color: Colors.indigo, width: 3)));
  }

  static BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
// color: Colors.blue, //Color.fromRGBO(0, 87, 153, 60),
      borderRadius: BorderRadius.circular(9),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 4,
          blurRadius: 8,
          offset: const Offset(0, 1), // changes position of shadow
        ),
      ],
      gradient: const RadialGradient(
        center: Alignment(0, 0),
        radius: 4,
        colors: [Colors.blue, Color.fromRGBO(0, 87, 153, 60)],
      ),
    );
  }

  static BoxDecoration buildAppBarDecoration() {
    return BoxDecoration(
// color: Colors.black, //Color.fromRGBO(0, 87, 153, 60),
// color: Colors.red,
// borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 4,
          blurRadius: 8,
          offset: const Offset(0, 1), // changes position of shadow
        ),
      ],
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.black,
          Color.fromRGBO(0, 0, 190, 1),
//Color.fromRGBO(0, 87, 153, 60)
        ],
      ),
    );
  }

  static BoxDecoration buildLoginButtonBoxDecoration() {
    return BoxDecoration(
      color: Colors.blue, //Color.fromRGBO(0, 87, 153, 60),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 4,
          blurRadius: 8,
          offset: const Offset(0, 1), // changes position of shadow
        ),
      ],
      gradient: const RadialGradient(
        center: Alignment(0, 0),
        radius: 4,
        colors: [Color.fromRGBO(0, 0, 190, 1), Color.fromRGBO(0, 87, 153, 60)],
      ),
    );
  }

  static buildHistoryButtonDecoration() {
    return BoxDecoration(
      color: Colors.blue, //Color.fromRGBO(0, 87, 153, 60),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 4,
          blurRadius: 8,
          offset: const Offset(0, 1), // changes position of shadow
        ),
      ],
      gradient: const RadialGradient(
        center: Alignment(0, 0),
        radius: 4,
        colors: [Color.fromRGBO(0, 0, 190, 1), Color.fromRGBO(0, 87, 153, 60)],
      ),
    );
  }

  static buildSaveMqttSettingsButtonDecoration() {
    return BoxDecoration(
      color: Colors.blue, //Color.fromRGBO(0, 87, 153, 60),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 4,
          blurRadius: 8,
          offset: const Offset(0, 1), // changes position of shadow
        ),
      ],
      gradient: const RadialGradient(
        center: Alignment(0, 0),
        radius: 4,
        colors: [Color.fromRGBO(0, 0, 190, 1), Color.fromRGBO(0, 87, 153, 60)],
      ),
    );
  }

  static buildSaveMqttSettingsButtonDecoration1() {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) =>
          const Color.fromRGBO(0, 0, 190, 1)), //Color.fromRGBO(0, 87, 153, 60),
      //borderRadius: BorderRadius.circular(12),
    );
  }

  static MaterialStateProperty<Color> getColor(
      Color color, Color colorPressed) {
    getColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return colorPressed;
      } else {
        return color;
      }
    }

    return MaterialStateProperty.resolveWith(getColor);
  }


  static ButtonStyle buildElevatedButtonSettings() {
    return ButtonStyle(
        //side: MaterialStateProperty.BorderSide(color: Colors.red),
        shape:MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          //side: BorderSide(color: Color.fromRGBO(0, 0, 90, 1)))
        )),
        backgroundColor:
            getColor(const Color.fromRGBO(0, 0, 190, 1), Colors.lightBlue),
        foregroundColor:
            getColor(const Color.fromRGBO(0, 0, 190, 1), Colors.lightBlue),
        overlayColor:
            getColor(const Color.fromRGBO(0, 0, 190, 1), Colors.lightBlue));
  }

  static ButtonStyle buildElevatedButtonFriendlyName() {
    return ButtonStyle(
        //side: MaterialStateProperty.BorderSide(color: Colors.red),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          //side: BorderSide(color: Color.fromRGBO(0, 0, 90, 1)))
        )),
        backgroundColor:
            getColor(const Color.fromRGBO(0, 0, 190, 1), Colors.lightBlue),
        foregroundColor:
            getColor(const Color.fromRGBO(0, 0, 190, 1), Colors.lightBlue),
        overlayColor:
            getColor(const Color.fromRGBO(0, 0, 190, 1), Colors.lightBlue));
  }

  static ButtonStyle buildElevatedButtonLogin() {
    return ButtonStyle(
//side: MaterialStateProperty.BorderSide(color: Colors.red),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          //side: BorderSide(color: Color.fromRGBO(0, 0, 90, 1)))
        )),
        backgroundColor:
            getColor(const Color.fromRGBO(0, 0, 190, 1), Colors.lightBlue),
        foregroundColor:
            getColor(const Color.fromRGBO(0, 0, 190, 1), Colors.lightBlue),
        overlayColor:
            getColor(const Color.fromRGBO(0, 0, 190, 1), Colors.lightBlue));
  }

  static InputDecoration buildInputUsernameLoginDecoration() {
    return InputDecoration(
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.blueAccent,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              width: 1.5, color: Color.fromRGBO(108, 165, 222, 60)),
          borderRadius: BorderRadius.circular(16), //
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: Color.fromRGBO(108, 165, 222, 60), width: 2.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12, width: 0.5),
        ),
        //labelText: Constants.ENTER_VALID_USER,
        labelStyle: const TextStyle(letterSpacing: 0.8),
        hintText: Constants.ENTER_VALID_USER,
        hintStyle: const TextStyle(fontSize: 12));
  }

  static InputDecoration buildFriendlyNameDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
            width: 1.5, color: Color.fromRGBO(108, 165, 222, 60)),
        borderRadius: BorderRadius.circular(3), //
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(
            color: Color.fromRGBO(108, 165, 222, 60), width: 2.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Colors.black12, width: 0.5),
      ),
      //labelText: Constants.ENTER_VALID_USER,
      labelStyle: const TextStyle(letterSpacing: 0.8),
    );
  }
  static InputDecoration setInputDecorationFriendlyName() {
    return InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.only(left:3, right: 3),
        border: UnderlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(14)),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ));
  }
  static InputDecoration setInputDecoration(val) {
    return InputDecoration(
        //labelText: val,
        filled: true,
        fillColor: Colors.white,
        border: UnderlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(14)),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ));
  }
/*static MaterialStateProperty<OutlinedBorder> getBorder(BorderSide borderSide, BorderSide borderSide1) {
    final getBorder = (Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return borderSide1;
      } else {
        return borderSide;
      }
    };
    return MaterialStateProperty.resolveWith(getBorder);
  } */
}
