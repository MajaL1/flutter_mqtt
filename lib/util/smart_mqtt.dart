import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';

import '../model/constants.dart';

class SmartMqtt {
  String ip;
  int port;

  MqttClient client;
  MqttConnectionState connectionState;
  StreamSubscription subscription;
  bool isConnected = false;

  // <<--------------- Important --------------->>
  final StreamController _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get stream => _controller.stream;

  // <<--------------- Important --------------->>
  final StreamController _subscriptionController = StreamController<String>();
  final StreamController _unsubscriptionController = StreamController<String>();

  // <<--------------- Important --------------->> Make this class a 'Singleton'
  static final SmartMqtt _instance = SmartMqtt._internal();

  SmartMqtt._internal();

  factory SmartMqtt({
    String ip = Constants.BROKER_IP,
    int port = Constants.BROKER_PORT,
  }) {
    _instance.ip = ip;
    _instance.port = port;
    return _instance;
  }

  // Setup Client before connecting, feel free to add additional params like keepAlive  etc.
  client.onConnected

  =

  ()

  {

  _subscriptionController.stream.listen

  (

  (topic) { //<---- Created a Subscribe stream listener
  client.subscribe(topic, MqttQos.exactlyOnce);
  if(debug)
  print('[SmartMqtt] Subscribed -> $topic');
  });
  _unsubscriptionController.stream.listen((topic) { // <---- Created a Unsubscribe stream listener
  client.unsubscribe(topic);
  if(debug)
  print('[SmartMqtt] Unsubscribed -> $topic');
  });
};

// Stream Listener callback that handles received message
mqtt.stream.asBroadcastStream().listen((msg) {
// Do something nice here with received message
}
});

// Subscribe and Unsubscribe to the topics on-the-fly like this
/**mqtt.subscribe(topic);
mqtt.unsubscribe(topic);

void subscribe(String topic) {
  _subscriptionController.sink.add(topic);
}

void unsubscribe(String topic) {
  _unsubscriptionController.sink.add(topic);
}} */