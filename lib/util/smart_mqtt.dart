import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/alarm.dart';
import '../model/constants.dart';
import '../mqtt/state/MQTTAppState.dart';

class SmartMqtt {
  late String host;
  late int port;

// late MQTTAppState _currentState = MQTTAppState().setAppConnectionState("disconnected");
  MQTTAppConnectionState currentState = MQTTAppConnectionState.disconnected;

  //MqttServerClient ?client;

  late String _host;
  late String topic1;
  late String topic2;
  late String topic3;
  late String _identifier;

  late MqttServerClient client;
  late MqttConnectionState connectionState;

  late bool isConnected = false;

  // <<--------------- Important --------------->>
  // final StreamController _controller = StreamController<dynamic>.broadcast();
  // Stream<dynamic> get stream => _controller.stream;

  // <<--------------- Important --------------->>
  //final StreamController _subscriptionController = StreamController<String>();
  //final StreamController _unsubscriptionController = StreamController<String>();

  // <<--------------- Important --------------->> Make this class a 'Singleton'
  static final SmartMqtt _instance = SmartMqtt._internal();

  //SmartMqtt._internal();
  SmartMqtt._internal();

  /*factory SmartMqtt() {
   return _instance;
 }*/

  Future<void> init() async {
    //_sharedPrefs = await SharedPreferences.getInstance();
  }

  factory SmartMqtt({
    String host = Constants.BROKER_IP,
    int port = Constants.BROKER_PORT,
    String topic1 = "c45bbe821261/settings",
    String topic2 = "c45bbe821261/alarm",
    String topic3 = "c45bbe821261/data",
  }) {
    _instance.host = host;
    _instance.port = port;
    _instance.topic1 = topic1;
    _instance.topic2 = topic2;
    _instance.topic3 = topic3;
    return _instance;
  }

  bool debug = true;

  // Setup Client before connecting, feel free to add additional params like keepAlive  etc.

  void disconnect() {
    print('Disconnected');
    client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic1, MqttQos.exactlyOnce, builder.payload!);
  }

// PING response received
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
    client?.unsubscribe(topic);
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    currentState = MQTTAppConnectionState.disconnected;
    // .setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    //_currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    currentState = MQTTAppConnectionState.connected;

    print('on Connected: EXAMPLE::Mosquitto client connected....');
    client.subscribe(topic1, MqttQos.atLeastOnce);
    client.subscribe(topic2, MqttQos.atLeastOnce);
    // client!.subscribe(topic3, MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      //_currentState.setReceivedText(pt);

      String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      String decodeMessage = const Utf8Decoder().convert(message.codeUnits);

      String? topicName = recMess.variableHeader?.topicName;

      SharedPreferences preferences = await SharedPreferences.getInstance();
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
      if (topicName!.contains("data")) {
        //debugPrint("from which topic -data $topicName");
        //preferences.setString("data_mqtt", decodeMessage);
      }
      if (topicName!.contains("alarm")) {
        debugPrint("from which topic -alarm $topicName, $decodeMessage");

        //prebere listo alarmov iz preferenc in jim doda nov alarm
        SharedPreferences preferences = await SharedPreferences.getInstance();

        // 1. dobi listo prejsnjih alarmov
        String? alarmListOldData =
            preferences.get("alarm_list_mqtt") as String?;
        List a1 = json.decode(alarmListOldData!);

        // 2. dobi trenuten alarm
        Map<String, dynamic> currentAlarmJson = json.decode(decodeMessage);
        List<Alarm> currentAlarmList = Alarm.getAlarmList(currentAlarmJson);
        currentAlarmList.first.sensorAddress = topicName.split("/alarm").first;
        // 3. doda alarm na listo starih alarmov
        a1.addAll(currentAlarmList);
        String alarmListMqtt = jsonEncode(a1);

        preferences.setString("alarm_list_mqtt", alarmListMqtt);
        debugPrint("alarmList---: $alarmListMqtt");

        // prikaze sporocilo z alarmom
        //NotificationHelper.sendMessage(currentAlarmList.first);
      }
      print("======= pt: ${pt} , topic: $topic1, $topic2");
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  void _onMessage(List event) {
    print(event.length);
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
    client.onDisconnected = onDisconnected;
    client.secure = false;
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    client.setProtocolV31();

    String username = "test";
    String password = "MWQxYjRkZWJlZjQ2MWViNQ==";

    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier(_identifier)
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    print('EXAMPLE:: client connecting....');
    client.connectionMessage = connMess;

    try {
      print('::Navis app client connecting....');
      currentState = MQTTAppConnectionState.connecting;
      client.keepAlivePeriod = 20;
      await client.connect(username, password);
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
