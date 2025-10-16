import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/notification_helper.dart';
import '../model/alarm.dart';
import '../model/constants.dart';
import '../model/data.dart';
import '../mqtt/MQTTAppState.dart';
import '../widgets/show_alarm_time_settings.dart';
import 'data_smart_mqtt.dart';

class SmartMqtt extends ChangeNotifier {
  String? host;
  int? port;

  String? mqttPass;
  String? username;

  late List topicList = [];
  late String _identifier;

  late String currentTopic;

  int messageCount = 0;

  MQTTAppConnectionState? currentState; //= MQTTAppConnectionState.disconnected;

  MqttServerClient? client;
  late MqttConnectionState connectionState;

  //late bool isConnected = false;
  late bool userIsLoggedIn = false;
  bool connected = false;

  static final SmartMqtt _instance = SmartMqtt._internal();

  SmartMqtt._internal();

  static SmartMqtt get instance => _instance;

  factory SmartMqtt(
      {required String host,
      required int port,
      required String username,
      required String mqttPass,
      required topicList}) {
    _instance.host = host;
    _instance.port = port;
    _instance.username = username;
    _instance.mqttPass = mqttPass;
    List topics = json.decode(topicList);
    _instance.topicList = topics;
    _instance.initializeMQTTClient();
    //debugPrint("SMARTMQTT constructor;, client: ${_instance.client}");
    return _instance;
  }

  // SmartMqtt._internal() {    // initialization logic
  //initializeMQTTClient();
  //}

  //static SmartMqtt getInstance() {
  // return _instance;
  // }

  // void setMqtt(SmartMqtt mqtt){
  // _instance = mqtt;
  //}

  bool getConnectionState() {
    return connected;
  }

  bool debug = true;
  late bool isSaved = false;
  late bool newSettingsMessageLoaded = false;
  String newUserSettings = "";
  late Data newMqttData;
  String alarmInterval = "";

  void disconnect() {
    currentState = MQTTAppConnectionState.disconnected;

    connected = false;
    SharedPreferences.getInstance().then((value) {
      value.setBool("connected", false);
      setCurrentState(instance.currentState);
    });
    print('Disconnected');

    client!.disconnect();
  }

  void publish(String message, String topicName) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    // find settings topic
    // MqttServerClient ? c = getClient();
    //debugPrint("11:::smartmqtt: $_instance");
    //debugPrint("11:::client: $client");
    //debugPrint("11:::c: $c");

