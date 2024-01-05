import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/notification_helper.dart';
import '../model/alarm.dart';
import '../mqtt/MQTTAppState.dart';

class SmartMqtt extends ChangeNotifier {
  late String host;
  late int port;

  late String mqttPass;
  late String username;

  late List<String> topicList;
  late String _identifier;

  late String currentTopic;

  int messageCount = 0;

  MQTTAppConnectionState currentState = MQTTAppConnectionState.disconnected;

  late MqttServerClient client;
  late MqttConnectionState connectionState;

  late bool isConnected = false;
  late bool userIsLoggedIn = false;

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
    _instance.topicList = topicList;
    return _instance;
  }

  bool debug = true;
  late bool isSaved = false;
  late bool newSettingsMessageLoaded = false;
  late String newUserSettings = "";

  void disconnect() {
    print('Disconnected');
    client.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    // find settings topic
    for (String topic in topicList) {
      if (topic.contains("settings")) {
        currentTopic = topic;
      }
    }
    isSaved = true;
    client.publishMessage(currentTopic, MqttQos.exactlyOnce, builder.payload!);
    //notifyListeners();
  }

  /// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }

  void ping() {
    print("-----ping");
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The subscribed callback
  void unsubscribe(String topic) {
    print('EXAMPLE::UNSubscription confirmed for topic $topic');
    client.unsubscribe(topic);
  }

  void onAutoReconnect() {
    print("onAutoReconnect");
  }
    /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    currentState = MQTTAppConnectionState.disconnected;
  }

  /// The successful connect callback
  void onConnected() {
    currentState = MQTTAppConnectionState.connected;

    print('on Connected: EXAMPLE::Mosquitto client connected....');
    for (String topicName in topicList) {
      client.subscribe(topicName, MqttQos.atLeastOnce);
    }
    // client!.subscribe(topic3, MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      await mqttMessageProcessor(c);
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  Future<void> mqttMessageProcessor(
      List<MqttReceivedMessage<MqttMessage?>>? c) async {
    final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

    // final MqttPublishMessage recMess = c![0].payload;
    final String pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    //_currentState.setReceivedText(pt);

    String message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    String decodeMessage = const Utf8Decoder().convert(message.codeUnits);

    String? topicName = recMess.variableHeader?.topicName;

    SharedPreferences preferences = await SharedPreferences.getInstance();

    // todo: testni alarm - izbrisi
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
    NotificationHelper.sendMessage(alarm); */

    /* preferences.remove("settings_mqtt");
    preferences.remove("alarm_mqtt");
    preferences.clear(); */

    /***  polnjenje objekta - data ***/
    if (topicName!.contains("settings")) {
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
        // debugPrint("got new settings");
        // ali novi settingi niso enaki prejsnim
        // ali ce so v zacetku prazni
        if (newUserSettings.compareTo(decodeMessage) != 0) {
          debugPrint("new user settings");

          newUserSettings = decodeMessage;
          await setNewUserSettings(newUserSettings);
        }

        // debugPrint("----- newUserSettings: $newUserSettings");
        preferences.setString(
            "settings_mqtt_device_name", topicName.split("/settings").first);
      }
      preferences.setString("settings_mqtt", decodeMessage);
    }
    if (topicName.contains("data")) {
      //debugPrint("from topic -data $topicName");
      //preferences.setString("data_mqtt", decodeMessage);
    }
    if (topicName.contains("alarm")) {
      if (messageCount > 0) {
        Map<String, dynamic> currentAlarmJson = json.decode(decodeMessage);
        List<Alarm> currentAlarmList = Alarm.getAlarmList(currentAlarmJson);
        //prebere listo alarmov iz preferenc in jim doda nov alarm
        SharedPreferences preferences = await SharedPreferences.getInstance();

        // 1. dobi listo prejsnjih alarmov
        String? alarmListOldData =
            preferences.get("alarm_list_mqtt") as String?;
        List oldAlarmList = [];
        if (alarmListOldData != null) {
          oldAlarmList = json.decode(alarmListOldData);
        }

        DateTime? lastAlarmDate =
            await SharedPreferences.getInstance().then((value) {
          if (value.getString("last_sent_alarm_date") != null) {
            String? lastAlarmDateString =
                value.getString("last_sent_alarm_date");
            //debugPrint("last_sent_alarm_date $lastAlarmDateString");
            return DateTime.parse(lastAlarmDateString!);
          }
        });

        int? lastSentHiAlarmValue =
            await SharedPreferences.getInstance().then((value) {
          if (value.getString("last_sent_hi_alarm_value") != null) {
            int? lastSentHiAlarmValue =
                value.getInt("last_sent_hi_alarm_value");
            //debugPrint("last_sent_hi_alarm_value $lastSentHiAlarmValue");
            return lastSentHiAlarmValue;
          }
        });

        int? lastSentLoAlarmValue =
            await SharedPreferences.getInstance().then((value) {
          if (value.getString("last_sent_lo_alarm_value") != null) {
            int? lastSentLoAlarmValue =
                value.getInt("last_sent_lo_alarm_value");
            debugPrint("last_sent_lo_alarm_value $lastSentLoAlarmValue");
            return lastSentLoAlarmValue;
          }
        });

        int minutes = 6;
        if (lastAlarmDate != null) {
          minutes = Utils.compareDatesInMinutes(lastAlarmDate!);
        }

        //ali je vec kot 5 minut od alarma
        if (minutes > 5) {
          debugPrint(
              "from topic-alarm $topicName, $decodeMessage, message count: $messageCount, comparedDatesInMinutes:: $minutes ");

          // 2. dobi trenuten alarm
          currentAlarmList.first.sensorAddress =
              topicName.split("/alarm").first;
          // 3. doda alarm na listo starih alarmov
          // odkomentiraj, da bo dodajalo alarm
          oldAlarmList.addAll(currentAlarmList);
          String alarmListMqtt = jsonEncode(oldAlarmList);
          preferences.setString("alarm_list_mqtt", alarmListMqtt);
          //debugPrint("alarmList---: $alarmListMqtt");
          messageCount++;

          // prikaze sporocilo z alarmom
          await NotificationHelper.sendMessage(currentAlarmList.first);
          await SharedPreferences.getInstance().then((value) {
            value.setString(
                "last_sent_alarm_date", currentAlarmList.first.ts.toString());
          });
        }
        // debugPrint("message is not retain, message count: $firstRetainMessage");
      } else {
        debugPrint("first-retain message ignored $messageCount");
        messageCount++;
      }

      //debugPrint("payload: $pt");
    }

    // print("======= pt: ${pt} , topic: $topicList[0], $topicList[1]");
    //print(
    //  'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    //print('');
  }

  Future<MqttServerClient> initializeMQTTClient() async {
    String osPrefix = 'Flutter_iOS';
    // if (Platform.isAndroid()) {
    osPrefix = 'Flutter_Android';
    String identifier = "_12apxeeejjjewg";
    _identifier = identifier;
    client = MqttServerClient(host, identifier, maxConnectionAttempts: 10);
    client.port = 1883;
    client.keepAlivePeriod = 200000;
    client.autoReconnect = true;
    client.setProtocolV311();
    client.onDisconnected = onDisconnected;
    client.onAutoReconnect = onAutoReconnect;
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    client.secure = false;
    client.resubscribeOnAutoReconnect = true;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(username, mqttPass)
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    print('EXAMPLE:: client connecting....');
    client.connectionMessage = connMess;

    try {
      print('::Navis app client connecting....');
      currentState = MQTTAppConnectionState.connecting;
      client.keepAlivePeriod = 20;
      print(
          "*********************** Connecting to broker *******************************");
      await client.connect(username, mqttPass);
    } on Exception catch (e) {
      print('Navis app::client exception - $e');
      disconnect();
    }
    return client;
  }

  Future<String> getNewUserSettingsList() async {
    // if(newUserSettings != null) {
    return newUserSettings;
    //}
  }

  Future<void> setNewUserSettings(String newUserSettings) async {
    this.newUserSettings = newUserSettings;

    this.isSaved = true;
    notifyListeners();
    debugPrint("notifying listeners..");
  }
}

//subscribe to topic failed
void onSubscribeFail(String topic) {
  print('Failed to subscribe $topic');
}
