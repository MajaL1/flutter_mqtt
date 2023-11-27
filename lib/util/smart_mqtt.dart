import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/alarm.dart';
import '../mqtt/state/MQTTAppState.dart';

class SmartMqtt extend ChangeNotifier {
  late String host;
  late int port;

  late String mqttPass;
  late String username;

  late List<String> topicList;
  late String _identifier;

  late String currentTopic;

  MQTTAppConnectionState currentState = MQTTAppConnectionState.disconnected;

  late MqttServerClient client;
  late MqttConnectionState connectionState;

  late bool isConnected = false;

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
    client.publishMessage(currentTopic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// PING response received
  void pong() {
    print('Ping response client callback invoked');
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
    //_currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    currentState = MQTTAppConnectionState.connected;

    print('on Connected: EXAMPLE::Mosquitto client connected....');
    for (String topicName in topicList) {
      client.subscribe(topicName, MqttQos.atLeastOnce);
    }
    // client!.subscribe(topic3, MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      // ignore: avoid_as
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

     /* preferences.remove("settings_mqtt");
      preferences.remove("alarm_mqtt");
      preferences.clear(); */

      /***  polnjenje objekta - data ***/
      if (topicName!.contains("settings")) {
        debugPrint("___________________________________________________");
        debugPrint("from which topic $topicName");
        debugPrint("__________ $decodeMessage");
        debugPrint("___________________________________________________");
        preferences.setString("settings_mqtt", decodeMessage);
        preferences.setString(
            "settings_mqtt_device_name", topicName.split("/settings").first);
      }
      if (topicName.contains("data")) {
        //debugPrint("from which topic -data $topicName");
        //preferences.setString("data_mqtt", decodeMessage);
      }
      if (topicName.contains("alarm")) {
        debugPrint("from which topic -alarm $topicName, $decodeMessage");

        //prebere listo alarmov iz preferenc in jim doda nov alarm
        SharedPreferences preferences = await SharedPreferences.getInstance();

        // 1. dobi listo prejsnjih alarmov
        String? alarmListOldData =
            preferences.get("alarm_list_mqtt") as String?;
        List a1 = [];
        if(alarmListOldData != null) {
          a1 = json.decode(alarmListOldData!);
        }

        // 2. dobi trenuten alarm
        Map<String, dynamic> currentAlarmJson = json.decode(decodeMessage);
        List<Alarm> currentAlarmList = Alarm.getAlarmList(currentAlarmJson);
        currentAlarmList.first.sensorAddress = topicName.split("/alarm").first;
        // 3. doda alarm na listo starih alarmov
        //a1.addAll(currentAlarmList);
        String alarmListMqtt = jsonEncode(a1);
        preferences.setString("alarm_list_mqtt", alarmListMqtt);
        //debugPrint("alarmList---: $alarmListMqtt");

        // prikaze sporocilo z alarmom
        //NotificationHelper.sendMessage(currentAlarmList.first);
      }
      print("======= pt: ${pt} , topic: $topicList[0], $topicList[1]");
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  Future<MqttServerClient> initializeMQTTClient() async {
    String osPrefix = 'Flutter_iOS';
    // if (Platform.isAndroid()) {
    osPrefix = 'Flutter_Android';
    String identifier = "_12apxeeejjjewg";
    _identifier = identifier;
    client = MqttServerClient(host, identifier, maxConnectionAttempts: 10);
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.autoReconnect = true;
    client.onDisconnected = onDisconnected;
    client.secure = false;
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;

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
      await client.connect(username, mqttPass);
    } on Exception catch (e) {
      print('Navis app::client exception - $e');
      disconnect();
    }
    return client;
  }
}

//subscribe to topic failed
void onSubscribeFail(String topic) {
  print('Failed to subscribe $topic');
}
