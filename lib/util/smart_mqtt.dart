import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/notification_helper.dart';
import '../model/alarm.dart';
import '../mqtt/state/MQTTAppState.dart';

class SmartMqtt {
 late String host;
 late int port;
// late MQTTAppState _currentState = MQTTAppState().setAppConnectionState("disconnected");
  MQTTAppConnectionState currentState = MQTTAppConnectionState.disconnected;

  //MqttServerClient ?client;
 late String _identifier;
 late String _host;
 late String topic1;
 late String topic2;
 late String topic3;

 late MqttClient client;
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
    String ip = "BROKER_IP",
    int port = 0,
    String host = "",

    String topic1 = "topic1",
    String topic2 = "topic1",
    String topic3 = "topic1",
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
  currentState = MQTTAppConnectionState.disconnected;
  // .setAppConnectionState(MQTTAppConnectionState.disconnected);
}

/// The successful connect callback
void onConnected() {
  //_currentState.setAppConnectionState(MQTTAppConnectionState.connected);
  currentState = MQTTAppConnectionState.connected;

  print('on Connected: EXAMPLE::Mosquitto client connected....');
  client!.subscribe(topic1, MqttQos.atLeastOnce);
  client!.subscribe(topic2, MqttQos.atLeastOnce);
  client!.subscribe(topic3, MqttQos.atLeastOnce);

  client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
    // ignore: avoid_as
    final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

    // final MqttPublishMessage recMess = c![0].payload;
    final String pt =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
    //_currentState.setReceivedText(pt);

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
      preferences.setString("settings_mqtt_device_name", topicName.split("/settings").first);
    }
    if(topicName!.contains("data")){
      //debugPrint("from which topic -data $topicName");
      //preferences.setString("data_mqtt", decodeMessage);
    }
    if(topicName!.contains("alarm")){
      debugPrint("from which topic -alarm $topicName, $decodeMessage");

      //prebere listo alarmov iz preferenc in jim doda nov alarm
      SharedPreferences preferences = await SharedPreferences.getInstance();

      // 1. dobi listo prejsnjih alarmov
      String? alarmListOldData = preferences.get("alarm_list_mqtt") as String?;
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
      NotificationHelper.sendMessage(currentAlarmList.first);
    }
    print("======= pt: ${pt} , topic: $topic1, $topic2");
    print(
        'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    print('');
  });
  print(
      'EXAMPLE::OnConnected client callback - Client connection was sucessful');
}


// Connect to the host
// ignore: avoid_void_async
Future<void> connect() async {
  assert(client != null);
  try {
    String username= "test";
    String password = "MWQxYjRkZWJlZjQ2MWViNQ==";
    print('::Navis app client connecting....');
    currentState = MQTTAppConnectionState.connecting;
    await client!.connect(username, password);
  } on Exception catch (e) {
    print('Navis app::client exception - $e');
    disconnect();
  }
}


void initializeMQTTClient() {
  String osPrefix = 'Flutter_iOS';
  // if (Platform.isAndroid()) {
  osPrefix = 'Flutter_Android';
  _identifier = osPrefix;
  client = MqttServerClient(host, _identifier);
  client!.port = 1883;
  client!.keepAlivePeriod = 20;
  client!.onDisconnected = onDisconnected;
  //client!.secure = false;
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



}
// Subscribe and Unsubscribe to the topics on-the-fly like this
//mqtt.subscribe(topic);
//mqtt.unsubscribe(topic);
