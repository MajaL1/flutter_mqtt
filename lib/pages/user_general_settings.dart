import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_test/util/smart_mqtt.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/gui_utils.dart';
import '../widgets/show_alarm_time_settings.dart';

class UserGeneralSettings extends StatefulWidget {
  const UserGeneralSettings.base({Key? key}) : super(key: key);

  @override
  State<UserGeneralSettings> createState() => _UserGeneralSettingsState();
}

class _UserGeneralSettingsState extends State<UserGeneralSettings> {
  List<String> alarmIntervalsList = Utils.buildAlarmIntervalsList();
  String? dropdownValue = "";

  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);

  TextStyle headingStyleIOS = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: CupertinoColors.inactiveGray,
  );
  TextStyle descStyleIOS = const TextStyle(color: CupertinoColors.inactiveGray);

  @override
  void initState() {
    Utils.getIntervalTest().then((str) {
      setState(() {
        dropdownValue = str;
        //Utils.setAlarmGeneralIntervalSettings(dropdownValue!);
      });
    });
    // String? val = pref?.getString("alarm_interval_setting");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildUserGeneralSettings();
  }

  Container buildUserGeneralSettings() {
    //super.initState();

    return Container(
          color: Colors.white,
          child: Column(children: <Widget>[
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
    ),
    // const Divider(height: 1, color: Colors.black12, thickness: 5),
    Container(
      height: 30,
      color: Colors.white,
    ),
    Container(
      //height: 30,
      color: Colors.white,
      child: const Text("General settings ",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20)),
    ),
    const Divider(height: 14, color: Colors.white, thickness: 5),

    //const Divider(height: 4, color: Colors.black12, thickness: 5),
    _buildUserGeneralSettings(),
          ]),
          // ),
        );
  }

  BoxDecoration buildBoxDecoration() {
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
    );
  }

  Widget _buildUserGeneralSettings() {
    //debugPrint("-- 0 dropdown value: $dropdownValue");
    bool isEnabledSave = false;
    ValueNotifier<bool> notifier = ValueNotifier(isEnabledSave);

    return Container(
        padding:
            const EdgeInsets.only(left: 30, right: 12, bottom: 12, top: 15),
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(
            //alignment: WrapAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              const Row(children: [
                Text("Alarm interval:",
                    style: TextStyle(fontSize: 14))
              ]),
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.1, vertical: 0.1),
                      decoration: GuiUtils.buildBoxDecorationInterval(),
                      child: _buildDropdownMenu(isEnabledSave, notifier)),
                  IconButton(
                      icon: notifier.value != dropdownValue
                          ? const Icon(
                              Icons.check,
                              size: 35,
                            )
                          : const Icon(null),
                      onPressed: notifier.value == dropdownValue
                          ? null
                          : () {
                              saveInterval(dropdownValue!);
                              isEnabledSave = false;
                              notifier.value = false;
                            })
                ],
              ),
              const Divider(
                  height: 20, color: Colors.transparent, thickness: 2),
            ],
          ),
        ]));
  }

  DropdownMenu<String> _buildDropdownMenu(
      bool isEnabledSave,
      ValueNotifier notifier,
      ) {
    debugPrint("initState _buildDropdownMenu, val $dropdownValue");

    SharedPreferences.getInstance().then((pref) {
      if (dropdownValue!.isEmpty) {
        String? val = pref.getString("alarm_interval_setting");
        if (val == null || val.isEmpty) {
          dropdownValue = ShowAlarmTimeSettings.minutes10;
        } else {
          dropdownValue = val;
        }
      }
    });

    bool isEnabledSave = false;
    ValueNotifier<bool> notifier = ValueNotifier(isEnabledSave);

    final dropdown = DropdownMenu<String>(
      width: 220,
      menuStyle: MenuStyle(
        elevation: WidgetStateProperty.all(8),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        shadowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.15)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 6)),
      ),
      textStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      initialSelection: dropdownValue!.isNotEmpty
          ? dropdownValue
          : ShowAlarmTimeSettings.minutes10,
      onSelected: (String? val) {
        if (val == "") {
          isEnabledSave = false;
          notifier.value = isEnabledSave;
        } else if (val == val) {
          isEnabledSave = false;
          notifier.value = isEnabledSave;
        } else {
          isEnabledSave = true;
          notifier.value = isEnabledSave;
        }
        setState(() {
          dropdownValue = val!;
        });
      },
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints.tight(const Size.fromHeight(48)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
        ),
      ),
      trailingIcon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.black54,
      ),
      selectedTrailingIcon: const Icon(
        Icons.keyboard_arrow_up_rounded,
        color: Color(0xFF2563EB),
      ),
      dropdownMenuEntries:
      alarmIntervalsList.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(
          value: value,
          label: value,
          labelWidget: Container(
            width: 180,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          style: ButtonStyle(
            overlayColor:
            WidgetStateProperty.all(const Color(0xFF2563EB).withOpacity(0.08)),
            padding:
            WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
        );
      }).toList(),
    );

    return dropdown; // ✅ ensures a non-null return
  }


  SharedPreferences? preferences;

  Future<void> saveInterval(String interval) async {
    debugPrint("saving interval settings.... $interval");
    /***
     * TODO: ce skenslas aplikacijo, ne dobi alarmInterval!!!
     * ko jo na novo odpres, interval ni shranjen!!
     *
     * units -> not set
     * ***/
    /*SharedPreferences.getInstance().then((value) {
      String? v = value.getString("alarm_interval_setting");
      debugPrint("v: $v");
      dropdownValue = v;
    }); */
    dropdownValue = interval;
    SmartMqtt.instance.setAlarmIntervalSettings(interval);
    //SmartMqtt.instance.alarmInterval = interval;
    debugPrint(
        "dropdown value from smartMqtt ${SmartMqtt.instance.alarmInterval}");
    //SharedPreferences.getInstance().then((value) => value.setString(key, value))
    SharedPreferences.getInstance().then((value) {
      value.setString("alarm_interval_setting", interval);
      debugPrint("setting: $interval");
    }).then((value) => SmartMqtt.instance.setAlarmIntervalSettings(interval));

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    //Utils.getAlarmGeneralIntervalSettings().then((str) {
    // Utils.setAlarmGeneralIntervalSettings(interval);
    // debugPrint("getting interval....$str");
    // });
    debugPrint("interval saved...");
  }

  @override
  void dispose() {
    debugPrint("user-general-settings.dart - dispose");
    super.dispose();
  }
}
