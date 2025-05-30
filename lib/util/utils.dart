import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_test/model/user_topic.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/alarm.dart';
import '../model/alarm_interval_setting.dart';
import '../model/topic_data.dart';
import '../model/user.dart';
import '../model/user_data_settings.dart';
import '../widgets/show_alarm_time_settings.dart';

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
    //debugPrint("diff: $diff");
    return diff;
  }

  static List<String> createTopicListFromApi(User user) {
    // List<TopicData> userTopicDataList = user.topic.topicList;
    List<String> userTopicList = [];
    /* String deviceName = user.topic.sensorName;

    */

    for (UserTopic userTopic in user.userTopicList) {
      String deviceName = userTopic.sensorName;

      for (TopicData topicData in userTopic.topicList) {
        if (topicData.name.contains("settings")) {
          if (!userTopicList.contains("$deviceName/settings")) {
            userTopicList.add("$deviceName/settings");
          }
        }
        if (topicData.name.contains("alarm")) {
          if (!userTopicList.contains("$deviceName/alarm")) {
            userTopicList.add("$deviceName/alarm");
          }
        }
       /* if (topicData.name.contains("data")) {
          if (!userTopicList.contains(deviceName + "/data")) {
            userTopicList.add(deviceName + "/data");
          }
        } */
      }
    }
    return userTopicList;
  }

  static Column showCircularProgressIndicator() {
    return const Column(
      children: <Widget>[
        SizedBox(
          height: 200.0,
          child: Stack(
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    strokeWidth: 15,
                    value: 1.0,
                  ),
                ),
              ),
              Center(child: Text("Getting user settings...")),
            ],
          ),
        ),
      ],
    );
  }

  static bool currentSettingsContainNewSettings(
      String decodeMessage, SharedPreferences preferences) {
    String? parsedMqttSettings =
        preferences.getString("parsed_current_mqtt_settings");
    debugPrint(
        "call method currentSettingsContainNewSettings: $parsedMqttSettings");
    if (parsedMqttSettings!.contains(decodeMessage) || parsedMqttSettings.isEmpty) {
      return true;
    } else {
      List<UserDataSettings> parsedMqttSettingsList =
          UserDataSettings.getUserDataSettingsList(parsedMqttSettings);

      List<UserDataSettings> parsedMqttSettingsListNew =
          UserDataSettings.getUserDataSettingsList(decodeMessage);

      // preveri, ali stara lista vsebuje listo z istimi senzorji in z novimi nastavitvami
      for (UserDataSettings oldSettings in parsedMqttSettingsList) {
        String? deviceName = oldSettings.deviceName;
        String? sensorAddress = oldSettings.sensorAddress;

        bool overwriteOldSettings = false;
        for (UserDataSettings newSetting in parsedMqttSettingsListNew) {
          if (newSetting.deviceName == deviceName &&
              newSetting.sensorAddress == sensorAddress) {
            overwriteOldSettings = true;
            break;
          }
        }
        // ali prepisemo stare settingse
        if (overwriteOldSettings) {
          preferences.setString("current_mqtt_settings_list", decodeMessage);
        }
        // ce jih ne prepisemo, jih samo dodamo na obstojeco listo current_mqtt_settings_list
        else {
          parsedMqttSettingsList.addAll(parsedMqttSettingsListNew);
          String decodeStr = json.encode(parsedMqttSettingsList);
          preferences.setString("current_mqtt_settings_list", decodeStr);
        }
      }
    }

    return true;
  }

  static List<String> buildAlarmIntervalsList() {
    List<String> alarmIntervalList = [];

    alarmIntervalList.add(ShowAlarmTimeSettings.minutes10);
    alarmIntervalList.add(ShowAlarmTimeSettings.minutes30);
    alarmIntervalList.add(ShowAlarmTimeSettings.hour);
    alarmIntervalList.add(ShowAlarmTimeSettings.hour6);
    alarmIntervalList.add(ShowAlarmTimeSettings.hour12);
    alarmIntervalList.add(ShowAlarmTimeSettings.all);
    //alarmIntervalList.add(ShowAlarmTimeSettings.changeOnly);
    alarmIntervalList.add(ShowAlarmTimeSettings.noAlarm);

    return alarmIntervalList;
  }

  static void setAlarmGeneralIntervalSettings(String setting) async {
    await SharedPreferences.getInstance().then((value) {
      value.setString("alarm_interval_setting", setting);
      debugPrint("setting: $setting");
    }).then((value) => SmartMqtt.instance.setAlarmIntervalSettings(setting));
  }

  static Future<String> getIntervalTest() async {
    String test = "";

    test = await SharedPreferences.getInstance().then((value) {
      if (value.getString("alarm_interval_setting") != null) {
        String? str = value.getString("alarm_interval_setting");
        if (str != null) {
          return str;
        }
      }
      return "";
    });
    return test;
  }

  /// Pride v postev za nastavitve za vsak alarm posebej *//
  static Future<List<AlarmIntervalSetting>>
      getAlarmIntervalSettingsList() async {
    List<AlarmIntervalSetting> alarmIntervalSettingList = [];

    alarmIntervalSettingList =
        await SharedPreferences.getInstance().then((value) {
      if (value.getString("alarm_interval_settings_list") != null) {
        String? str = value.getString("alarm_interval_settings_list");
        if (str != null) {
          alarmIntervalSettingList = json.decode(str);
        }
      }
      return alarmIntervalSettingList;
    });
    return alarmIntervalSettingList;
  }

  static Future<AlarmIntervalSetting?> getAlarmIntervalSettingForDevice(
      String sensorName, String deviceName, String alarmSetting) async {
    List<AlarmIntervalSetting> alarmIntervalSettingList =
        await getAlarmIntervalSettingsList();

    for (AlarmIntervalSetting setting in alarmIntervalSettingList) {
      if (setting.sensorAddress == sensorName &&
          setting.deviceName == deviceName &&
          setting.setting == alarmSetting) {
        return setting;
      }
    }
    return null;
  }

  static Future<void> setAlarmIntervalSettingForDevice(String sensorName,
      String deviceName, String alarmSetting, String value) async {
    List<AlarmIntervalSetting> alarmIntervalSettingList =
        await getAlarmIntervalSettingsList();

    bool found = false;
    for (AlarmIntervalSetting setting in alarmIntervalSettingList) {
      if (setting.sensorAddress == sensorName &&
          setting.deviceName == deviceName) {
        found = true;
        setting.setting = alarmSetting;
        break;
      }
    }

    if (!found) {
      AlarmIntervalSetting setting = AlarmIntervalSetting(
          deviceName: deviceName,
          sensorAddress: sensorName,
          setting: alarmSetting,
          value: value);

      alarmIntervalSettingList.add(setting);

      // put new list of settings in shared preferences
    }
  }

  static void saveLastSentAlarmForDevice(Alarm newAlarm) {}

  static void setLastAlarmHistoryFromPreferencesTEST() {
    /** test **/
    Alarm alarm1 = Alarm(
        deviceName: "aa1",
        sensorAddress: "aa1bb2",
        hiAlarm: 10,
        loAlarm: 1,
        ts: DateTime.now());
    Alarm alarm2 = Alarm(
        deviceName: "aa1",
        sensorAddress: "bb1cc2",
        hiAlarm: 20,
        loAlarm: 2,
        ts: DateTime.now());
    Alarm alarm3 = Alarm(
        deviceName: "bb1",
        sensorAddress: "dd1ee1",
        hiAlarm: 40,
        loAlarm: 4,
        ts: DateTime.now());
    Alarm alarm4 = Alarm(
        deviceName: "bb1",
        sensorAddress: "bb1cc2",
        hiAlarm: 60,
        loAlarm: 6,
        ts: DateTime.now());

    Map<String, List<Alarm>> alarmHistoryList = {
      "aa1": [alarm1, alarm2],
      "bb1": [alarm3, alarm4],
    };
    String alarmListData = json.encode(alarmHistoryList);
    //json.decode(alarmListData);
    SharedPreferences.getInstance().then((value) {
      value.setString("last_alarm_history_list", alarmListData);
    });
  }

  static Future<Map<String, List<Alarm>>>
      getLastAlarmHistoryListFromPreferencesTEST() async {
    Map<String, List<Alarm>> alarmHistoryList = {};
    alarmHistoryList = await SharedPreferences.getInstance().then((value) {
      if (value.getString("last_alarm_history_list") != null) {
        // username = value.getString("mqtt_username")!;
        String? str = value.getString("last_alarm_history_list");
        if (str != null) {
          alarmHistoryList = Map.castFrom(json.decode(str));
        }
      }
      return alarmHistoryList;
    });

    return alarmHistoryList;
  }

  // Map<String, List<Alarm>> decodeAlarmHistoryList(String str){
  //List<String> usrList =
  //str.map((item) => jsonEncode(item.toMap())).toList();
  // json
  // }

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

  static Future setFriendlyName(Alarm alarm) async{
    Future<String?> s = SharedPreferences.getInstance().then((value) {
      if (value.getString("parsed_current_mqtt_settings") != null) {
        List parsedMqttSettingsList = [];

        String? parsedMqttSettings =
            value.getString("parsed_current_mqtt_settings");

        var jsonMap = json.decode(parsedMqttSettings!); //jsonMap.runtimeType

        parsedMqttSettingsList =
            jsonMap.map((val) => UserDataSettings.fromJson(val)).toList();
        // parsedMqttSettingsList =
        //     UserDataSettings.getUserDataSettingsList(parsedMqttSettings);

        for (UserDataSettings setting in parsedMqttSettingsList) {
          String? deviceName = setting.deviceName;
          String? sensorAddress = setting.sensorAddress;
          String? friendlyName = setting.friendlyName;

          //debugPrint("utils - before sendMessage setFriendlyName");
          if (alarm.sensorAddress == sensorAddress &&
              alarm.deviceName == deviceName) {
            alarm.friendlyName = friendlyName;
          }
        }
        //debugPrint("utils - before sendMessage ${alarm.friendlyName}");
        return alarm.friendlyName;
      }
      return "";
    });
    return s;
  }

  static List<UserDataSettings> diffOldAndNewSettings(List<UserDataSettings> newUserSettings, List<UserDataSettings> currentUserSettings) {
    /* RegExp regex = RegExp(
        "\s*\"friendlyName\" *: *(\"(.*?)\"(,|\s|)|\s*\{(.*?)\}(,|\s|))");

    debugPrint("removeFriendlyNameFromMqttSettings:  $userDataSettings");
    debugPrint("will compare:  userDataSettings $userDataSettings");
    debugPrint("will compare:  newUserSettings $newUserSettings");

    if (regex.hasMatch(userDataSettings)) {
      debugPrint("hasMatch");
      final withoutFriendlyName =
          userDataSettings.replaceAll(regex, ''); // abc
      debugPrint("withoutFriendlyName: $withoutFriendlyName");
    } */

   // debugPrint("\n\t\t=== 1010  primerjamo NOVE SETTINGE: $newUserSettings");
   // debugPrint("\n\t\t=== 1010  primerjamo TRENUTNE SETTINGE SETTINGE: $currentUserSettings");



    // preveri vsebino userdatasettingsov
    // preveri, ali so parametri v obeh listah enake, oz. novi listi pripni friendlyName

    for (UserDataSettings setOld in currentUserSettings) {
      for (UserDataSettings setNew in newUserSettings) {
        if (setOld.deviceName == setNew.deviceName &&
            setOld.sensorAddress == setNew.sensorAddress) {
          setOld.friendlyName = setNew.friendlyName;
        }
      }
    }

    debugPrint("diffOldAndNewSettings:  currentUserSettings - dodan hi alarm: $currentUserSettings");

    return currentUserSettings;
  }

  static int getIntervalFromPreferences(String? showInterval) {
    int timeIntervalMinutes = 1;
    switch (showInterval) {
      case ShowAlarmTimeSettings.minutes10:
        timeIntervalMinutes = 10;
        break;
      case ShowAlarmTimeSettings.minutes30:
        timeIntervalMinutes = 30;
        break;
      case ShowAlarmTimeSettings.hour:
        timeIntervalMinutes = 60;
        break;
      case ShowAlarmTimeSettings.hour6:
        timeIntervalMinutes = 360;
        break;
      case ShowAlarmTimeSettings.hour12:
        timeIntervalMinutes = 720;
        break;
      case ShowAlarmTimeSettings.day:
        timeIntervalMinutes = 1440;
        break;
      case ShowAlarmTimeSettings.all:
        timeIntervalMinutes = 1;
        break;
      case ShowAlarmTimeSettings.noAlarm:
        timeIntervalMinutes = 100000;
        break;
      default:
        timeIntervalMinutes = 10;
    }
    return timeIntervalMinutes;
  }
}
