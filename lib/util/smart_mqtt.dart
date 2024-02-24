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

class SmartMqtt extends ChangeNotifier {
  late String host;
  late int port;

  late String mqttPass;
  late String username;

  late List topicList;
  late String _identifier;

  late String currentTopic;

  int messageCount = 0;
  bool dataSet = false;

  MQTTAppConnectionState? currentState; //= MQTTAppConnectionState.disconnected;

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
    //_instance.initializeMQTTClient();
    debugPrint("SMARTMQTT");
    return _instance;
  }

  bool debug = true;
  late bool isSaved = false;
  late bool newSettingsMessageLoaded = false;
  late String newUserSettings = "";

  void disconnect() {
    currentState = MQTTAppConnectionState.disconnected;
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
    print('onSubscribed::Subscription confirmed for topic $topic');
  }

  /// The subscribed callback
  void unsubscribe(String topic) {
    print('onunSubscribed::UNSubscription confirmed for topic $topic');
    client.unsubscribe(topic);
  }

  void onAutoReconnect() {
    String clientID = client.clientIdentifier;
    currentState = MQTTAppConnectionState.connected;

    print(
        "///////////////////////////// onAutoReconnect  $clientID, $currentState ///////////////////////////////////");
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    currentState = MQTTAppConnectionState.disconnected;

    String clientID = client.clientIdentifier;
    print(
        "///////////////////////////// onDisconnected  $clientID, $currentState ///////////////////////////////////");
    MqttConnectReturnCode? returnCode = client.connectionStatus!.returnCode;
    print(
        ':OnDisconnected client callback - Client disconnection, return code: $returnCode');
    if (client.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print(":OnDisconnected callback is solicited, this is correct");
    }
    currentState = MQTTAppConnectionState.disconnected;
  }

  /// The successful connect callback
  void onConnected() {
    String clientID = client.clientIdentifier;
    currentState = MQTTAppConnectionState.connected;

    print(
        "///////////////////////////// onConnected,  $clientID, $currentState  ///////////////////////////////////");

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
    /* Alarm alarm = Alarm(
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

    if (topicName!.contains("data")) {
      if(!dataSet) {
        Data? data = convertMessageToData(decodeMessage, topicName);
        setDataListToPreferences(data!, preferences);
        //preferences.setString("data_mqtt", decodeMessage);

        debugPrint("___________________________________________________");
        debugPrint("from topic data $topicName");
        debugPrint("__________ $decodeMessage");
        debugPrint("___________________________________________________");
        dataSet = true;
      }
    }
    /***  polnjenje objekta - settings ***/
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
          preferences.setString("current_mqtt_settings", decodeMessage);
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
      debugPrint("alarm!!!!!");
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

        DateTime? lastAlarmDate = await _getLastAlarmDate();

        int? lastSentHiAlarmValue = await _getLastSentHiAlarm();

        int? lastSentLoAlarmValue = await _getLastSentLoAlarm();
        int minutes = 6;
        if (lastAlarmDate != null) {
          minutes = Utils.compareDatesInMinutes(lastAlarmDate!, DateTime.now());
        }
        int? currentHiAlarm;
        currentHiAlarm = currentAlarmList.first.hiAlarm;
        int? currentLoAlarm;
        currentLoAlarm = currentAlarmList.first.loAlarm;

        //ali je vec kot 5 minut od alarma
        /**** ToDo ali je prejsnja vrednost poslanega alarma vecja od druge in je minilo manj kot 5 min*****/
        if ((lastAlarmDate == null || minutes >= 5))
        // || (minutes<3 && lastSentHiAlarmValue! < currentHiAlarm! )) {

        {
          debugPrint(
              "from topic-alarm $topicName, $decodeMessage, message count: $messageCount ");

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
            /*********************/
            if (currentAlarmList.first.hiAlarm != null) {
              value.setInt(
                  "last_sent_hi_alarm_value", currentAlarmList.first.hiAlarm!);
            } else if (currentAlarmList.first.loAlarm != null) {
              value.setInt(
                  "last_sent_lo_alarm_value", currentAlarmList.first.loAlarm!);
            }
            /*********************/
          });
        } else {
          debugPrint("minutes<5, not showing alarm");
          debugPrint(
              "from topic-alarm $topicName, $decodeMessage, message count: $messageCount ");
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

  Future<DateTime?> _getLastAlarmDate() async {
    return await SharedPreferences.getInstance().then((value) {
      if (value.getString("last_sent_alarm_date") != null) {
        String? lastAlarmDateString = value.getString("last_sent_alarm_date");
        //debugPrint("last_sent_alarm_date $lastAlarmDateString");
        return DateTime.parse(lastAlarmDateString!);
      }
    });
  }

  Future<int?> _getLastSentLoAlarm() async {
    return await SharedPreferences.getInstance().then((value) {
      if (value.getInt("last_sent_lo_alarm_value") != null) {
        int? lastSentLoAlarmValue = value.getInt("last_sent_lo_alarm_value");
        debugPrint("last_sent_lo_alarm_value $lastSentLoAlarmValue");
        return lastSentLoAlarmValue;
      }
    });
  }

  Future<int?> _getLastSentHiAlarm() async {
    return await SharedPreferences.getInstance().then((value) {
      if (value.getInt("last_sent_hi_alarm_value") != null) {
        int? lastSentHiAlarmValue = value.getInt("last_sent_hi_alarm_value");
        //debugPrint("last_sent_hi_alarm_value $lastSentHiAlarmValue");
        return lastSentHiAlarmValue;
      }
    });
  }

  Future<MqttServerClient> initializeMQTTClient(String username,
      String password1, String identifier, List topicList1) async {
    debugPrint(" calling smart_mqtt.dart - initializeMQTTClient");
    String osPrefix = 'Flutter_iOS';
    // if (Platform.isAndroid()) {
    osPrefix = 'Flutter_Android';
    topicList = topicList1;

    String l = Utils.generateRandomString(10);
    //String identifier = "_12apxeeejjjewg";
    String identifier = l.toString();

    _identifier = identifier;
    client = MqttServerClient(Constants.BROKER_IP, identifier,
        maxConnectionAttempts: 1);
    client.port = 1883;
    client.keepAlivePeriod = 50;
    //client.autoReconnect = true;
    client.autoReconnect = true;
    // client.setProtocolV311();
    client.onDisconnected = onDisconnected;
    client.onAutoReconnect = onAutoReconnect;
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    client.secure = false;
    //client.maxConnectionAttempts = 1;
    // client.resubscribeOnAutoReconnect = true;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(username, password1)
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    debugPrint(':: client connecting....');
    client.connectionMessage = connMess;

    try {
      print('::Navis app client connecting....');
      currentState = MQTTAppConnectionState.connecting;
      //client.keepAlivePeriod = 20;
      String clientID = client.clientIdentifier;
      print(
          "*********************** Connecting to broker, client id $clientID, $currentState *******************************");
      await client.connect(username, password1);
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

  Data? convertMessageToData(String message, String deviceName) {
    String decodeMessage = const Utf8Decoder().convert(message.codeUnits);
    Map<String, dynamic> dataStr = json.decode(decodeMessage);

    Data? data = Data().getData(dataStr);
    // Data data = json.decode(dataStr);
    data?.deviceName = deviceName;

    debugPrint(
        "converting data object...${data?.deviceName}, ${data?.sensorAddress}, ${data?.typ}, ${data?.t}");

    return data;
  }

  void setDataListToPreferences(Data newData, SharedPreferences preferences) {
    String? dataListStr = preferences.getString("data_mqtt_list");
    List ?dataList;
    if (dataListStr != null) {
      final jsonResult = jsonDecode(dataListStr!);
      dataList = Data.fromJsonList(jsonResult);
      dataList.add(newData);
    } else {
      dataList = [];
      dataList.add(newData);
    }
    String encodedData = json.encode(dataList);
    preferences.setString("data_mqtt_list", encodedData);
    debugPrint("setting data_mqtt_list $encodedData");
  }
}

//subscribe to topic failed
void onSubscribeFail(String topic) {
  print('Failed to subscribe $topic');
}
