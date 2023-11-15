import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_test/api/notification_helper.dart';
import 'package:mqtt_test/mqtt/state/MQTTAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/alarm.dart';
import '../model/user_data_settings.dart';

class MQTTConnectionManager {
  // Private instance of client
  final MQTTAppState _currentState;
 static MqttServerClient ?client;
  final String _identifier;
  final String _host;
  final String _topic1;
  final String _topic2;
  final String _topic3;


  // Constructor
  MQTTConnectionManager(
      {required String host,
        required String topic1,
        required String topic2,
        required String topic3,
        required String identifier,
        required MQTTAppState state})
      : _identifier = identifier,
        _host = host,
        _topic1 = topic1,
        _topic2 = topic2,
        _topic3 = topic3,

      _currentState = state;


  void initializeMQTTClient() {
    client = MqttServerClient(_host, _identifier);
    client!.port = 1883;
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;
    client!.secure = false;
    client!.logging(on: true);

    /// Add the successful connection callback
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic(
        'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE:: client connecting....');
    client!.connectionMessage = connMess;

  }

  // Connect to the host
  // ignore: avoid_void_async
  Future<void> connect() async {
    assert(client != null);
    try {
      String username= "test";
      String password = "MWQxYjRkZWJlZjQ2MWViNQ==";
      print('::Navis app client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await client!.connect(username, password);
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(_topic1, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The subscribed callback
  void unsubscribe(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
    client?.unsubscribe(topic);
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    print('on Connected: EXAMPLE::Mosquitto client connected....');
    client!.subscribe(_topic1, MqttQos.atLeastOnce);
    client!.subscribe(_topic2, MqttQos.atLeastOnce);
    client!.subscribe(_topic3, MqttQos.atLeastOnce);

    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      _currentState.setReceivedText(pt);

      String message =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      String decodeMessage = const Utf8Decoder().convert(message.codeUnits);

      String ? topicName = recMess.variableHeader?.topicName;

      SharedPreferences preferences = await SharedPreferences.getInstance();
      /***  polnjenje objekta - data ***/
      if(topicName!.contains("settings")){
        debugPrint("___________________________________________________");
        debugPrint("from which topic $topicName");
        debugPrint("__________ $decodeMessage");
        debugPrint("___________________________________________________");
        preferences.setString("settings_mqtt", decodeMessage);
      }
      if(topicName!.contains("data")){
        debugPrint("from which topic -data $topicName");
        preferences.setString("data_mqtt", decodeMessage);
      }
      if(topicName!.contains("alarm")){
        debugPrint("from which topic -alarm $topicName, $decodeMessage");
        //preferences.setString("data_mqtt", decodeMessage);


        SharedPreferences preferences = await SharedPreferences.getInstance();
        //Object ? alarmListData = preferences.get("alarm_list_mqtt");
        Map<String, dynamic> alarmMessageJson = json.decode(decodeMessage);
        List<Alarm> alarmList = Alarm.getAlarmList(alarmMessageJson);
//Alarm ? alarm = Alarm.decodeAlarm(decodeMessage);
        debugPrint("alarmList---: $alarmMessageJson");
        // Todo: save alarm to alarmList in localstorage

        // Todo: notifications
        NotificationHelper.sendMessage(alarmList.first);

      }

      //NotificationHelper.initializeService();
      print("======= pt: ${pt} , topic: $_topic1, $_topic2");
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
      });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}
