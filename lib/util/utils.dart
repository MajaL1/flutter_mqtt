import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../model/topic_data.dart';
import '../model/user.dart';

class Utils {
  static Future<String> downloadFile(String url, String filename) async {
    final direactory = await getApplicationSupportDirectory();
    final filepath = '${direactory.path}/$filename';
    final response = await http.get(Uri.parse(url));
    debugPrint(response as String?);

    final file = File(filepath);

    await file.writeAsBytes(response.bodyBytes);
    return filepath;
  }

  /*static int compareDatesInMinutes(DateTime lastSentAlarm) {
    Duration? duration = DateTime.now().difference(lastSentAlarm);
    int differenceInMinutes = duration!.inMinutes;
    return differenceInMinutes;
  } */

  static int compareDatesInMinutes(DateTime oldDate, DateTime newDate) {
    var diff = newDate.difference(oldDate).inMinutes;
    debugPrint("diff: $diff");
    return diff;
  }

  static List<String> createTopicListFromApi(User user) {
    List<TopicData> userTopicDataList = user.topic.topicList;
    List<String> userTopicList = [];
    String deviceName = user.topic.sensorName;
    for (TopicData topicData in userTopicDataList) {
      if (topicData.name.contains("settings")) {
        userTopicList.add(deviceName + "/settings");
      }
      if (topicData.name.contains("alarm")) {
        userTopicList.add(deviceName + "/alarm");
      }
    }
    return userTopicList;
  }

  static Future<String> getImageFilePathFromAssets(
      String asset, String filename) async {
    final byteData = await rootBundle.load(asset);
    final tempDirectory = await getTemporaryDirectory();
    final file = File('${tempDirectory.path}/$filename');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file.path;
  }

  static String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

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
        labelStyle: const TextStyle(letterSpacing: 1.8),
        hintStyle: const TextStyle(fontSize: 12));
  }

  static BoxDecoration buildBoxDecorationSettings() {
    return BoxDecoration(
      color: Colors.white60, //Color.fromRGBO(0, 87, 153, 60),
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

  static ButtonStyle buildElevatedButtonSettings() {
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
}