    debugPrint("1:::client:::  ${_instance.client}, ${instance.client}");
    //debugPrint("publishing to current topic: $topicName, message: $message, 2client: ${_instance.client}");
    isSaved = true;
    client!.publishMessage(topicName, MqttQos.exactlyOnce, builder.payload!);
    //notifyListeners();
  }

  /// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }

  void ping() {
    debugPrint("---ping $mqttPass $currentState  ping---");
    print("-----ping");
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('onSubscribed::Subscription confirmed for topic $topic');
  }

  /// The subscribed callback
  void unsubscribe(String topic) {
    print('onunSubscribed::UNSubscription confirmed for topic $topic');
    client!.unsubscribe(topic);
  }

  void onAutoReconnect() {
    String clientID = client!.clientIdentifier;
    instance.currentState = MQTTAppConnectionState.connected;
    print(
        "///////////////////////////// onAutoReconnect  $clientID, $instance.currentState ///////////////////////////////////");
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    String clientID = client!.clientIdentifier;
    print(
        "///////////////////////////// onDisconnected  $clientID, $instance.currentState ///////////////////////////////////");
    MqttConnectReturnCode? returnCode = client!.connectionStatus!.returnCode;
    print(
        ':OnDisconnected client callback - Client disconnection, return code: $returnCode');
    if (client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print(":OnDisconnected callback is solicited, this is correct");
    }
    instance.currentState = MQTTAppConnectionState.disconnected;
    setCurrentState(instance.currentState);
  }

  /// The successful connect callback
  void onConnected() {
    String clientID = client!.clientIdentifier;
    _instance.currentState = MQTTAppConnectionState.connected;
    setCurrentState(_instance.currentState);
    connected = true;
    SharedPreferences.getInstance().then((value) {
      value.setBool("connected", true);
    });
    print(
        "///////////////////////////// onConnected,  $clientID, $currentState  ///////////////////////////////////");

    print('on Connected: ALARM APP:Mosquitto client connected....');
    for (String topicName in topicList) {
      client!.subscribe(topicName, MqttQos.atLeastOnce);
      debugPrint("topicName: $topicName");
    }
    // client!.subscribe(topic3, MqttQos.atLeastOnce);

    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      await mqttMessageProcessor(c);
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  Future<void> mqttMessageProcessor(
      List<MqttReceivedMessage<MqttMessage?>>? c) async {
    final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

    debugPrint("mqttMessageProcessor: currentState: $currentState");
    // final MqttPublishMessage recMess = c![0].payload;
    // final String pt =
    //     MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    //_currentState.setReceivedText(pt);

    // FlutterBackgroundService().invoke("setAsBackground");

    String message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    String decodeMessage = const Utf8Decoder().convert(message.codeUnits);
    //debugPrint("MQTT decodeMessage: $decodeMessage");
    String? topicName = recMess.variableHeader?.topicName;

    bool? isRetain = recMess.header?.retain;

    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? alarmInterval1 =
        await SharedPreferences.getInstance().then((value) {
      return value.getString("alarm_interval_setting");
    });
    debugPrint("alarmInterval 1: $alarmInterval1");

    // todo: testni alarm
    /*Alarm alarm = Alarm(
        sensorAddress: "test1233",
        typ: 2,
        v: 1,
        hiAlarm: 10,
        loAlarm: 2,
        ts: DateTime.timestamp(),
        lb: 1,
        bv: 3,
        r: 1,
        l: 3,
        b: 2,
        t: 3);
    NotificationHelper.instance.sendMessage(alarm); */

    /* preferences.remove("settings_mqtt");
    preferences.remove("alarm_mqtt");
    preferences.clear(); */

    if (topicName!.contains("data")) {
      // DataSmartMqtt implementira notifierja za getNewData
      DataSmartMqtt dataSmartMqtt = DataSmartMqtt.instance;

      await dataSmartMqtt.dataProcessor(decodeMessage, topicName, preferences);
    }
    /***  polnjenje objekta - settings ***/
    if (topicName.contains("settings")) {
      debugPrint("___________________________________________________");
      debugPrint("from topic $topicName");
      debugPrint("__________ $decodeMessage");
      debugPrint("___________________________________________________");

      //preverimo, ker je prvo sporocilo
      // po shranjevanju oblike {"135":{"hi_alarm":111}}
      // in tega izpustimo
      if ((decodeMessage.contains("v") ||
          decodeMessage.contains("typ") ||
          decodeMessage.contains("u"))) {
          debugPrint("got new settings mqtt");
        // ali novi settingi niso enaki prejsnim
        // ali ce so v zacetku prazni
        if (newUserSettings.compareTo(decodeMessage) != 0 &&
            decodeMessage.isNotEmpty) {
          await _parseMqttSettingsForTopic(preferences, decodeMessage, topicName);
          //{\"57\":{\"typ\":1,\"u\":0,\"ut\":0,\"hi_alarm\":0,\"ts\":455},\"84\":{\"typ\":1,\"u\":0,\"ut\":0,\"hi_alarm\":0,\"ts\":455}}
        }
      }
    }
    if (topicName.contains("alarm")) {
      //debugPrint("+++++alarm!!!!!, isRetain $isRetain");
      if (!isRetain!) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.reload();
        Map<String, dynamic> currentAlarmJson = json.decode(decodeMessage);
        List<Alarm> currentAlarmList = Alarm.getAlarmList(currentAlarmJson);
        currentAlarmList.first.deviceName = topicName.split("/alarm").first;

       //debugPrint("+++++ALARM ? check below if show ${currentAlarmList.first.toString()},: ${messageCount}");

        //prebere listo alarmov iz preferenc in jim doda nov alarm
        SharedPreferences preferences = await SharedPreferences.getInstance();

        // 1. dobi listo prejsnjih alarmov
        String? alarmListOldData = preferences.get("alarm_list_mqtt") as String?;
        List oldAlarmList = [];
        if (alarmListOldData != null) {
          oldAlarmList = json.decode(alarmListOldData);
        }

        int minutes = 0;
        int timeIntervalMinutes = 0;
        // preveri interval

        bool showAlarm = false;
        bool noAlarm = false;
        String? alarmInterval; //= getAlarmInterval();
        //if(alarmInterval.isEmpty){

        //String? alarmInterval1 = preferences.getString("alarm_interval_setting");

        //debugPrint("+++++got alarmInterval1: $alarmInterval1");
        /*String? a = await SharedPreferences.getInstance().then((value) {
          if (value.getString("alarm_interval_setting") != null) {
            debugPrint("aaa: ${value.getString("alarm_interval_setting")}");
            return value.getString("alarm_interval_setting")!;
          } else {
            debugPrint("aaa 1: ${value.getString("alarm_interval_setting")}");
          }
          return "";
        });*/

        alarmInterval = preferences.getString("alarm_interval_setting");
        //}
        //debugPrint("+++++got alarmInterval: $alarmInterval");
        timeIntervalMinutes = Utils.getIntervalFromPreferences(alarmInterval);
        if (timeIntervalMinutes == 100000) {
          noAlarm = true;
        }
        //debugPrint("+++++ 1timeIntervalMinutes $timeIntervalMinutes");

        if (timeIntervalMinutes == ShowAlarmTimeSettings.noAlarm) {
          noAlarm = true;
        }
        if (timeIntervalMinutes == "") {
          //debugPrint("+++++ 2timeIntervalMinutes == ''");
          showAlarm = true;
        }

        // ce ni prazen in ce ni izbrano, da prikaze vse alarme
        if (timeIntervalMinutes != "") {
          //debugPrint("+++++ 3timeIntervalMinutes != " ": $timeIntervalMinutes");

          //debugPrint("+++++ 4got timeIntervalMinutes: $timeIntervalMinutes");

          if (alarmInterval == ShowAlarmTimeSettings.all) {
            showAlarm = true;
          }

          // dobi zadnji datum od alarma iz naprave iz historija
          _getLastAlarmDateFromHistory(currentAlarmList.first.deviceName, currentAlarmList.first.sensorAddress)
              .then((value) async {
            // primerjaj zadnji alarm s trenutnim casom
            // trenutni cas - zadnji alarm
            showAlarm = false;
            //debugPrint("+++++ value: $value for device ${currentAlarmList.first.deviceName} ${currentAlarmList.first.sensorAddress}");
            if (value != null) {
              // if(!value.isBefore(DateTime.now())) {
              minutes = Utils.compareDatesInMinutes(value, DateTime.now());
              //debugPrint("+++++ got minutes from compare: $minutes, timeIntervalInMinutes: ${minutes}");
              // primerjaj s shranjenim intervalom
              if (minutes >= timeIntervalMinutes || timeIntervalMinutes == 1) {
                //debugPrint("+++++ minutes > timeIntervalMinutes, will show alarm");

                showAlarm = true;
                // ce je minilo vec minut od prejsnjega alarma
                // prikazi alarm
              } else {
                //debugPrint("+++++ minutes < timeIntervalMinutes, NOT show alarm");
              }
              // }
              // else {
              //   showAlarm = false;
              // }
            } else {
              showAlarm = true;
            }
            if (showAlarm) {
              //debugPrint(" WILL SHOW ALARM +++++ from topic-alarm $topicName, $decodeMessage, message count: $messageCount ");
              oldAlarmList.addAll(currentAlarmList);
              String alarmListMqtt = jsonEncode(oldAlarmList);
              await preferences.setString("alarm_list_mqtt", alarmListMqtt);
              debugPrint("smartmqtt - alarmList---: $alarmListMqtt");
              messageCount++;

              String ? friendlyName = await Utils.setFriendlyName(currentAlarmList.first);
              //debugPrint("utils - setFriendlyName after: $friendlyName");
              if(friendlyName != null) {
                currentAlarmList.first.friendlyName = friendlyName;
              }
                        
              // prikaze sporocilo z alarmom
              if (!noAlarm) {
                await NotificationHelper.instance.sendMessage(currentAlarmList.first);
              }
            }
          });
        }
      }
    }
  }

  Future<void> _parseMqttSettingsForTopic(SharedPreferences preferences, String decodeMessage, String topicName) async {
    try {
      debugPrint("new user settings");
      preferences.setString("current_mqtt_settings", decodeMessage);
      // parse trenutno sporocilo
      Map decodeMessageSettings = <String, String>{};
      decodeMessageSettings = json.decode(decodeMessage);
      //debugPrint("AAAAAAAA  decodeMessageSettings: ${decodeMessageSettings}");
      await setDeviceNameToSettings(decodeMessageSettings, topicName
          .split("/settings")
          .first);
      //-----
      //String oldUserSettings = newUserSettings;
      Map newSettings = <String, String>{};
      if (newUserSettings.isEmpty) {
        debugPrint("1 AAAAAAAA  newUserSettings.isEmpty:, newUserSettings: $decodeMessage");
        newUserSettings = decodeMessage;
        newSettings = json.decode(newUserSettings);
        //debugPrint("1 AAAAAAAA newSettings: ${newSettings}");

        await setDeviceNameToSettings(newSettings, topicName.split("/settings").first);
        //debugPrint("1 AAAAAAAA2 newSettings: ${newSettings}");

        await setNewUserSettings(newSettings);
        notifyListeners();
        debugPrint("notifying listeners 0.. $newSettings");
      } else if (newUserSettings.isNotEmpty && !newUserSettings.contains(decodeMessage)) {
        debugPrint("2 AAAAAAAA  newUserSettings.isNotEmpty &&!decodeMessage.contains(newUserSettings),");
        //debugPrint("3 AAAAAAAA: decodeMessageSettings ${decodeMessageSettings}");

        //debugPrint("4 AAAAAAAA: newSettings ${newUserSettings}");
        newSettings = json.decode(newUserSettings);

        //  stare settinge za doloceno napravo zamenja za nove
        // ... je concatenate, iz mapa nadomesti key-e z decodemessagesettings
        final concatenatedSettings = {
          ...newSettings,
          ...decodeMessageSettings,
        };
        if (newUserSettings != null || newUserSettings.isNotEmpty) {
          newUserSettings = json.encode(concatenatedSettings);
          debugPrint("notifying listeners 1.. $newUserSettings");
          preferences.setString("current_mqtt_settings", newUserSettings);
          // await setNewUserSettings(concatenatedSettings);

          preferences.setBool("settingsChanged", true);
          notifyListeners();
        }

        //print("map: ${concatenatedSettings}");
        //debugPrint("5 AAAAAAAA: concatenatedSettings ${concatenatedSettings}");
      }
    } catch(e){
      debugPrint("!!!Exception:: $e");
    }
  }

  // iz historija dobi zadnji alarm za napravo in vrne njen datum
  Future<DateTime?> _getLastAlarmDateFromHistory(
      String? deviceName, String? sensorName) async {
    List<Alarm> alarmList = [];

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("alarm_list_mqtt")) {
      String alarmListData = preferences.get("alarm_list_mqtt") as String;
      if (alarmListData.isNotEmpty) {
        List alarmMessageJson = json.decode(alarmListData);
        alarmList = Alarm.getAlarmListFromPreferences(alarmMessageJson);
      }
    }

    //bool found = true;
    DateTime? lastSentAlarm;
    for (Alarm alarm in alarmList) {
      String? alarmDeviceName = alarm.deviceName;
      String? alarmSensorAddress = alarm.sensorAddress;
      // zadnji datum
      if (alarmDeviceName == deviceName && alarmSensorAddress == sensorName) {
        //found = true;
        lastSentAlarm = alarm.ts;
        if (lastSentAlarm!.isAfter(alarm.ts!)) {
          lastSentAlarm = alarm.ts;
          break;
        }
      }
    }

    /* for (Alarm alarm in alarmList) {
      debugPrint("Printing alarmList ${alarm.toString()}");
    } */

    //debugPrint("alarmList.size: ${alarmList.length}");
    //lastSentAlarm ??= DateTime.now();
    debugPrint(
        "----lastSentAlarm: $lastSentAlarm for device $deviceName, sensonName: $sensorName");

    return lastSentAlarm;
  }

  MqttServerClient? getClient() {
    return client;
  }

  void setClient(MqttServerClient c) {
    debugPrint("setting MqttServerClient");
    client = c;
  }

  MqttServerClient initializeMQTTClient() {
    debugPrint(" calling smart_mqtt.dart - initializeMQTTClient");
    //String osPrefix = 'Flutter_iOS';
    // if (Platform.isAndroid()) {
    //osPrefix = 'Flutter_Android';
    topicList = topicList;

    String l = Utils.generateRandomString(10);
    //String identifier = "_12apxeeejjjewg";
    String identifier = l.toString();

    _identifier = identifier;
    _instance.client = MqttServerClient(Constants.BROKER_IP, identifier,
        maxConnectionAttempts: 1);
    _instance.client!.port = 1883;
    _instance.client!.keepAlivePeriod = 50;
    //client.autoReconnect = true;
    _instance.client!.autoReconnect = true;
    // client.setProtocolV311();
    _instance.client!.onDisconnected = onDisconnected;
    _instance.client!.onAutoReconnect = onAutoReconnect;
    _instance.client?.logging(on: true);
    _instance.client!.onConnected = onConnected;
    _instance.client!.onSubscribed = onSubscribed;
    _instance.client!.onSubscribeFail = onSubscribeFail;
    _instance.client!.pongCallback = pong;
    _instance.client!.secure = false;
    //client.maxConnectionAttempts = 1;
    // client.resubscribeOnAutoReconnect = true;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(username, mqttPass)
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    debugPrint(':: client connecting....');
    client!.connectionMessage = connMess;

    try {
      print('::Navis app client connecting....');
      instance.currentState = MQTTAppConnectionState.connecting;
      setCurrentState(instance.currentState);
      //client.keepAlivePeriod = 20;
      String clientID = client!.clientIdentifier;
      print(
          "*********************** Connecting to broker, client id $clientID, $currentState *******************************");

      client!.connect(username, mqttPass);
    } on Exception catch (e) {
      print('Navis app::client exception - $e');
      disconnect();
    }
    SharedPreferences.getInstance().then((val) {
      String clientStr = json.encode(client.toString());
      val.setString("client_mqtt", clientStr);
      val.setString("identifier", identifier);
      debugPrint("CLIENT SmartMqtt from prefereces: ${client.toString()}");
      val.reload();
    });
    return client!;
  }

  Future<MQTTAppConnectionState?> getCurrentState() async {
    return currentState;
  }

  Future<String> getNewUserSettingsList() async {

    debugPrint("getNewUserSettingsList 222222222222 new User settings - smart mqtt:");
    String  settings =  "";
    await SharedPreferences.getInstance().then((value) {
      String set = value.getString("current_mqtt_settings")!;
      debugPrint("2222222222222 new User settings - smart mqtt: $set");
      settings = set;
      //return set;
    });
    debugPrint("1111111111111 new User settings - smart mqtt: $settings");
    return settings;
  }

  Future<void> setDeviceNameToSettings(Map settings, String deviceName) async {
    for (String key in settings.keys) {
      if (settings[key] != null && (key != "ts")) {
        Map val = settings[key];

        //for (String key1 in val.keys) {
          //print("key1: $key1");
        //}
        final Map<String, String> deviceNameMap = {"device_name": deviceName};
        val.addAll(deviceNameMap);
      }
    }
  }

  Future<void> setNewUserSettings(Map concatenatedSettings) async {
    newUserSettings = json.encode(concatenatedSettings);
    debugPrint("setting new user settings: $concatenatedSettings");
  }

  Future<void> setAlarmIntervalSettings(String interval) async {
    alarmInterval = interval;
  }

  String getAlarmInterval() {
    return alarmInterval;
  }

  Data? convertMessageToData(String message, String deviceName) {
    String decodeMessage = const Utf8Decoder().convert(message.codeUnits);
    Map<String, dynamic> dataStr = json.decode(decodeMessage);

    Data? data = Data().getData(dataStr);
    // Data data = json.decode(dataStr);
    data?.deviceName = deviceName.split("/data").first;

    debugPrint(
        "converting data object...${data?.deviceName}, ${data?.sensorAddress}, ${data?.typ}, ${data?.t}");

    return data;
  }

  void setDataListToPreferences(Data newData, SharedPreferences preferences) {
    //String? dataListStr = preferences.getString("data_mqtt_list");
    List? dataList;

    // zaenkrat dodamo samo eno element na listo
    /*if (dataListStr != null) {
      final jsonResult = jsonDecode(dataListStr!);
      dataList = Data.fromJsonList(jsonResult);
      dataList.add(newData);
    } else { */
    dataList = [];
    dataList.add(newData);
    // }
    String encodedData = json.encode(dataList);
    debugPrint("encodedData:  $encodedData");
    preferences.setString("data_mqtt_list", encodedData);
    debugPrint("setting data_mqtt_list encodedData: $encodedData");
  }

  void setCurrentState(MQTTAppConnectionState? currentState) {
    instance.currentState = currentState;
    SharedPreferences.getInstance().then((val) {
      val.setString("current_state", currentState.toString());
    });
  }

  /*_instance.host = host;
    _instance.port = port;
    _instance.username = username;
    _instance.mqttPass = mqttPass;
    _instance.topicList = topicList;*/
  Map<String, dynamic> toJson() {
    return {
      "host": host,
      "port": port,
      "username": username,
      "mqttPass": mqttPass,
      //"topicList": topicList,
      // "currentState": currentState,
      "_identifier": _identifier,
      "client": client!.connectionStatus
    };
  }

  factory SmartMqtt.fromJson(Map<String, dynamic> map) {
    return SmartMqtt(
      host: map["host"],
      port: map["port"],
      username: map["username"],
      mqttPass: map["mqttPass"],
      topicList: map["topicList"],
      //client: map["client"]
      //currentState: map["currentState"],
      //_identifier: map["_identifier"]
    );
  }

  @override
  String toString() {
    return '1SmartMqtt{host: $host, port: $port, mqttPass: $mqttPass, username: $username, topicList: $topicList, currentState: $currentState,'
        ' userIsLoggedIn: $userIsLoggedIn, debug: $debug, isSaved: $isSaved, newSettingsMessageLoaded: $newSettingsMessageLoaded, newUserSettings: $newUserSettings, alarmInterval: $alarmInterval}';
  } //        ' connectionState: $connectionState, '
}

//subscribe to topic failed
void onSubscribeFail(String topic) {
  print('Failed to subscribe $topic');
}
