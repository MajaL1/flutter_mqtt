import 'dart:convert';

import 'package:flutter/material.dart';

class NotificationMessage {
  int? id;
  String ?channel;
  String title;
  String ?description;
  bool on;

  NotificationMessage(
      {
        this.id = 0,
        required this.channel,
        required this.title,
        required this.description,
        required this.on});

  // Class Function
  showNotificationInfo() {
    debugPrint("Notification message : $id, $channel, $title, $description, $on");
  }

  factory NotificationMessage.fromJson(Map<String, dynamic> map) {
    return NotificationMessage(
        id: map["id"],
        channel: map["channel"],
        title: map["title"],
        description: map["description"],
        on: map["on"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "channel": channel
      ,"title": title, "description": description, "on": on};
  }

  List<NotificationMessage> notificationMessageFromJson(String jsonData) {
    final data = json.decode(jsonData);
    return List<NotificationMessage>.from(
        data.map((item) => NotificationMessage.fromJson(item)));
  }

  String notificationMessageToJson(NotificationMessage data) {
    final jsonData = data.toJson();
    return json.encode(jsonData);
  }

  @override
  String toString() {
    return 'Notification{id: $id, name: $title}';
  }

  void main() {
    //var notificationMessage = new NotificationMessage(title: '');
  }
}
