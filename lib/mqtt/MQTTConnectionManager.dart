import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_test/mqtt/state/MQTTAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MQTTConnectionManager {
  // Private instance of client
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;

  // Constructor
  // ignore: sort_constructors_first
  MQTTConnectionManager(
      {required String host,
        required String topic,
        required String identifier,
        required MQTTAppState state})
      : _identifier = identifier,
        _host = host,
        _topic = topic,
        _currentState = state;

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic(
        'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE:: client connecting....');
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  // ignore: avoid_void_async
  Future<void> connect() async {
    assert(_client != null);
    try {
      String username= "test1";
      String password = "MDQ0MThmZmM1NTI4OGQ4OQ==";
      print('::Navis app client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect(username, password);
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    print('on Connected: EXAMPLE::Mosquitto client connected....');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      _currentState.setReceivedText(pt);

      String message =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);


      String decodeMessage = const Utf8Decoder().convert(message.codeUnits);

      debugPrint("__________ $decodeMessage");
      print("MQTTClientWrapper::GOT A NEW MESSAGE $decodeMessage");


      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("settings_mqtt", decodeMessage);
      print("======= pt: ${pt}");
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}
